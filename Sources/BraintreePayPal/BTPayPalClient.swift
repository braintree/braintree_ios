import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

@objc public class BTPayPalClient: NSObject {
    
    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
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

    /// Tokenize a PayPal request to be used with the PayPal Vault flow.
    ///
    /// - Note: You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
    /// server when this method completes without any additional user interaction.
    ///
    /// On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error.
    /// If the user cancels out of the flow, the error code will be `.canceled`.
    ///
    /// - Parameters:
    ///   - request: A `BTPayPalVaultRequest`
    ///   - completion: This completion will be invoked exactly once when tokenization is complete or an error occurs.
    @objc(tokenizeWithVaultRequest:completion:)
    public func tokenize(
        _ request: BTPayPalVaultRequest,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        tokenize(request: request, completion: completion)
    }

    /// Tokenize a PayPal request to be used with the PayPal Vault flow.
    ///
    /// - Note: You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
    /// server when this method completes without any additional user interaction.
    ///
    /// On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error.
    /// If the user cancels out of the flow, the error code will be `.canceled`.
    ///
    /// - Parameter request: A `BTPayPalVaultRequest`
    /// - Returns: A `BTPayPalAccountNonce` if successful
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ request: BTPayPalVaultRequest) async throws -> BTPayPalAccountNonce {
        try await withCheckedThrowingContinuation { continuation in
            tokenize(request) { nonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let nonce {
                    continuation.resume(returning: nonce)
                }
            }
        }
    }

    /// Tokenize a PayPal request to be used with the PayPal Checkout or Pay Later flow.
    ///
    /// - Note: You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
    /// server when this method completes without any additional user interaction.
    ///
    /// On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error.
    /// If the user cancels out of the flow, the error code will be `.canceled`.
    ///
    /// - Parameters:
    ///   - request: A `BTPayPalCheckoutRequest`
    ///   - completion: This completion will be invoked exactly once when tokenization is complete or an error occurs.
    @objc(tokenizeWithCheckoutRequest:completion:)
    public func tokenize(
        _ request: BTPayPalCheckoutRequest,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        tokenize(request: request, completion: completion)
    }

    /// Tokenize a PayPal request to be used with the PayPal Checkout or Pay Later flow.
    ///
    /// - Note: You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
    /// server when this method completes without any additional user interaction.
    ///
    /// On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error.
    /// If the user cancels out of the flow, the error code will be `.canceled`.
    ///
    /// - Parameter request: A `BTPayPalCheckoutRequest`
    /// - Returns: A `BTPayPalAccountNonce` if successful
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ request: BTPayPalCheckoutRequest) async throws -> BTPayPalAccountNonce {
        try await withCheckedThrowingContinuation { continuation in
            tokenize(request) { nonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let nonce {
                    continuation.resume(returning: nonce)
                }
            }
        }
    }
    
    // MARK: - Internal Methods
    
    func handleBrowserSwitchReturn(
        _ url: URL?,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        guard let url, isValidURLAction(url: url) else {
            self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
            completion(nil, BTPayPalError.invalidURLAction)
            return
        }
        
        guard let response = responseDictionary(from: url) else {
            self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserLoginCanceled)
            completion(nil, BTPayPalError.canceled)
            return
        }
        
        var parameters: [String: Any] = ["paypal_account": response]
        var account: [String: Any] = [:]
        
        if paymentType == .checkout {
            account["options"] = ["validate": false]
            if let request  = payPalRequest as? BTPayPalCheckoutRequest {
                account["intent"] = request.intent.stringValue
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
                    self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeNetworkConnectionFailed)
                }

                self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
                completion(nil, error)
                return
            }

            guard let payPalAccount = body?["paypalAccounts"].asArray()?.first,
                  let tokenizedAccount = BTPayPalAccountNonce(json: payPalAccount) else {
                self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
                completion(nil, BTPayPalError.failedToCreateNonce)
                return
            }

            self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeSucceeded)
            completion(tokenizedAccount, nil)
        }
    }
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        returnedToAppAfterPermissionAlert = isAuthenticationSessionStarted
    }
    
    func handlePayPalRequest(
        with url: URL,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        // Defensive programming in case PayPal returns a non-HTTP URL so that ASWebAuthenticationSession doesn't crash
        if let scheme = url.scheme, !scheme.lowercased().hasPrefix("http") {
            apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
            completion(nil, BTPayPalError.asWebAuthenticationSessionURLInvalid(scheme))
            return
        }
        performSwitchRequest(appSwitchURL: url, paymentType: paymentType, completion: completion)
    }
    
    // MARK: - Analytics Helpers
    
    private func sendAnalyticsEvent(for paymentType: BTPayPalPaymentType, success: Bool) {
        let successString = success ? "started" : "failed"
        
        apiClient.sendAnalyticsEvent("ios.\(paymentType.stringValue).webswitch.initiate.\(successString)")
        
        if let checkoutRequest = payPalRequest as? BTPayPalCheckoutRequest,
           checkoutRequest.offerPayLater {
            apiClient.sendAnalyticsEvent("ios.\(paymentType.stringValue).webswitch.paylater.offered.\(successString)")
        }
        
        if let vaultRequest = payPalRequest as? BTPayPalVaultRequest, vaultRequest.offerCredit {
            apiClient.sendAnalyticsEvent("ios.\(paymentType.stringValue).webswitch.credit.offered.\(successString)")
        }
    }

    // MARK: - Private Methods

    private func tokenize(
        request: BTPayPalRequest,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeStarted)
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
                completion(nil, error)
                return
            }

            guard let configuration, let json = configuration.json else {
                self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
                completion(nil, BTPayPalError.fetchConfigurationFailed)
                return
            }

            guard json["paypalEnabled"].isTrue else {
                self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
                completion(nil, BTPayPalError.disabled)
                return
            }

            self.payPalRequest = request
            self.apiClient.post(request.hermesPath, parameters: request.parameters(with: configuration)) { body, response, error in
                if let error = error as? NSError {
                    if error.code == BTCoreConstants.networkConnectionLostCode {
                        self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeNetworkConnectionFailed)
                    }

                    guard let jsonResponseBody = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON else {
                        self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
                        completion(nil, error)
                        return
                    }

                    let errorDetailsIssue = jsonResponseBody["paymentResource"]["errorDetails"][0]["issue"]
                    var dictionary = error.userInfo
                    dictionary[NSLocalizedDescriptionKey] = errorDetailsIssue
                    self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
                    completion(nil, BTPayPalError.httpPostRequestError(dictionary))
                    return
                }

                guard let body,
                      var approvalURL = body["paymentResource"]["redirectUrl"].asURL() ??
                        body["agreementSetup"]["approvalUrl"].asURL() else {
                    self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
                    completion(nil, BTPayPalError.invalidURL)
                    return
                }

                approvalURL = self.decorate(approvalURL: approvalURL, for: request)

                let pairingID = self.token(from: approvalURL)
                let dataCollector = BTDataCollector(apiClient: self.apiClient)
                self.clientMetadataID = self.payPalRequest?.riskCorrelationID ?? dataCollector.clientMetadataID(pairingID)
                self.sendAnalyticsEvent(for: request.paymentType, success: error == nil)
                self.handlePayPalRequest(with: approvalURL, paymentType: request.paymentType, completion: completion)
            }
        }
    }
    
    private func performSwitchRequest(
        appSwitchURL: URL,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        approvalURL = appSwitchURL
        authenticationSession = ASWebAuthenticationSession(
            url: appSwitchURL,
            callbackURLScheme: BTCoreConstants.callbackURLScheme
        ) { callbackURL, error in
            // Required to avoid memory leak for BTPayPalClient
            self.authenticationSession = nil
            if let error = error as? NSError {
                switch error {
                case ASWebAuthenticationSessionError.canceledLogin:
                    // User canceled by breaking out of the PayPal browser switch flow
                    // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
                    if self.returnedToAppAfterPermissionAlert == false {
                        // User tapped system cancel button on permission alert
                        self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserLoginAlertCanceled)
                    }
                    // general login cancel message for both user cancel
                    self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserLoginCanceled)
                    completion(nil, BTPayPalError.canceled)
                    return
                default:
                    self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
                    completion(nil, BTPayPalError.webSessionError(error))
                    return
                }
            }
            
            self.handleBrowserSwitchReturn(callbackURL, paymentType: paymentType, completion: completion)
        }
        
        authenticationSession?.presentationContextProvider = self
        returnedToAppAfterPermissionAlert = false
        isAuthenticationSessionStarted = authenticationSession?.start() ?? false
        
        if isAuthenticationSessionStarted {
            apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserPresentationSucceeded)
        } else {
            apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserPresentationFailed)
            apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeFailed)
            completion(nil, BTPayPalError.webSessionFailedToLaunch)
            return
        }
    }
    
    private func decorate(approvalURL: URL, for request: BTPayPalRequest) -> URL {
        guard let request = payPalRequest as? BTPayPalCheckoutRequest,
              var approvalURLComponents = URLComponents(url: approvalURL, resolvingAgainstBaseURL: false) else {
            return approvalURL
        }

        let userActionValue = request.userAction.stringValue
        guard userActionValue.count > 0 else {
            return approvalURL
        }
        
        let userActionQueryItem = URLQueryItem(name: "useraction", value: userActionValue)
        var queryItems = approvalURLComponents.queryItems ?? []
        queryItems.append(userActionQueryItem)
        approvalURLComponents.queryItems = queryItems
        
        return approvalURLComponents.url ?? approvalURL
    }
    
    private func token(from approvalURL: URL) -> String {
        guard let query = approvalURL.query else { return "" }
        let queryDictionary = parse(queryString: query)
        
        return queryDictionary["token"] ?? queryDictionary["ba_token"] ?? ""
    }
    
    private func parse(queryString query: String) -> [String: String] {
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
    
    private func isValidURLAction(url: URL) -> Bool {
        guard let host = url.host, let scheme = url.scheme, !scheme.isEmpty else {
            return false
        }
        
        var hostAndPath = host
            .appending(url.path)
            .components(separatedBy: "/")
            .dropLast(1) // remove the action (`success`, `cancel`, etc)
            .joined(separator: "/")

        if hostAndPath.count > 0 {
            hostAndPath.append("/")
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
    
    private func responseDictionary(from url: URL) -> [String : Any]? {
        if let action = action(from: url), action == "cancel" {
            return nil
        }

        let clientDictionary: [String: String] = [
            "platform": "iOS",
            "product_name": "PayPal",
            "paypal_sdk_version": "version"
        ]

        let responseDictionary: [String: String] = ["webURL": url.absoluteString]
        
        return [
            "client": clientDictionary,
            "response": responseDictionary,
            "response_type": "web"
        ]
    }
    
    private func action(from url: URL) -> String? {
        guard let action = url.lastPathComponent.components(separatedBy: "?").first,
           !action.isEmpty else {
            return url.host
        }

        return action
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension BTPayPalClient: ASWebAuthenticationPresentationContextProviding {

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