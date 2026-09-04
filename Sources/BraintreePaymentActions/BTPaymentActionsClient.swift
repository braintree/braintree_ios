import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objc public class BTPaymentActionsClient: NSObject {
    
    // MARK: - Internal Properties
    
    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    /// Creates a Payment Actions Client.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls.
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
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
            let (body, _) = try await apiClient.post("", parameters: body, httpType: .graphQLAPI)
            
            let paymentActionJSON: BTJSON = body?["data"]["setPaymentActionPaymentMethod"]["paymentAction"] ?? BTJSON()
            
            guard let paymentActionID = paymentActionJSON["id"].asString(), !paymentActionID.isEmpty else {
                apiClient.sendAnalyticsEvent(
                    BTPaymentActionAnalytics.setPaymentActionPaymentMethodFailed,
                    errorDescription: BTPaymentActionError.missingID.errorDescription
                )
                throw BTPaymentActionError.missingID
            }
            
            guard let statusString = paymentActionJSON["status"].asString(), !statusString.isEmpty else {
                apiClient.sendAnalyticsEvent(
                    BTPaymentActionAnalytics.setPaymentActionPaymentMethodFailed,
                    errorDescription: BTPaymentActionError.missingStatus.errorDescription
                )
                throw BTPaymentActionError.missingStatus
            }
            
            let status = BTPaymentActionStatus.status(from: statusString)
            apiClient.sendAnalyticsEvent(
                BTPaymentActionAnalytics.setPaymentActionPaymentMethodSucceeded
            )
            return BTPaymentAction(id: paymentActionID, status: status)
        } catch {
            apiClient.sendAnalyticsEvent(
                BTPaymentActionAnalytics.setPaymentActionPaymentMethodSucceeded,
                errorDescription: error.localizedDescription
            )
            throw error
        }
    }
    
    /// Maps a raw `BTPaymentAction` (id + status from the GraphQL response) into the semantic
    /// `BTPaymentActionResult` the merchant acts on.
    func result(from paymentAction: BTPaymentAction) -> BTPaymentActionResult {
        switch paymentAction.status {
        case .requiresPaymentMethod:
            return BTPaymentActionResult(type: .paymentMethodRequired, id: paymentAction.id)
        case .readyForConfirmation:
            return BTPaymentActionResult(type: .serverActionRequired, id: paymentAction.id, serverAction: .confirm)
        case .requiresCapture:
            return BTPaymentActionResult(type: .serverActionRequired, id: paymentAction.id, serverAction: .capture)
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
            return BTPaymentActionResult(type: .unknown, id: paymentAction.id)
        }
    }
}
