import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

@objcMembers public class BTLocalPaymentClient: BTWebAuthenticationSessionClient {

    // MARK: - Internal Properties

    var webAuthenticationSession: BTWebAuthenticationSession

    /// Indicates if the user returned back to the merchant app from the `BTWebAuthenticationSession`
    /// Will only be `true` if the user proceeded through the `UIAlertController`
    var webSessionReturned: Bool = false

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    // MARK: - Private Properties

    private var request: BTLocalPaymentRequest?

    /// Used for linking events from the client to server side request
    /// In the Local Payment flow this will be a Payment Token/Order ID
    private var contextID: String?

    // MARK: - Initializer

    /// Initialize a new `BTLocalPaymentClient` instance.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls.
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
        self.webAuthenticationSession = BTWebAuthenticationSession()
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Public Methods

    /// Starts a payment flow using a `BTLocalPaymentRequest`
    /// - Parameters:
    ///   - request: A `BTLocalPaymentRequest` request.
    ///   - completion: This completion will be invoked exactly once when the payment flow is complete or an error occurs.
    public func start(_ request: BTLocalPaymentRequest, completion: @escaping (BTLocalPaymentResult?, Error?) -> Void) {
        Task { @MainActor in
            do {
                let result = try await start(request)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    /// Starts a payment flow using a `BTLocalPaymentRequest`
    /// - Parameter request: A `BTLocalPaymentRequest` request.
    /// - Returns: A `BTLocalPaymentResult` if successful
    /// - Throws: An `Error` describing the failure
    public func start(_ request: BTLocalPaymentRequest) async throws -> BTLocalPaymentResult {
        apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentStarted)
        self.request = request

        do {
            let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
            
            guard configuration.isLocalPaymentEnabled else {
                NSLog(
                    "%@ Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments.",
                    BTLogLevelDescription.string(for: .critical)
                )
                notifyFailure(with: BTLocalPaymentError.disabled)
                throw BTLocalPaymentError.disabled
            }

            guard request.localPaymentFlowDelegate != nil else {
                NSLog(
                    "%@ BTLocalPaymentRequest localPaymentFlowDelegate can not be nil.",
                    BTLogLevelDescription.string(for: .critical)
                )
                notifyFailure(with: BTLocalPaymentError.integration)
                throw BTLocalPaymentError.integration
            }
            
            let dataCollector = BTDataCollector(authorization: self.apiClient.authorization.originalValue)
            request.correlationID = dataCollector.clientMetadataID(nil)

            return try await start(request: request, configuration: configuration)
        } catch {
            notifyFailure(with: error)
            throw error
        }
    }

    // MARK: - Internal Methods

    func applicationDidBecomeActive(notification: Notification) {
        webSessionReturned = true
    }

    func handleOpen(_ url: URL) async throws -> BTLocalPaymentResult {
        // canceled case
        if url.host == "x-callback-url" && url.path.hasPrefix("/braintree/local-payment/cancel") {
            let canceledError = BTLocalPaymentError.canceled(request?.paymentType ?? "unknown")
            notifyFailure(with: canceledError)
            throw canceledError
        }

        let localPaymentPayPalAccountRequest = LocalPaymentPayPalAccountsPOSTBody(
            request: self.request,
            clientMetadata: self.apiClient.metadata,
            url: url
        )

        let (body, _) = try await self.apiClient.post(
            "/v1/payment_methods/paypal_accounts",
            parameters: localPaymentPayPalAccountRequest
        )

        guard let body else {
            notifyFailure(with: BTLocalPaymentError.noAccountData)
            throw BTLocalPaymentError.noAccountData
        }

        guard let tokenizedLocalPayment = BTLocalPaymentResult(json: body) else {
            notifyFailure(with: BTLocalPaymentError.failedToCreateNonce)
            throw BTLocalPaymentError.failedToCreateNonce
        }

        notifySuccess(with: tokenizedLocalPayment)
        return tokenizedLocalPayment
    }

    // MARK: - Private Methods

    private func start(request: BTLocalPaymentRequest, configuration: BTConfiguration) async throws -> BTLocalPaymentResult {
        let localPaymentRequest = LocalPaymentPOSTBody(localPaymentRequest: request)

        let (body, _) = try await self.apiClient.post("v1/local_payments/create", parameters: localPaymentRequest)

        guard let body else {
            NSLog(
                "%@ Payment cannot be processed: response body is nil. Contact Braintree support if the error persists.",
                BTLogLevelDescription.string(for: .critical)
            )
            notifyFailure(with: BTLocalPaymentError.noAccountData)
            throw BTLocalPaymentError.noAccountData
        }

        guard
            let paymentID = body["paymentResource"]["paymentToken"].asString(),
            let approvalURLString = body["paymentResource"]["redirectUrl"].asString(),
            let url = URL(string: approvalURLString)
        else {
            NSLog(
                // swiftlint:disable:next line_length
                "%@ Payment cannot be processed: the redirectUrl or paymentToken is nil. Contact Braintree support if the error persists.",
                BTLogLevelDescription.string(for: .critical)
            )
            notifyFailure(with: BTLocalPaymentError.appSwitchFailed)
            throw BTLocalPaymentError.appSwitchFailed
        }

        if !paymentID.isEmpty {
            self.contextID = paymentID
        }
        
        // Call delegate to inform payment has started
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            request.localPaymentFlowDelegate?.localPaymentStarted(request, paymentID: paymentID) {
                continuation.resume()
            }
        }

        return try await launchWebSession(url: url)
    }

    /// Launches the `BTWebAuthenticationSession` and suspends until the session completes,
    /// cancels, or errors — then either returns a result or throws.
    private func launchWebSession(url: URL) async throws -> BTLocalPaymentResult {
        return try await withCheckedThrowingContinuation { continuation in
            webSessionReturned = false

            webAuthenticationSession.start(url: url, context: self) { [weak self] callbackURL, error in
                guard let self else {
                    NSLog("%@ BTLocalPaymentClient has been deallocated.", BTLogLevelDescription.string(for: .critical))
                    continuation.resume(throwing: BTLocalPaymentError.unknown)
                    return
                }

                if let error {
                    apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                    continuation.resume(throwing: BTLocalPaymentError.webSessionError(error))
                    return
                }

                guard let callbackURL else {
                    apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserLoginFailed)
                    apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                    continuation.resume(throwing: BTLocalPaymentError.missingReturnURL)
                    return
                }

                // Use Task to handle the async handleOpen call
                Task {
                    do {
                        let result = try await self.handleOpen(callbackURL)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }

            } sessionDidAppear: { [weak self] didAppear in
                guard let self else { return }
                if didAppear {
                    apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserPresentationSucceeded)
                } else {
                    apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserPresentationFailed)
                }
            } sessionDidCancel: { [weak self] in
                guard let self else { return }
                if !webSessionReturned {
                    apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserLoginAlertCanceled)
                }
                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentCanceled)
                continuation.resume(throwing: BTLocalPaymentError.canceled(self.request?.paymentType ?? ""))
            }
        }
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(with result: BTLocalPaymentResult) {
        apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentSucceeded, contextID: contextID)
    }

    private func notifyFailure(with error: Error) {
        apiClient.sendAnalyticsEvent(
            BTLocalPaymentAnalytics.paymentFailed,
            contextID: contextID,
            errorDescription: error.localizedDescription
        )
    }
}
