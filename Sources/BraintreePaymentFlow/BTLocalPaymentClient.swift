import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

// TODO: look through methods and rename / refactor as needed

@objcMembers public class BTLocalPaymentClient: NSObject {
    
    // MARK: - Internal Properties
    
    var authenticationSession: ASWebAuthenticationSession?
    
    // MARK: - Private Properties
    
    private let apiClient: BTAPIClient

    private var request: BTLocalPaymentRequest?
    private var merchantCompletion: ((BTLocalPaymentResult?, Error?) -> Void)? = nil

    // MARK: - Initializer

    /// Initialize a new `BTLocalPaymentClient` instance.
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    /// Starts a payment flow using a `BTLocalPaymentRequest`
    /// - Parameters:
    ///   - request: A `BTLocalPaymentRequest` request.
    ///   - completion: This completion will be invoked exactly once when the payment flow is complete or an error occurs.
    public func startPaymentFlow(_ request: BTLocalPaymentRequest, completion: @escaping (BTLocalPaymentResult?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent("ios.local-payment.start-payment.selected")

        self.request = request
        self.merchantCompletion = completion

        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else { return }

            if let error {
                completion(nil, error)
            }

            let dataCollector = BTDataCollector(apiClient: apiClient)
            request.correlationID = dataCollector.clientMetadataID(nil)

            guard let configuration else {
                completion(nil, BTLocalPaymentError.fetchConfigurationFailed)
                return
            }

            if !configuration.isLocalPaymentEnabled {
                NSLog("%@ Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments.", BTLogLevelDescription.string(for: .critical))
                completion(nil, BTLocalPaymentError.disabled)
                return
            } else if (request.localPaymentFlowDelegate == nil) {
                NSLog("%@ BTLocalPaymentRequest localPaymentFlowDelegate can not be nil.", BTLogLevelDescription.string(for: .critical))
                completion(nil, BTLocalPaymentError.integration)
                return
            } else if (request.amount == nil || (request.paymentType == nil)) {
                NSLog("%@ BTLocalPaymentRequest amount and paymentType can not be nil.", BTLogLevelDescription.string(for: .critical))
                completion(nil, BTLocalPaymentError.integration)
                return
            }

            start(request: request, configuration: configuration)
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

    func onPayment(with url: URL?, error: Error?) {
        if let error {
            apiClient.sendAnalyticsEvent("ios.local-payment.start-payment.failed")
            merchantCompletion?(nil, error)
            return
        }

        guard let url else {
            merchantCompletion?(nil, BTLocalPaymentError.missingRedirectURL)
            return
        }

        apiClient.sendAnalyticsEvent("ios.local-payment.webswitch.initiate.succeeded")

        authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: BTCoreConstants.callbackURLScheme) { callbackURL, error in
            // Required to avoid memory leak for BTPaymentFlowClient
            self.authenticationSession = nil

            // TODO: - Refactor similar to BTPayPalClient to handle distinct cancellations b/w system alert or system browser
            if let error = error as? NSError {
                if error.domain == ASWebAuthenticationSessionError.errorDomain,
                   error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                    self.apiClient.sendAnalyticsEvent("ios.local-payment.authsession.browser.cancel")
                }

                self.merchantCompletion?(nil, BTLocalPaymentError.canceled(self.request?.paymentType ?? "unknown"))
                return
            }

            if let callbackURL {
                self.apiClient.sendAnalyticsEvent("ios.local-payment.webswitch.succeeded")
                self.handleOpen(callbackURL)
            } else {
                self.merchantCompletion?(nil, BTLocalPaymentError.missingReturnURL)
            }
        }

        authenticationSession?.presentationContextProvider = self
        authenticationSession?.start()
    }

    func handleOpen(_ url: URL) {
        if url.host == "x-callback-url" && url.path.hasPrefix("/braintree/local-payment/cancel") {
            // canceled case
            merchantCompletion?(nil, BTLocalPaymentError.canceled(request?.paymentType ?? "unknown"))

        } else {
            // success case
            var params: [String: Any] = [:]

            var paypalAccount: [String: Any] = [:]
            paypalAccount["response"] = ["webURL": url.absoluteString]
            paypalAccount["response_type"] = "web"
            paypalAccount["options"] = ["validate": false]
            paypalAccount["intent"] = "sale"

            if let correlationID = request?.correlationID {
                paypalAccount["correlation_id"] = correlationID
            }

            if let merchantAccountID = request?.merchantAccountID {
                params["merchant_account_id"] = merchantAccountID
            }

            params["paypal_account"] = paypalAccount

            let metadataParameters: [String: String] = [
                "source": apiClient.metadata.sourceString,
                "integration": apiClient.metadata.integrationString,
                "sessionId": apiClient.metadata.sessionID
            ]

            params["_meta"] = metadataParameters

            apiClient.post("/v1/payment_methods/paypal_accounts", parameters: params, completion: { [weak self] body, response, error in
                guard let self else { return }

                if let error = error as? NSError {
                    if error.code == BTCoreConstants.networkConnectionLostCode {
                        apiClient.sendAnalyticsEvent("ios.local-payment-methods.network-connection.failure")
                    }

                    merchantCompletion?(nil, error)
                    return
                } else {
                    guard let body else {
                        merchantCompletion?(nil, BTLocalPaymentError.noAccountData)
                        return
                    }

                    guard let tokenizedLocalPayment = BTLocalPaymentResult(json: body) else {
                        merchantCompletion?(nil, BTLocalPaymentError.failedToCreateNonce)
                        return
                    }

                    merchantCompletion?(tokenizedLocalPayment, nil)
                }
            })
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

        var experienceProfile: [String: Any] = [
            "no_shipping": !request.isShippingAddressRequired,
        ]

        if let displayName = request.displayName {
            experienceProfile["brand_name"] = displayName
        }

        requestParameters["experience_profile"] = experienceProfile

        apiClient.post("v1/local_payments/create", parameters: requestParameters) { body, response, error in
            if let error {
                if (error as NSError).code == BTCoreConstants.networkConnectionLostCode {
                    self.apiClient.sendAnalyticsEvent("ios.local-payment-methods.network-connection.failure")
                }

                self.onPayment(with: nil, error: error)
                return
            }

            if let paymentID = body?["paymentResource"]["paymentToken"].asString(),
               let approvalURLString = body?["paymentResource"]["redirectUrl"].asString(),
               let url = URL(string: approvalURLString) {

                self.request?.localPaymentFlowDelegate?.localPaymentStarted(request, paymentID: paymentID, start: {
                    self.onPayment(with: url, error: error)
                })
            } else {
                NSLog("%@ Payment cannot be processed: the redirectUrl or paymentToken is nil.  Contact Braintree support if the error persists.", BTLogLevelDescription.string(for: .critical))
                self.merchantCompletion?(nil, BTLocalPaymentError.appSwitchFailed)
                return
            }
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