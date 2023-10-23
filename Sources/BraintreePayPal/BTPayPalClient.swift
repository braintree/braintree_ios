import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

@objc public class BTPayPalClient: BTWebAuthenticationSessionClient {
    
    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient
    
    /// Exposed for testing the approvalURL construction
    var approvalURL: URL? = nil

    /// Exposed for testing the clientMetadataID associated with this request.
    /// Used in POST body for FPTI analytics & `/paypal_account` fetch.
    var clientMetadataID: String? = nil
    
    /// Exposed for testing the intent associated with this request
    var payPalRequest: BTPayPalRequest? = nil

    /// Exposed for testing, the ASWebAuthenticationSession instance used for the PayPal flow
    var webAuthenticationSession: BTWebAuthenticationSession

    // MARK: - Private Properties

    /// Indicates if the user returned back to the merchant app from the `BTWebAuthenticationSession`
    /// Will only be `true` if the user proceed through the `UIAlertController`
    private var webSessionReturned: Bool = false

    // MARK: - Initializer

    /// Initialize a new PayPal client instance.
    /// - Parameter apiClient: The API Client
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
            notifyFailure(with: BTPayPalError.invalidURLAction, completion: completion)
            return
        }
        
        guard let response = responseDictionary(from: url) else {
            notifyCancel(completion: completion)
            return
        }
        
        var account: [String: Any] = response

        if paymentType == .checkout {
            account["options"] = ["validate": false]
            if let request  = payPalRequest as? BTPayPalCheckoutRequest {
                account["intent"] = request.intent.stringValue
            }
        }
        
        if let clientMetadataID {
            account["correlation_id"] = clientMetadataID
        }

        var parameters: [String: Any] = ["paypal_account": account]
        
        if let payPalRequest, let merchantAccountID = payPalRequest.merchantAccountID {
            parameters["merchant_account_id"] = merchantAccountID
        }

        let metadata = apiClient.metadata
        metadata.source = .payPalBrowser
        
        parameters["_meta"] = [
            "source": metadata.source.stringValue,
            "integration": metadata.integration.stringValue,
            "sessionId": metadata.sessionID
        ]
        
        apiClient.post("/v1/payment_methods/paypal_accounts", parameters: parameters) { body, response, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }

            guard let payPalAccount = body?["paypalAccounts"].asArray()?.first,
                  let tokenizedAccount = BTPayPalAccountNonce(json: payPalAccount) else {
                self.notifyFailure(with: BTPayPalError.failedToCreateNonce, completion: completion)
                return
            }

            self.notifySuccess(with: tokenizedAccount, completion: completion)
        }
    }
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        webSessionReturned = true
    }
    
    func handlePayPalRequest(
        with url: URL,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        // Defensive programming in case PayPal returns a non-HTTP URL so that ASWebAuthenticationSession doesn't crash
        if let scheme = url.scheme, !scheme.lowercased().hasPrefix("http") {
            notifyFailure(with: BTPayPalError.asWebAuthenticationSessionURLInvalid(scheme), completion: completion)
            return
        }
        performSwitchRequest(appSwitchURL: url, paymentType: paymentType, completion: completion)
    }

    // MARK: - Private Methods

    private func tokenize(
        request: BTPayPalRequest,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeStarted)
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }

            guard let configuration, let json = configuration.json else {
                self.notifyFailure(with: BTPayPalError.fetchConfigurationFailed, completion: completion)
                return
            }

            guard json["paypalEnabled"].isTrue else {
                self.notifyFailure(with: BTPayPalError.disabled, completion: completion)
                return
            }

            self.payPalRequest = request
            self.apiClient.post(request.hermesPath, parameters: request.parameters(with: configuration)) { body, response, error in
                if let error = error as? NSError {
                    guard let jsonResponseBody = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON else {
                        self.notifyFailure(with: error, completion: completion)
                        return
                    }

                    let errorDetailsIssue = jsonResponseBody["paymentResource"]["errorDetails"][0]["issue"]
                    var dictionary = error.userInfo
                    dictionary[NSLocalizedDescriptionKey] = errorDetailsIssue
                    self.notifyFailure(with: BTPayPalError.httpPostRequestError(dictionary), completion: completion)
                    return
                }

                guard let body,
                      let approvalURL = body["paymentResource"]["redirectUrl"].asURL() ??
                        body["agreementSetup"]["approvalUrl"].asURL() else {
                    self.notifyFailure(with: BTPayPalError.invalidURL, completion: completion)
                    return
                }

                let pairingID = self.token(from: approvalURL)
                let dataCollector = BTDataCollector(apiClient: self.apiClient)
                self.clientMetadataID = self.payPalRequest?.riskCorrelationID ?? dataCollector.clientMetadataID(pairingID)
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
        webSessionReturned = false
        
        webAuthenticationSession.start(url: appSwitchURL, context: self) { [weak self] url, error in
            guard let self else {
                completion(nil, BTPayPalError.deallocated)
                return
            }

            if let error {
                notifyFailure(with: BTPayPalError.webSessionError(error), completion: completion)
                return
            }

            handleBrowserSwitchReturn(url, paymentType: paymentType, completion: completion)
        } sessionDidAppear: { [self] didAppear in
            if didAppear {
                apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserPresentationSucceeded)
            } else {
                apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserPresentationFailed)
            }
        } sessionDidCancel: { [self] in
            if !webSessionReturned {
                // User tapped system cancel button on permission alert
                apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserLoginAlertCanceled)
            }

            // User canceled by breaking out of the PayPal browser switch flow
            // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
            apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserLoginCanceled)
            notifyCancel(completion: completion)
            return
        }
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

    // MARK: - Analytics Helper Methods

    private func notifySuccess(
        with result: BTPayPalAccountNonce,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeSucceeded, correlationID: clientMetadataID)
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.tokenizeFailed,
            errorDescription: error.localizedDescription,
            correlationID: clientMetadataID
        )
        completion(nil, error)
    }

    private func notifyCancel(completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void) {
        self.apiClient.sendAnalyticsEvent(BTPayPalAnalytics.browserLoginCanceled, correlationID: clientMetadataID)
        completion(nil, BTPayPalError.canceled)
    }
}
