import Foundation
import CardinalMobile
import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objc public class BTPaymentActionsClient: NSObject {
    
    // MARK: - Internal Properties
    
    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    /// Exposed for testing to inject a mock Cardinal session for the 3DS customer-action drive path.
    var cardinalSession: CardinalSessionTestable = CardinalSession()

    /// Exposed for testing to control the foreground gate without depending on the real
    /// `UIApplication`. `nil` defaults to `UIApplication.shared`, resolved by
    /// `BTPaymentActionThreeDSecureProvider`'s own initializer — not here, since `UIApplication.shared`
    /// is main-actor-isolated and can't be used as a stored-property initializer value.
    var applicationStateProvider: ApplicationStateProviding?

    /// Tracks whether a `handleNextAction` drive loop is already in flight on this client instance.
    var isHandlingNextAction = false

    /// Options customizing the 3D Secure challenge presented during the Payment Actions drive path. Applies to
    /// every call this client makes — create a new client with the same options if the app is killed.
    let threeDSecureLaunchOptions: BTThreeDSecureLaunchOptions

    // MARK: - Initializer

    /// Creates a Payment Actions Client.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls.
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
        self.threeDSecureLaunchOptions = BTThreeDSecureLaunchOptions()
    }

    /// Creates a Payment Actions Client with 3D Secure challenge customization.
    /// - Parameters:
    ///    - authorization: A valid client token or tokenization key used to authorize API calls.
    ///    - threeDSecureLaunchOptions: Options customizing the 3D Secure challenge. Not the
    ///    server-side `threeDSecureOptions` field used when creating the Payment Action, which is a
    ///    different thing.
    @objc(initWithAuthorization:threeDSecureLaunchOptions:)
    public init(authorization: String, threeDSecureLaunchOptions: BTThreeDSecureLaunchOptions) {
        self.apiClient = BTAPIClient(authorization: authorization)
        self.threeDSecureLaunchOptions = threeDSecureLaunchOptions
    }
    
    // MARK: - Public Methods
    
    /// Submits a payment method to a Payment Action.
    /// - Parameters:
    ///    - request: The payment method details to submit — e.g. a `BTCardPaymentActionRequest`.
    ///    - completion: A completion block that is invoked when the submission has completed. If it succeeds,
    ///    `status` will contain the resulting `BTPaymentActionStatus` and `error` will be `nil`; if it fails,
    ///    `error` will describe the failure.
    @objc(submitForPaymentActionWithRequest:completion:)
    public func submitForPaymentAction(
        _ request: BTPaymentActionRequest,
        completion: @escaping (BTPaymentActionResult?, Error?) -> Void
    ) {
        Task { @MainActor in
            do {
                let result = try await submitForPaymentAction(request)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    /// Submit a payment method for a Payment Action.
    /// - Parameter request: The payment method details to submit — e.g. a `BTCardPaymentActionRequest`.
    /// - Returns: the resulting `BTPaymentActionStatus`.
    /// - Throws: an `Error` describing the failure.
    public func submitForPaymentAction(
        _ request: BTPaymentActionRequest
    ) async throws -> BTPaymentActionResult {
        do {
            let body = try SetPaymentActionPaymentMethodGraphQLBody(request: request)
            let paymentAction = try await setPaymentActionPaymentMethod(body)
            return result(from: paymentAction)
        } catch {
            // TODO: Replace with the exact error type in a later PR.
            throw error
        }
    }
    
    /// Drives the Payment Action forward from its current server state until a terminal outcome or
    /// a handoff boundary is reached.
    /// - Parameter completion: A completion block invoked exactly once with the resulting
    ///   `BTPaymentActionResult`, or an `Error` describing the failure.
    @objc(handleNextActionWithCompletion:)
    public func handleNextAction(completion: @escaping (BTPaymentActionResult?, Error?) -> Void) {
        Task { @MainActor in
            do {
                let result = try await handleNextAction()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    /// Drives the Payment Action forward from its current server state until a terminal outcome or
    /// a handoff boundary is reached.
    ///
    /// If the Payment Action reaches `requires_customer_action` with a recognized 3D Secure
    /// `nextAction`, this drives device data collection and the challenge itself via an internal
    /// CardinalMobile wrapper, signaling completion after each step, and continues the loop — the
    /// merchant never sees an intermediate `.customerActionRequired` result for 3DS success. A
    /// `nextAction` this SDK doesn't recognize still surfaces `.customerActionRequired` immediately.
    ///
    /// A customer-abandoned or timed-out challenge surfaces `.threeDSecureCanceled` — the Payment
    /// Action is still alive and retryable, and this is never conflated with the general `.canceled`
    /// terminal status.
    ///
    /// A `.processing` result means the SDK's own bounded internal retries were exhausted while the
    /// Payment Action was still settling server-side — wait briefly, then call `handleNextAction` again.
    /// - Returns: the resulting `BTPaymentActionResult`.
    /// - Throws: `BTPaymentActionError.handleNextActionAlreadyInProgress` if called while a previous
    ///   invocation on this instance hasn't completed, or the underlying fetch/decoding/3DS error.
    @MainActor
    public func handleNextAction() async throws -> BTPaymentActionResult {
        guard !isHandlingNextAction else {
            throw BTPaymentActionError.handleNextActionAlreadyInProgress
        }

        isHandlingNextAction = true
        defer { isHandlingNextAction = false }

        // Shared across every customer-action step within this single handleNextAction call, so
        // device data collection and the challenge run on the same CardinalSession — Cardinal
        // documents a session as spanning configure/setup/continueWith together, and the existing 3DS
        // flow relies on this same-instance contract. Built lazily (only on the first recognized 3DS
        // nextAction), not at the top of this method, so non-3DS merchants never construct it at all.
        var threeDSecureProvider: BTPaymentActionThreeDSecureProvider?

        let handler = NextActionHandler(
            fetchPaymentAction: { [weak self] in
                guard let self else {
                    throw BTPaymentActionError.deallocated
                }
                return try await self.getPaymentAction()
            },
            resolveCustomerAction: { [weak self] nextAction in
                guard let self else {
                    throw BTPaymentActionError.deallocated
                }

                let provider: BTPaymentActionThreeDSecureProvider
                if let existing = threeDSecureProvider {
                    provider = existing
                } else {
                    provider = try await self.makeThreeDSecureProvider()
                    threeDSecureProvider = provider
                }

                return try await self.resolveCustomerAction(nextAction, using: provider)
            }
        )

        switch try await handler.drive() {
        case .paymentAction(let paymentAction):
            return result(from: paymentAction)
        case .threeDSecureCanceled(let id):
            return BTPaymentActionResult(type: .threeDSecureCanceled, id: id)
        }
    }

    // MARK: - Internal Methods

    /// Submits a payment method to the `setPaymentActionPaymentMethod` GraphQL mutation.
    /// - Parameter body: the GraphQL request body to submit, encoding the payment method
    ///   details and the fields to return on the `paymentAction` selection set.
    /// - Returns: a `BTPaymentActionResult` containing the Payment Action `id` and `status`.
    /// - Throws: the underlying error from the network layer or GraphQL response.
    func setPaymentActionPaymentMethod<Body: BTGraphQLEncodableBody>(
        _ body: Body
    ) async throws -> BTPaymentAction {
        apiClient.sendAnalyticsEvent(BTPaymentActionAnalytics.setPaymentActionPaymentMethodStarted)

        do {
            let (responseBody, _) = try await apiClient.post("", parameters: body, httpType: .graphQLAPI)

            let paymentActionJSON: BTJSON = responseBody?["data"]["setPaymentActionPaymentMethod"]["paymentAction"]
                ?? BTJSON()
            let paymentAction = try BTPaymentAction(json: paymentActionJSON)

            apiClient.sendAnalyticsEvent(BTPaymentActionAnalytics.setPaymentActionPaymentMethodSucceeded)

            return paymentAction
        } catch {
            apiClient.sendAnalyticsEvent(
                BTPaymentActionAnalytics.setPaymentActionPaymentMethodFailed,
                errorDescription: error.localizedDescription
            )
            throw error
        }
    }

    /// Self-fetches the current state of the Payment Action scoped to this client's authorization.
    /// - Returns: a `BTPaymentActionResult` containing the Payment Action's `id`, `status`,
    ///   and `nextAction` (if any).
    /// - Throws: the underlying error from the network layer or GraphQL response.
    func getPaymentAction() async throws -> BTPaymentAction {
        let (responseBody, _) = try await apiClient.post(
            "",
            parameters: GetPaymentActionGraphQLBody(),
            httpType: .graphQLAPI
        )

        let paymentActionJSON: BTJSON = responseBody?["data"]["paymentAction"] ?? BTJSON()
        return try BTPaymentAction(json: paymentActionJSON)
    }

    /// Signals that the customer has completed the current `nextAction` (e.g. device data collection
    /// or a 3D Secure challenge), advancing the Payment Action to its next state.
    /// - Parameter completedAction: the completed action's payload — mirrors the GraphQL `@oneOf` input.
    /// - Returns: the resulting `BTPaymentAction`, which may carry a new `nextAction` if another
    ///   customer action is required.
    /// - Throws: the underlying error from the network layer or GraphQL response.
    func signalCustomerActionComplete(_ completedAction: BTCustomerCompletedAction) async throws -> BTPaymentAction {
        let (responseBody, _) = try await apiClient.post(
            "",
            parameters: SignalCustomerActionCompleteGraphQLBody(completedAction: completedAction),
            httpType: .graphQLAPI
        )

        let paymentActionJSON: BTJSON = responseBody?["data"]["signalCustomerActionComplete"]["paymentAction"]
            ?? BTJSON()
        return try BTPaymentAction(json: paymentActionJSON)
    }
    
    /// Drives a single recognized 3D Secure `nextAction` to completion via `threeDSecureProvider`,
    /// signaling the result to the server afterward.
    /// - Throws: the underlying Cardinal/network error, or `BTPaymentActionError.decodingFailure` if
    ///   called with `.unrecognized` (never done by `NextActionHandler`, which handles that case itself).
    func resolveCustomerAction(
        _ nextAction: BTNextAction,
        using threeDSecureProvider: BTPaymentActionThreeDSecureProvider
    ) async throws -> NextActionHandler.CustomerActionOutcome {
        switch nextAction {
        case .threeDSecureAuthentication:
            let dfReferenceID = try await threeDSecureProvider.collectDeviceData()
            let paymentAction = try await signalCustomerActionComplete(.deviceDataCollection(dfReferenceID: dfReferenceID))
            return .advanced(paymentAction)

        case .threeDSecureChallenge(let challenge):
            guard let mpiTransactionID = challenge.mpiTransactionID else {
                throw BTPaymentActionError.missingMpiTransactionID
            }

            let outcome = try await threeDSecureProvider.presentChallenge(
                transactionID: mpiTransactionID,
                payload: challenge.challengePayload
            )

            switch outcome {
            case .validated(let serverJWT):
                let paymentAction = try await signalCustomerActionComplete(.challenge(cardinalAuthenticationJWT: serverJWT))
                return .advanced(paymentAction)
            case .abandoned:
                return .abandoned
            }

        case .unrecognized:
            throw BTPaymentActionError.decodingFailure
        }
    }

    /// Fetches configuration and constructs a fresh `BTPaymentActionThreeDSecureProvider`.
    /// - Throws: `BTPaymentActionError.missingCardinalAuthenticationJWT` if this merchant's
    ///   configuration has no Cardinal authentication JWT.
    func makeThreeDSecureProvider() async throws -> BTPaymentActionThreeDSecureProvider {
        let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
        return try await BTPaymentActionThreeDSecureProvider(
            configuration: configuration,
            threeDSecureLaunchOptions: threeDSecureLaunchOptions,
            cardinalSession: cardinalSession,
            applicationStateProvider: applicationStateProvider
        )
    }

    /// Maps a raw `BTPaymentAction` (id + status from the GraphQL response) into the semantic
    /// `BTPaymentActionResult` the merchant acts on.
    func result(from paymentAction: BTPaymentAction) -> BTPaymentActionResult {
        switch paymentAction.status {
        case .requiresPaymentMethod:
            return BTPaymentActionResult(type: .paymentMethodRequired, id: paymentAction.id)
        case .readyForConfirmation:
            return BTServerActionRequiredResult(id: paymentAction.id, serverAction: .confirm)
        case .requiresCapture:
            return BTServerActionRequiredResult(id: paymentAction.id, serverAction: .capture)
        case .requiresCustomerAction:
            return BTPaymentActionResult(type: .customerActionRequired, id: paymentAction.id)
        case .processing:
            return BTPaymentActionResult(type: .processing, id: paymentAction.id)
        case .succeeded:
            return BTPaymentActionResult(type: .completed, id: paymentAction.id)
        case .canceled:
            return BTPaymentActionResult(type: .canceled, id: paymentAction.id)
        case .expired:
            return BTPaymentActionResult(type: .expired, id: paymentAction.id)
        case .unknown:
            return BTPaymentActionResult(type: .unrecognized, id: paymentAction.id)
        }
    }
}
