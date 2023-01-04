import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

@objcMembers public class BTPayPalClientSwift: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    // MARK: - Internal Properties
    
    /// Exposed for testing the approvalURL construction
    var approvalURL: URL? = nil
    
    ///Exposed for testing to get the instance of BTAPIClient
    let apiClient: BTAPIClient
    
    /// Exposed for testing the clientMetadataID associated with this request
    var clientMetadataID: String? = nil
    
    /// Exposed for testing the intent associated with this request
    var payPalRequest: BTPayPalRequest? = nil
    
    /// Exposed for testing, the ASWebAuthenticationSession instance used for the PayPal flow
    var authenticationSession: ASWebAuthenticationSession? = nil
    
    /// Exposed for testing, for determining if ASWebAuthenticationSession was started
    var isAuthenticationSessionStarted: Bool = false
    
    // MARK: - Private Properties
    
    var returnedToAppAfterPermissionAlert: Bool = false

    /// Initialize a new PayPal client instance.
    /// - Parameter apiClient: The API Client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Public Methods
    
    /// Tokenize a PayPal account for vault or checkout.
    ///
    /// @note You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
    /// server when this method completes without any additional user interaction.
    ///
    /// On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error.
    /// If the user cancels outof the flow, the error code will be `BTPayPalClientErrorTypeCanceled`.
    ///
    /// - Parameters:
    ///   - request: Either a BTPayPalCheckoutRequest or a BTPayPalVaultRequest
    ///   - completion: This completion will be invoked exactly once when tokenization is complete or an error occurs.
    @objc(tokenizePayPalAccountWithPayPalRequest:completion:)
    public func tokenizePayPalAccount(
        with request: BTPayPalRequest?,
        completion: @escaping (BTPayPalAccountNonce?, NSError?) -> Void
    ) {
        guard let request else {
            completion(nil, NSError(domain: BTPayPalErrorDomain, code: BTPayPalErrorType.invalidRequest.rawValue))
            return
        }
        
        guard let requestTokenizable = request as? BTPayPalRequestTokenizable else {
            let error = NSError(
                domain: BTPayPalErrorDomain,
                code: BTPayPalErrorType.integration.rawValue,
                userInfo: [
                    NSLocalizedDescriptionKey: "BTPayPalClient failed because request is not of type BTPayPalCheckoutRequest or BTPayPalVaultRequest."
                ]
            )
            completion(nil, error)
            return
        }
        
        self.apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error = error as? NSError { // TODO: Notice this whole class uses NSError but BTAPIClient uses Error
                completion(nil, error)
                return
            }
            
            guard let configuration = configuration,
                  let json = configuration.json else {
                completion(nil, nil) // TODO: What is this error?
                return
            }
            
            do {
                guard try self.verifyAppSwitch(remoteConfiguration: json) else {
                    // TODO: In Objc an error response is also a false response
                    completion(nil, NSError(domain: BTPayPalErrorDomain, code: BTPayPalErrorType.unknown.rawValue))
                    return
                }
            } catch {
                completion(nil, error as NSError)
                return
            }
            
            self.payPalRequest = request
            
            // TODO: could we pass in a function to the closure instead of doing it inline?
            // Doing so could increase readability by reducing the line count in this function and removing some nested
            // logic
            self.apiClient.post(
                requestTokenizable.hermesPath,
                parameters: requestTokenizable.parameters(with: configuration)
            ) { body, response, error in
                if let error = error as? NSError {
                    if error.code == BTCoreConstants.networkConnectionLostCode {
                        self.apiClient.sendAnalyticsEvent("ios.paypal.tokenize.network-connection.failure")
                    }
                    guard let jsonResponseBody = error.userInfo[BTHTTPError.jsonResponseBodyKey] as? BTJSON else {
                        let completionError = NSError(
                            domain: BTPayPalErrorDomain,
                            code: BTPayPalErrorSwift.unknown.rawValue,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unexpected state, failed to parse JSON from POST error in Tokenize request",
                                NSLocalizedRecoverySuggestionErrorKey: "Try again or contact Braintree Support."
                            ]
                        )
                        completion(nil, completionError)
                        return
                    }
                    
                    let errorDetailsIssue = jsonResponseBody["paymentResource"]["errorDetails"][0]["issue"]
                    var dictionary = error.userInfo
                    dictionary[NSLocalizedDescriptionKey] = errorDetailsIssue
                    let completionError = NSError(
                        domain: error.domain,
                        code: error.code,
                        userInfo: dictionary
                    )
                    completion(nil, completionError)
                    return
                }

                guard let body,
                      var approvalURL = body["paymentResource"]["redirectUrl"].asURL() ??
                        body["agreementSetup"]["approvalUrl"].asURL() else {
                    let completionError = NSError(
                        domain: BTPayPalErrorDomain,
                        code: BTPayPalErrorSwift.unknown.rawValue,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unexpected state, failed to parse approvalUrl or redirectUrl from response body.",
                            NSLocalizedRecoverySuggestionErrorKey: "Try again or contact Braintree Support."
                        ]
                    )
                    completion(nil, completionError)
                    return
                }
                
                approvalURL = self.decorate(approvalURL: approvalURL, for: request)

                let pairingID = Self.token(from: approvalURL)
                
                let dataCollector = BTDataCollector(apiClient: self.apiClient)
                self.clientMetadataID = self.payPalRequest?.riskCorrelationId ??
                                        dataCollector.clientMetadataID(pairingID)
                
                self.sendAnalyticsEventForInitiatingOneTouch(
                    paymentType: requestTokenizable.paymentType,
                    success: error == nil
                )
                
                self.handlePayPalRequest(
                    with: approvalURL,
                    error: nil,
                    paymentType: requestTokenizable.paymentType,
                    completion: completion
                )
            }
        }
    }
    
    // MARK: - Internal Methods
    
    func applicationDidBecomeActive(notification: Notification) {
        if self.isAuthenticationSessionStarted {
            self.returnedToAppAfterPermissionAlert = true
        }
    }
    
    func handlePayPalRequest(
        with url: URL,
        error: NSError?,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, NSError?)->Void
    ) {
        if let error {
            completion(nil, error)
            return
        }
        
        if let scheme = url.scheme,
           !scheme.lowercased().hasPrefix("http") {
            let urlError = NSError(
                domain: BTPayPalErrorDomain,
                code: BTPayPalErrorSwift.unknown.rawValue,
                userInfo: [
                    NSLocalizedDescriptionKey: "Attempted to open an invalid URL in ASWebAuthenticationSession: \(scheme)://",
                    NSLocalizedRecoverySuggestionErrorKey: "Try again or contact Braintree Support."
                ]
            )
            
            let eventName = "ios.\(paymentType.string).webswitch.error.safariviewcontrollerbadscheme.\(scheme)"
            self.apiClient.sendAnalyticsEvent(eventName)
                        
            completion(nil, urlError)
            return
        }
        performSwitchRequest(
            appSwitchURL: url,
            paymentType: paymentType,
            completion: completion
        )
    }
    
    // TODO: Make an extension on URL? See usage in tokenizePayPalAccount
    func decorate(
        approvalURL: URL,
        for request: BTPayPalRequest
    ) -> URL {
        guard let request = payPalRequest as? BTPayPalCheckoutRequest,
              var approvalURLComponents = URLComponents(url: approvalURL, resolvingAgainstBaseURL: false) else {
            return approvalURL
        }
        let userActionValue = request.userActionAsString
        guard userActionValue.count > 0 else {
            return approvalURL
        }
        
        let userActionQueryItem = URLQueryItem(
            name: "useraction",
            value: userActionValue
        )
        var queryItems = approvalURLComponents.queryItems ?? []
        queryItems.append(userActionQueryItem)
        approvalURLComponents.queryItems = queryItems
        
        return approvalURLComponents.url ?? approvalURL
    }
    
    // MARK: - Private Methods
    
    private func performSwitchRequest(
        appSwitchURL: URL,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, NSError?) -> Void
    ) {
        self.approvalURL = appSwitchURL
        self.authenticationSession = ASWebAuthenticationSession(
            url: appSwitchURL,
            callbackURLScheme: BTPayPalRequest.callbackURLScheme) { callbackURL, error in
                self.authenticationSession = nil
                if let error = error as? NSError {
                    if error.domain == ASWebAuthenticationSessionError.errorDomain,
                       error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        if self.returnedToAppAfterPermissionAlert {
                            // User tapped system cancel button in browser
                            let eventName = "ios.\(paymentType.string).authsession.browser.cancel"
                            self.apiClient.sendAnalyticsEvent(eventName)
                        } else {
                            // User tapped system cancel button on permission alert
                            let eventName = "ios.\(paymentType.string).authsession.alert.cancel"
                            self.apiClient.sendAnalyticsEvent(eventName)
                        }
                    }
                    
                    // User canceled by breaking out of the PayPal browser switch flow
                    // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
                    let err = NSError(
                        domain: BTPayPalErrorDomain,
                        code: BTPayPalErrorType.canceled.rawValue,
                        userInfo: [NSLocalizedDescriptionKey: "PayPal flow was canceled by the user."]
                    )
                    completion(nil, err)
                    return
                }
                self.handleBrowserSwitchReturn(
                    url: callbackURL,
                    paymentType: paymentType,
                    completion: completion
                )
            }
        
        self.authenticationSession?.presentationContextProvider = self
        self.returnedToAppAfterPermissionAlert = false
        self.isAuthenticationSessionStarted = self.authenticationSession?.start() ?? false
        
        if self.isAuthenticationSessionStarted {
            self.apiClient.sendAnalyticsEvent("ios.\(paymentType.string).authsession.start.succeeded")
        } else {
            self.apiClient.sendAnalyticsEvent("ios.\(paymentType.string).authsession.start.failed")
        }
    }
    
    private func handleBrowserSwitchReturn(
        url: URL?,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, NSError?) -> Void
    ) {
        guard let url, Self.isValidURLAction(url: url) else {
            let error = NSError(domain: BTPayPalErrorDomain,
                                code: BTPayPalErrorSwift.unknown.rawValue,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Unexpected response"
                                ])
            completion(nil, error)
            return
        }
        
        guard let response = Self.responseDictionary(from: url) else {
            let error = NSError(
                domain: BTPayPalErrorDomain,
                code: BTPayPalErrorSwift.canceled.rawValue,
                userInfo: [
                    NSLocalizedDescriptionKey: "PayPal flow was canceled by the user."
                ]
            )
            completion(nil, error)
            return
        }
        var parameters: [String: Any] = [
            "paypal_account": response
        ]
        
        var account: [String: Any] = [:]
        
        if paymentType == .checkout {
            account["options"] = ["validate": false]
            if let request  = payPalRequest as? BTPayPalCheckoutRequest {
                account["intent"] = request.intentAsString
            }
        }
        
        if let clientMetadataID {
            account["correlation_id"] = clientMetadataID
        }
        
        if let payPalRequest,
           let merchantAccountID = payPalRequest.merchantAccountID {
            parameters["merchant_account_id"] = merchantAccountID
        }
        
        if !account.isEmpty {
            parameters["paypal_account"] = account
        }
        
        let metadata = self.apiClient.metadata
        metadata.source = .payPalBrowser
        
        parameters["_meta"] = [
            "source": metadata.sourceString,
            "integration": metadata.integrationString,
            "sessionId": metadata.sessionID
        ]
        
        self.apiClient.post("/v1/payment_methods/paypal_accounts") { body, response, error in
            if let error = error as? NSError {
                if error.code == BTCoreConstants.networkConnectionLostCode {
                    self.apiClient.sendAnalyticsEvent("ios.paypal.handle-browser-switch.network-connection.failure")
                }
                self.sendAnalyticsEventForTokenizationFailure(paymentType: paymentType)
                completion(nil, error)
                return
            }
            self.sendAnalyticsEventForTokenizationFailure(paymentType: paymentType)
            
            guard let paypalAccount = body?["paypayAccounts"].asArray()?.first,
                  let tokenizedAccount = self.payPalAccount(from: paypalAccount) else {
                let completionError = NSError(
                    domain: BTPayPalErrorDomain,
                    code: BTPayPalErrorSwift.unknown.rawValue,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unexpected state, failed to parse JSON from POST error in Tokenize request",
                        NSLocalizedRecoverySuggestionErrorKey: "Try again or contact Braintree Support."
                    ]
                )
                 completion(nil, completionError)
                return
            }
            self.sendAnalyticsEventIfCreditFinancing(
                in: tokenizedAccount,
                paymentType: paymentType
            )
            completion(tokenizedAccount, nil)
        }
    }
    
    // MARK: - Analytics Helpers
    
    private func sendAnalyticsEventIfCreditFinancing(
        in nonce: BTPayPalAccountNonce,
        paymentType: BTPayPalPaymentType
    ) {
        if nonce.creditFinancing != nil {
            self.apiClient.sendAnalyticsEvent("ios.\(paymentType.string).credit.accepted")
        }
    }
    
    private func sendAnalyticsEventForTokenizationFailure(paymentType: BTPayPalPaymentType) {
        self.apiClient.sendAnalyticsEvent("ios.\(paymentType.string).tokenize.failed")
    }
    
    private func sendAnalyticsEventForInitiatingOneTouch(paymentType: BTPayPalPaymentType, success: Bool) {
        let successString = success ? "started" : "failed"
        
        self.apiClient.sendAnalyticsEvent("ios.\(paymentType.string).webswitch.initiate.\(successString)")
        
        if let checkoutRequest = self.payPalRequest as? BTPayPalCheckoutRequest,
           checkoutRequest.offerPayLater {
            self.apiClient.sendAnalyticsEvent("ios.\(paymentType.string).webswitch.paylater.offered.\(successString)")
        }
        
        if let vaultRequest = self.payPalRequest as? BTPayPalVaultRequest,
           vaultRequest.offerCredit {
            self.apiClient.sendAnalyticsEvent("ios.\(paymentType.string).webswitch.credit.offered.\(successString)")
        }
    }
    
    // TODO: remove
    private func payPalAccount(from json: BTJSON) -> BTPayPalAccountNonce? {
        return BTPayPalAccountNonce(json: json)
    }
    
    // MARK: - ASWebAuthenticationPresentationContextProviding protocol
    
    // TODO: - Unavailable for extension
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let activeWindow = self.payPalRequest?.activeWindow {
            return activeWindow
        }
        
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive,
               let windowScene = scene as? UIWindowScene,
               let window = windowScene.windows.first {
                return window
            }
        }
        
        if #available(iOS 15, *),
           let firstConnectedScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let result = firstConnectedScene.windows.first {
            return result
        } else {
            return UIApplication.shared.windows.first! // TODO: - How to fail here if nil?
        }
    }
    
    // MARK: - Preflight Check
    
    private func verifyAppSwitch(remoteConfiguration configuration: BTJSON) throws -> Bool {
        guard configuration["payPalEnabled"].isTrue else {
            self.apiClient.sendAnalyticsEvent("ios.paypal-otc.preflight.disabled")
            throw NSError(domain: BTPayPalErrorDomain,
                          code: BTPayPalErrorSwift.disabled.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey : "PayPal is not enabled for this merchant",
                NSLocalizedRecoverySuggestionErrorKey: "Enable PayPal for this merchant in the Braintree Control Panel"
            ])
        }
        return true
    }
    
    // MARK: - Private Static Helper Methods
    
    // TODO: Confirm optionality of return type in actual use.
    private static func token(from approvalURL: URL) -> String? {
        let queryDictionary: [String: String]
        if #available(iOS 16, *) {
            guard let query = approvalURL.query(percentEncoded: false) else {
                return nil
            }
            queryDictionary = parse(queryString: query)
        } else {
            guard let query = approvalURL.query else {
                return nil
            }
            queryDictionary = parse(queryString: query)
        }
        return queryDictionary["token"] ?? queryDictionary["ba_token"]
    }
    
    private static func parse(queryString query: String) -> [String: String] {
        var dict = [String: String]()
        let pairs = query.components(separatedBy: "&")
        
        for pair in pairs {
            let elements = pair.components(separatedBy: "=")
            if elements.count > 1,
               let key = elements[0].removingPercentEncoding, // TODO: removingPercentEncoding will be unneccessary in iOS16
               let value = elements[1].removingPercentEncoding, // TODO: ditto above
               !key.isEmpty,
               !value.isEmpty {
                dict[key] = value
            }
        }
        return dict
    }
    
    private static func isValidURLAction(url: URL) -> Bool {
        guard let host = url.host, let scheme = url.scheme, !scheme.isEmpty else {
            return false
        }
        
        var hostAndPath = host
            .appending(url.path)
            .components(separatedBy: "/")
            .dropLast(1) // remove the action (`success`, `cancel`, etc)
            .joined(separator: "/")
        if hostAndPath.count > 0 {
            hostAndPath.append("/") // TODO: is this only necessary if count > 0?
        }
        
        if hostAndPath == BTPayPalRequest.callbackURLHostAndPath {
            return false
        }
        
        // TODO: Is the action method redundant? We could grab the action when initializing hostAndPath.
        guard let action = action(from: url),
              let query = url.query,   // TODO: query to be deprecated
              query.count > 0,
              action.count <= 0,
              ["success", "cancel", "authenticate"].contains(action) else {
            return false
        }
        
        return true
    }
    
    private static func responseDictionary(from url: URL) -> [String : Any]? {
        if let action = action(from: url), action == "cancel" {
            return nil
        }
        
        let result: [String: Any] = [
            "client": [
                "platform": "iOS",
                "product_name": "PayPal",
                "paypal_sdk_version": "version"
            ],
            "response": [
                "webURL": url.absoluteString
            ],
            "response_type": "w"
        ]
        
        return result
    }
    
    private static func action(from url: URL) -> String? {
        guard let action = url.lastPathComponent.components(separatedBy: "?").first,
           action.isEmpty else {
            return url.host
        }
        return action
    }
}
