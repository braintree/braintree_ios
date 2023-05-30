import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

@objcMembers public class BTLocalPaymentClient: NSObject {
    
    // MARK: - Internal Properties
    
    var webAuthenticationSession: BTWebAuthenticationSession

    /// Indicates if the user returned back to the merchant app from the `BTWebAuthenticationSession`
    /// Will only be `true` if the user proceed through the `UIAlertController`
    var webSessionReturned: Bool = false

    /// exposed for testing
    var merchantCompletion: ((BTLocalPaymentResult?, Error?) -> Void)? = nil
    
    // MARK: - Private Properties
    
    private let apiClient: BTAPIClient
    private var request: BTLocalPaymentRequest?

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
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                completion(nil, error)
                return
            }

            let dataCollector = BTDataCollector(apiClient: self.apiClient)
            request.correlationID = dataCollector.clientMetadataID(nil)

            guard let configuration else {
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                completion(nil, BTLocalPaymentError.fetchConfigurationFailed)
                return
            }

            if !configuration.isLocalPaymentEnabled {
                NSLog("%@ Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments.", BTLogLevelDescription.string(for: .critical))
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                completion(nil, BTLocalPaymentError.disabled)
                return
            } else if request.localPaymentFlowDelegate == nil {
                NSLog("%@ BTLocalPaymentRequest localPaymentFlowDelegate can not be nil.", BTLogLevelDescription.string(for: .critical))
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                completion(nil, BTLocalPaymentError.integration)
                return
            } else if request.amount == nil || request.paymentType == nil {
                NSLog("%@ BTLocalPaymentRequest amount and paymentType can not be nil.", BTLogLevelDescription.string(for: .critical))
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                completion(nil, BTLocalPaymentError.integration)
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

    @objc func applicationDidBecomeActive(notification: Notification) {
        webSessionReturned = true
    }

    func handleOpen(_ url: URL) {
        // canceled case
        if url.host == "x-callback-url" && url.path.hasPrefix("/braintree/local-payment/cancel") {
            apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
            merchantCompletion?(nil, BTLocalPaymentError.canceled(request?.paymentType ?? "unknown"))
            return
        }

        var paypalAccount: [String: Any] = [
            "response": ["webURL": url.absoluteString],
            "response_type": "web",
            "options": ["validate": false],
            "intent": "sale"
        ]

        if let correlationID = request?.correlationID {
            paypalAccount["correlation_id"] = correlationID
        }

        var requestParameters: [String: Any] = [:]

        if let merchantAccountID = request?.merchantAccountID {
            requestParameters["merchant_account_id"] = merchantAccountID
        }

        requestParameters["paypal_account"] = paypalAccount

        let metadataParameters: [String: String] = [
            "source": apiClient.metadata.sourceString,
            "integration": apiClient.metadata.integrationString,
            "sessionId": apiClient.metadata.sessionID
        ]

        requestParameters["_meta"] = metadataParameters

        apiClient.post("/v1/payment_methods/paypal_accounts", parameters: requestParameters) { [weak self] body, response, error in
            guard let self else { return }

            if let error = error as? NSError {
                if error.code == BTCoreConstants.networkConnectionLostCode {
                    apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentNetworkConnectionLost)
                }

                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                merchantCompletion?(nil, error)
                return
            }

            guard let body else {
                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                merchantCompletion?(nil, BTLocalPaymentError.noAccountData)
                return
            }

            guard let tokenizedLocalPayment = BTLocalPaymentResult(json: body) else {
                apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                merchantCompletion?(nil, BTLocalPaymentError.failedToCreateNonce)
                return
            }

            apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentSucceeded)
            merchantCompletion?(tokenizedLocalPayment, nil)
        }
    }

    // MARK: - Private Methods

    private func start(request: BTLocalPaymentRequest, configuration: BTConfiguration) {
        var requestParameters: [String: Any] = [
            "amount": request.amount ?? "",
            "funding_source": request.paymentType ?? "",
            "intent": "sale",
            "return_url": "\(BTCoreConstants.callbackURLScheme)://x-callback-url/braintree/local-payment/success",
            "cancel_url": "\(BTCoreConstants.callbackURLScheme)://x-callback-url/braintree/local-payment/cancel"
        ]

        if let countryCode = request.paymentTypeCountryCode {
            requestParameters["payment_type_country_code"] = countryCode
        }

        if let address = request.address {
            requestParameters["line1"] = address.streetAddress
            requestParameters["line2"] = address.extendedAddress
            requestParameters["city"] = address.locality
            requestParameters["state"] = address.region
            requestParameters["postal_code"] = address.postalCode
            requestParameters["country_code"] = address.countryCodeAlpha2
        }

        if let currencyCode = request.currencyCode {
            requestParameters["currency_iso_code"] = currencyCode
        }

        if let givenName = request.givenName {
            requestParameters["first_name"] = givenName
        }

        if let surname = request.surname {
            requestParameters["last_name"] = surname
        }

        if let email = request.email {
            requestParameters["payer_email"] = email
        }

        if let phone = request.phone {
            requestParameters["phone"] = phone
        }

        if let merchantAccountID = request.merchantAccountID {
            requestParameters["merchant_account_id"] = merchantAccountID
        }

        if let bic = request.bic {
            requestParameters["bic"] = bic
        }

        var experienceProfile: [String: Any] = ["no_shipping": !request.isShippingAddressRequired]

        if let displayName = request.displayName {
            experienceProfile["brand_name"] = displayName
        }

        requestParameters["experience_profile"] = experienceProfile

        apiClient.post("v1/local_payments/create", parameters: requestParameters) { body, response, error in
            if let error = error as? NSError {
                if error.code == BTCoreConstants.networkConnectionLostCode {
                    self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentNetworkConnectionLost)
                }

                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                self.merchantCompletion?(nil, error)
                return
            }

            if let paymentID = body?["paymentResource"]["paymentToken"].asString(),
               let approvalURLString = body?["paymentResource"]["redirectUrl"].asString(),
               let url = URL(string: approvalURLString) {

                self.request?.localPaymentFlowDelegate?.localPaymentStarted(request, paymentID: paymentID) {
                    self.onPayment(with: url, error: error)
                }
            } else {
                NSLog("%@ Payment cannot be processed: the redirectUrl or paymentToken is nil.  Contact Braintree support if the error persists.", BTLogLevelDescription.string(for: .critical))
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                self.merchantCompletion?(nil, BTLocalPaymentError.appSwitchFailed)
                return
            }
        }
    }

    private func onPayment(with url: URL?, error: Error?) {
        if let error {
            apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
            merchantCompletion?(nil, error)
            return
        }

        guard let url else {
            apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
            merchantCompletion?(nil, BTLocalPaymentError.missingRedirectURL)
            return
        }

        webSessionReturned = false
        webAuthenticationSession.start(url: url, context: self) { url, error in
            if let error {
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                self.onPayment(with: nil, error: BTLocalPaymentError.webSessionError(error))
                return
            }

            if let url {
                self.handleOpen(url)
            } else {
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserLoginFailed)
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentFailed)
                self.onPayment(with: nil, error: BTLocalPaymentError.missingReturnURL)
            }
        } sessionDidAppear: { didAppear in
            if didAppear {
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserPresentationSucceeded)
            } else {
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserPresentationFailed)
            }
        } sessionDidCancel: {
            // User canceled by breaking out of the LocalPayment browser switch flow
            // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
            if !self.webSessionReturned {
                // User tapped system cancel button on permission alert
                self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.browserLoginAlertCanceled)
            }
            self.apiClient.sendAnalyticsEvent(BTLocalPaymentAnalytics.paymentCanceled)
            self.onPayment(with: nil, error: BTLocalPaymentError.canceled(self.request?.paymentType ?? ""))
            return
        }
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension BTLocalPaymentClient: ASWebAuthenticationPresentationContextProviding {
    
    @objc public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if #available(iOS 15, *) {
            let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = firstScene?.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        } else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        }
    }
}
