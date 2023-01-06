import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

@objcMembers public class BTPayPalClient: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    // MARK: - Internal Properties

    ///Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient
    
    /// Exposed for testing the approvalURL construction
    var approvalURL: URL? = nil

    /// Exposed for testing the clientMetadataID associated with this request
    var clientMetadataID: String? = nil
    
    /// Exposed for testing the intent associated with this request
    var payPalRequest: BTPayPalRequest? = nil

    /// Exposed for testing, the ASWebAuthenticationSession instance used for the PayPal flow
    var authenticationSession: ASWebAuthenticationSession? = nil
    
    /// Exposed for testing, for determining if ASWebAuthenticationSession was started
    var isAuthenticationSessionStarted: Bool = false
    
    // MARK: - Private Properties

    private var returnedToAppAfterPermissionAlert: Bool = false

    // MARK: - Initializer

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
    /// - Note: You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
    /// server when this method completes without any additional user interaction.
    ///
    /// On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error.
    /// If the user cancels out of the flow, the error code will be `.canceled`.
    ///
    /// - Parameters:
    ///   - request: Either a `BTPayPalCheckoutRequest` or a `BTPayPalVaultRequest`
    ///   - completion: This completion will be invoked exactly once when tokenization is complete or an error occurs.
    @objc(tokenizePayPalAccountWithPayPalRequest:completion:)
    public func tokenizePayPalAccount(
        with request: BTPayPalRequest & BTPayPalRequestable,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                completion(nil, error)
                return
            }
            
            guard let configuration, let json = configuration.json else {
                completion(nil, BTPayPalError.fetchConfigurationFailed)
                return
            }
            
            guard json["paypalEnabled"].isTrue else {
                self.apiClient.sendAnalyticsEvent("ios.paypal-otc.preflight.disabled")
                completion(nil, BTPayPalError.disabled)
                return
            }
            
            self.payPalRequest = request
            
            // TODO: could we pass in a function to the closure instead of doing it inline?
            // Doing so could increase readability by reducing the line count in this function and removing some nested
            // logic
            self.apiClient.post(request.hermesPath, parameters: request.parameters(with: configuration)) { body, response, error in
                if let error = error as? NSError {
                    if error.code == BTCoreConstants.networkConnectionLostCode {
                        self.apiClient.sendAnalyticsEvent("ios.paypal.tokenize.network-connection.failure")
                    }

                    guard let jsonResponseBody = error.userInfo[BTHTTPError.jsonResponseBodyKey] as? BTJSON else {
                        completion(nil, BTPayPalError.httpResponseMissingUserInfoJSON)
                        return
                    }
                    
                    let errorDetailsIssue = jsonResponseBody["paymentResource"]["errorDetails"][0]["issue"]
                    var dictionary = error.userInfo
                    dictionary[NSLocalizedDescriptionKey] = errorDetailsIssue
                    completion(nil, BTPayPalError.httpPostRequestError(dictionary))
                    return
                }

                guard let body,
                      var approvalURL = body["paymentResource"]["redirectUrl"].asURL() ??
                        body["agreementSetup"]["approvalUrl"].asURL() else {
                    completion(nil, BTPayPalError.invalidURL)
                    return
                }
                
                approvalURL = self.decorate(approvalURL: approvalURL, for: request)

                let pairingID = Self.token(from: approvalURL)
                let dataCollector = BTDataCollector(apiClient: self.apiClient)
                self.clientMetadataID = self.payPalRequest?.riskCorrelationId ?? dataCollector.clientMetadataID(pairingID)
                self.sendAnalyticsEventForInitiatingOneTouch(paymentType: request.paymentType, success: error == nil)
                self.handlePayPalRequest(with: approvalURL, error: nil, paymentType: request.paymentType, completion: completion)
            }
        }
    }
    
    // MARK: - Internal Methods
    
    func applicationDidBecomeActive(notification: Notification) {
        returnedToAppAfterPermissionAlert = isAuthenticationSessionStarted ? true : false
    }
    
    func handlePayPalRequest(
        with url: URL,
        error: Error?,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?)->Void
    ) {
        if let error {
            completion(nil, error)
            return
        }
        
        if let scheme = url.scheme, !scheme.lowercased().hasPrefix("http") {
            let eventName = "ios.\(paymentType.string).webswitch.error.safariviewcontrollerbadscheme.\(scheme)"
            apiClient.sendAnalyticsEvent(eventName)
                        
            completion(nil, BTPayPalError.asWebAuthenticationSessionURLInvalid(scheme))
            return
        }
        performSwitchRequest(appSwitchURL: url, paymentType: paymentType, completion: completion)
    }
    
    // TODO: Make an extension on URL? See usage in tokenizePayPalAccount
    func decorate(approvalURL: URL, for request: BTPayPalRequest) -> URL {
        guard let request = payPalRequest as? BTPayPalCheckoutRequest,
              var approvalURLComponents = URLComponents(url: approvalURL, resolvingAgainstBaseURL: false) else {
            return approvalURL
        }

        let userActionValue = request.userAction?.stringValue ?? ""
        guard userActionValue.count > 0 else {
            return approvalURL
        }
        
        let userActionQueryItem = URLQueryItem(name: "useraction", value: userActionValue)
        var queryItems = approvalURLComponents.queryItems ?? []
        queryItems.append(userActionQueryItem)
        approvalURLComponents.queryItems = queryItems
        
        return approvalURLComponents.url ?? approvalURL
    }

    // TODO: Should this be moved to public section?
    @objc(handleBrowserSwitchReturnURL:paymentType:completion:)
    public func handleBrowserSwitchReturn(
        _ url: URL?,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        guard let url, Self.isValidURLAction(url: url) else {
            completion(nil, BTPayPalError.invalidURLAction)
            return
        }
        
        guard let response = Self.responseDictionary(from: url) else {
            completion(nil, BTPayPalError.canceled)
            return
        }

        var parameters: [String: Any] = ["paypal_account": response]
        var account: [String: Any] = [:]
        
        if paymentType == .checkout {
            account["options"] = ["validate": false]
            if let request  = payPalRequest as? BTPayPalCheckoutRequest {
                account["intent"] = request.intent?.stringValue
            }
        }
        
        if let clientMetadataID {
            account["correlation_id"] = clientMetadataID
        }
        
        if let payPalRequest, let merchantAccountID = payPalRequest.merchantAccountID {
            parameters["merchant_account_id"] = merchantAccountID
        }
        
        if !account.isEmpty {
            parameters["paypal_account"] = account
        }
        
        let metadata = apiClient.metadata
        metadata.source = .payPalBrowser
        
        parameters["_meta"] = [
            "source": metadata.sourceString,
            "integration": metadata.integrationString,
            "sessionId": metadata.sessionID
        ]
        
        apiClient.post("/v1/payment_methods/paypal_accounts", parameters: parameters) { body, response, error in
            if let error = error as? NSError {
                if error.code == BTCoreConstants.networkConnectionLostCode {
                    self.apiClient.sendAnalyticsEvent("ios.paypal.handle-browser-switch.network-connection.failure")
                }

                self.sendAnalyticsEventForTokenizationFailure(paymentType: paymentType)
                completion(nil, error)
                return
            }

            self.sendAnalyticsEventForTokenizationFailure(paymentType: paymentType)
            
            guard let payPalAccount = body?["paypalAccounts"].asArray()?.first,
                  let tokenizedAccount = BTPayPalAccountNonce(json: payPalAccount) else {
                completion(nil, BTPayPalError.failedToCreateNonce)
                return
            }

            self.sendAnalyticsEventIfCreditFinancing(in: tokenizedAccount,paymentType: paymentType)
            completion(tokenizedAccount, nil)
        }
    }

    // MARK: - Private Methods
    
    private func performSwitchRequest(
        appSwitchURL: URL,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        approvalURL = appSwitchURL
        authenticationSession = ASWebAuthenticationSession(
            url: appSwitchURL,
            callbackURLScheme: BTPayPalRequest.callbackURLScheme
        ) { callbackURL, error in
                self.authenticationSession = nil
                if let error = error as? NSError {
                    if error.domain == ASWebAuthenticationSessionError.errorDomain,
                       error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        if self.returnedToAppAfterPermissionAlert == true {
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
                    completion(nil, BTPayPalError.canceled)
                    return
                }

                self.handleBrowserSwitchReturn(callbackURL, paymentType: paymentType, completion: completion)
            }
        
        authenticationSession?.presentationContextProvider = self
        returnedToAppAfterPermissionAlert = false
        isAuthenticationSessionStarted = authenticationSession?.start() ?? false

        let authenticationSessionStatus = isAuthenticationSessionStarted ? "succeeded" : "failed"
        apiClient.sendAnalyticsEvent("ios.\(paymentType.string).authsession.start.\(authenticationSessionStatus)")
    }
    
    // MARK: - Analytics Helpers
    
    private func sendAnalyticsEventIfCreditFinancing(in nonce: BTPayPalAccountNonce, paymentType: BTPayPalPaymentType) {
        if nonce.creditFinancing != nil {
            apiClient.sendAnalyticsEvent("ios.\(paymentType.string).credit.accepted")
        }
    }
    
    private func sendAnalyticsEventForTokenizationFailure(paymentType: BTPayPalPaymentType) {
        apiClient.sendAnalyticsEvent("ios.\(paymentType.string).tokenize.failed")
    }
    
    private func sendAnalyticsEventForInitiatingOneTouch(paymentType: BTPayPalPaymentType, success: Bool) {
        let successString = success ? "started" : "failed"
        
        apiClient.sendAnalyticsEvent("ios.\(paymentType.string).webswitch.initiate.\(successString)")
        
        if let checkoutRequest = payPalRequest as? BTPayPalCheckoutRequest,
           checkoutRequest.offerPayLater {
            apiClient.sendAnalyticsEvent("ios.\(paymentType.string).webswitch.paylater.offered.\(successString)")
        }
        
        if let vaultRequest = payPalRequest as? BTPayPalVaultRequest, vaultRequest.offerCredit {
            apiClient.sendAnalyticsEvent("ios.\(paymentType.string).webswitch.credit.offered.\(successString)")
        }
    }
    
    // MARK: - ASWebAuthenticationPresentationContextProviding protocol
    
    // TODO: - NS_EXTENSION_UNAVAILABLE
    // "Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions."
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let activeWindow = payPalRequest?.activeWindow {
            return activeWindow
        }
        
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive,
               let windowScene = scene as? UIWindowScene,
               let window = windowScene.windows.first {
                return window
            }
        }
        
        if #available(iOS 15, *) {
            let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = firstScene?.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        } else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        }
    }
    
    // MARK: - Private Static Helper Methods
    
    private static func token(from approvalURL: URL) -> String {
        guard let query = approvalURL.query else { return "" }
        let queryDictionary = parse(queryString: query)
        
        return queryDictionary["token"] ?? queryDictionary["ba_token"] ?? ""
    }
    
    private static func parse(queryString query: String) -> [String: String] {
        var dict = [String: String]()
        let pairs = query.components(separatedBy: "&")
        
        for pair in pairs {
            let elements = pair.components(separatedBy: "=")
            if elements.count > 1,
               let key = elements[0].removingPercentEncoding,
               let value = elements[1].removingPercentEncoding,
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
        
        if hostAndPath != BTPayPalRequest.callbackURLHostAndPath {
            return false
        }

        guard let action = action(from: url),
              let query = url.query,
              query.count > 0,
              action.count >= 0,
              ["success", "cancel", "authenticate"].contains(action) else {
            return false
        }
        
        return true
    }
    
    private static func responseDictionary(from url: URL) -> [String : Any]? {
        if let action = action(from: url), action == "cancel" {
            return nil
        }
        
        return [
            "client": [
                "platform": "iOS",
                "product_name": "PayPal",
                "paypal_sdk_version": "version"
            ],
            "response": [
                "webURL": url.absoluteString
            ],
            "response_type": "web"
        ]
    }
    
    private static func action(from url: URL) -> String? {
        guard let action = url.lastPathComponent.components(separatedBy: "?").first,
           !action.isEmpty else {
            return url.host
        }

        return action
    }
}
