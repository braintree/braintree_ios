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
    /// Will only be `true` if the user proceed through the `UIAlertController`
    var webSessionReturned: Bool = false

    /// exposed for testing
    var merchantCompletion: ((BTLocalPaymentResult?, Error?) -> Void) = { _, _ in }
    
    // MARK: - Private Properties
    
    private let apiClient: BTAPIClient
    private var request: BTLocalPaymentRequest?

    /// Used for linking events from the client to server side request
    /// In the Local Payment flow this will be a Payment Token/Order ID
    private var payPalContextID: String?

    // MARK: - Initializer

    /// Initialize a new `BTLocalPaymentClient` instance.
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
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
    public func startPaymentFlow(_ request: BTLocalPaymentRequest, completion: @escaping (BTLocalPaymentResult?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentStarted)

        self.request = request
        self.merchantCompletion = completion

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }

            let dataCollector = BTDataCollector(apiClient: self.apiClient)
            request.correlationID = dataCollector.clientMetadataID(nil)

            guard let configuration else {
                self.notifyFailure(with: BTLocalPaymentError.fetchConfigurationFailed, completion: completion)
                return
            }

            if !configuration.isLocalPaymentEnabled {
                NSLog(
                    "%@ Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments.",
                    BTLogLevelDescription.string(for: .critical)
                )
                self.notifyFailure(with: BTLocalPaymentError.disabled, completion: completion)
                return
            } else if request.localPaymentFlowDelegate == nil {
                NSLog("%@ BTLocalPaymentRequest localPaymentFlowDelegate can not be nil.", BTLogLevelDescription.string(for: .critical))
                self.notifyFailure(with: BTLocalPaymentError.integration, completion: completion)
                return
            }

            self.start(request: request, configuration: configuration)
        }
    }
    
    /// Starts a payment flow using a `BTLocalPaymentRequest`
    /// - Parameter request: A `BTLocalPaymentRequest` request.
    /// - Returns: A `BTLocalPaymentResult` if successful
    /// - Throws: An `Error` describing the failure
    public func startPaymentFlow(_ request: BTLocalPaymentRequest) async throws -> BTLocalPaymentResult {
        try await withCheckedThrowingContinuation { continuation in
            startPaymentFlow(request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    // MARK: - Internal Methods

    func applicationDidBecomeActive(notification: Notification) {
        webSessionReturned = true
    }

    func handleOpen(_ url: URL) {
        // canceled case
        if url.host == "x-callback-url" && url.path.hasPrefix("/braintree/local-payment/cancel") {
            let canceledError = BTLocalPaymentError.canceled(request?.paymentType ?? "unknown")
            notifyFailure(with: canceledError, completion: merchantCompletion)
            return
        }

        let localPaymentPayPalAccountRequest = LocalPaymentPayPalAccountsPOSTBody(
            request: request,
            clientMetadata: apiClient.metadata,
            url: url
        )
        apiClient.post("/v1/payment_methods/paypal_accounts", parameters: localPaymentPayPalAccountRequest) { [weak self] body, _, error in
            guard let self else {
                NSLog("%@ BTLocalPaymentClient has been deallocated.", BTLogLevelDescription.string(for: .critical))
                return
            }

            if let error {
                notifyFailure(with: error, completion: merchantCompletion)
                return
            }

            guard let body else {
                notifyFailure(with: BTLocalPaymentError.noAccountData, completion: merchantCompletion)
                return
            }

            guard let tokenizedLocalPayment = BTLocalPaymentResult(json: body) else {
                notifyFailure(with: BTLocalPaymentError.failedToCreateNonce, completion: merchantCompletion)
                return
            }

            notifySuccess(with: tokenizedLocalPayment, completion: merchantCompletion)
        }
    }

    // MARK: - Private Methods

    private func start(request: BTLocalPaymentRequest, configuration: BTConfiguration) {
        let localPaymentRequest = LocalPaymentPOSTBody(localPaymentRequest: request)
        apiClient.post("v1/local_payments/create", parameters: localPaymentRequest) { body, _, error in
            if let error {
                self.notifyFailure(with: error, completion: self.merchantCompletion)
                return
            }

            if
                let paymentID = body?["paymentResource"]["paymentToken"].asString(),
                let approvalURLString = body?["paymentResource"]["redirectUrl"].asString(),
                let url = URL(string: approvalURLString) {

                if !paymentID.isEmpty {
                    self.payPalContextID = paymentID
                }

                self.request?.localPaymentFlowDelegate?.localPaymentStarted(request, paymentID: paymentID) {
                    self.onPayment(with: url, error: error)
                }
            } else {
                NSLog(
                    """
                    %@ Payment cannot be processed: the redirectUrl or paymentToken is nil. Contact Braintree support if the error persists.
                    """,
                    BTLogLevelDescription.string(for: .critical)
                )
                self.notifyFailure(with: BTLocalPaymentError.appSwitchFailed, completion: self.merchantCompletion)
                return
            }
        }
    }

    private func onPayment(with url: URL?, error: Error?) {
        if let error {
            notifyFailure(with: error, completion: merchantCompletion)
            return
        }

        guard let url else {
            notifyFailure(with: BTLocalPaymentError.missingRedirectURL, completion: merchantCompletion)
            return
        }

        webSessionReturned = false
        webAuthenticationSession.start(url: url, context: self) { [weak self] url, error in
            guard let self else {
                NSLog("%@ BTLocalPaymentClient has been deallocated.", BTLogLevelDescription.string(for: .critical))
                return
            }

            if let error {
                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                onPayment(with: nil, error: BTLocalPaymentError.webSessionError(error))
                return
            }

            if let url {
                handleOpen(url)
            } else {
                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserLoginFailed)
                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                onPayment(with: nil, error: BTLocalPaymentError.missingReturnURL)
            }
        } sessionDidAppear: { [self] didAppear in
            if didAppear {
                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserPresentationSucceeded)
            } else {
                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserPresentationFailed)
            }
        } sessionDidCancel: { [self] in
            if !webSessionReturned {
                // User tapped system cancel button on permission alert
                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserLoginAlertCanceled)
            }

            // User canceled by breaking out of the LocalPayment browser switch flow
            // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
            apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentCanceled)
            onPayment(with: nil, error: BTLocalPaymentError.canceled(self.request?.paymentType ?? ""))
            return
        }
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(
        with result: BTLocalPaymentResult,
        completion: @escaping (BTLocalPaymentResult?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentSucceeded, payPalContextID: payPalContextID)
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTLocalPaymentResult?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTLocalPaymentAnalytics.paymentFailed,
            errorDescription: error.localizedDescription,
            payPalContextID: payPalContextID
        )
        completion(nil, error)
    }
}
