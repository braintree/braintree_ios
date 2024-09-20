import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

// swiftlint:disable type_body_length file_length
@objc public class BTPayPalClient: BTWebAuthenticationSessionClient {
    
    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    /// Defaults to `UIApplication.shared`, but exposed for unit tests to inject test doubles
    /// to prevent calls to openURL. Subclassing UIApplication is not possible, since it enforces that only one instance can ever exist.
    var application: URLOpener = UIApplication.shared

    /// Exposed for testing the approvalURL construction
    var approvalURL: URL?

    /// Exposed for testing the clientMetadataID associated with this request.
    /// Used in POST body for FPTI analytics & `/paypal_account` fetch.
    var clientMetadataID: String?

    /// Exposed for testing the intent associated with this request
    var payPalRequest: BTPayPalRequest?

    /// Exposed for testing, the ASWebAuthenticationSession instance used for the PayPal flow
    var webAuthenticationSession: BTWebAuthenticationSession

    /// Used internally as a holder for the completion in methods that do not pass a completion such as `handleOpen`.
    /// This allows us to set and return a completion in our methods that otherwise cannot require a completion.
    var appSwitchCompletion: (BTPayPalAccountNonce?, Error?) -> Void = { _, _ in }

    /// True if `tokenize()` was called with a Vault request object type
    var isVaultRequest: Bool = false

    // MARK: - Static Properties

    /// This static instance of `BTPayPalClient` is used during the app switch process.
    /// We require a static reference of the client to call `handleReturnURL` and return to the app.
    static var payPalClient: BTPayPalClient?

    // MARK: - Private Properties

    private var universalLink: URL?

    /// Indicates if the user returned back to the merchant app from the `BTWebAuthenticationSession`
    /// Will only be `true` if the user proceed through the `UIAlertController`
    private var webSessionReturned: Bool = false

    /// Used for linking events from the client to server side request
    /// In the PayPal flow this will be either an EC token or a Billing Agreement token
    private var payPalContextID: String?
    
    /// Used for analytics purposes, to determine if brower-presentation event is associated with a locally cached, or remotely fetched `BTConfiguration`
    private var isConfigFromCache: Bool?

    /// Used for sending the type of flow, universal vs deeplink to FPTI
    private var linkType: LinkType?

    // MARK: - Initializer

    /// Initialize a new PayPal client instance.
    /// - Parameter apiClient: The API Client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        BTAppContextSwitcher.sharedInstance.register(BTPayPalClient.self)

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

    /// Initialize a new PayPal client instance for the PayPal App Switch flow.
    /// - Parameters:
    ///   - apiClient: The API Client
    ///   - universalLink: The URL to use for the PayPal app switch flow. Must be a valid HTTPS URL dedicated to Braintree app switch returns. This URL must be allow-listed in your Braintree Control Panel.
    /// - Warning: This initializer should be used for merchants using the PayPal App Switch flow. This feature is currently in beta and may change or be removed in future releases.
    @objc(initWithAPIClient:universalLink:)
    public convenience init(apiClient: BTAPIClient, universalLink: URL) {
        self.init(apiClient: apiClient)
        self.universalLink = universalLink
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
        isVaultRequest = true
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
        isVaultRequest = false
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

    /// Allows a customer to edit their PayPal payment method.
    ///
    /// On success, you will receive an instance of `BTPayPalVaultEditResult`; on failure or user cancelation you will receive an error.
    /// If the user cancels out of the flow, the error code will be `.canceled`.
    ///
    /// - Parameters:
    ///   - request: A `BTPayPalVaultEditRequest`
    ///   - completion: This completion will be invoked exactly once when the edit flow is complete or an error occurs.
    /// - Warning: This feature is currently in beta and may change or be removed in future releases. Additionally, this feature is currently only supported with client token authorization.
    public func edit(
        _ request: BTPayPalVaultEditRequest,
        completion: @escaping (BTPayPalVaultEditResult?, Error?) -> Void
    ) {
        edit(request: request, completion: completion)
    }

    /// Allows a customer to edit their PayPal payment method.
    ///
    /// On success, you will receive an instance of `BTPayPalVaultEditResult`; on failure or user cancelation you will receive an error.
    /// If the user cancels out of the flow, the error code will be `.canceled`.
    ///
    /// - Parameter request: A `BTPayPalVaultEditRequest`
    /// - Returns: A `BTPayPalVaultEditResult` if successful
    /// - Throws: An `Error` describing the failure
    /// - Warning: This feature is currently in beta and may change or be removed in future releases. Additionally, this feature is currently only supported with client token authorization.
    public func edit(_ request: BTPayPalVaultEditRequest) async throws -> BTPayPalVaultEditResult {
        try await withCheckedThrowingContinuation { continuation in
            edit(request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    /// Allows a customer to retry alternate funding instruments on failed attempts.
    ///
    /// On success, you will receive an instance of `BTPayPalVaultEditResult`; on failure or user cancelation you will receive an error.
    /// If the user cancels out of the flow, the error code will be `.canceled`.
    ///
    /// - Parameters:
    ///   - request: A `BTPayPalVaultErrorHandlingEditRequest`
    ///   - completion: This completion will be invoked exactly once when the edit flow is complete or an error occurs.
    /// - Warning: This feature is currently in beta and may change or be removed in future releases. Additionally, this feature is currently only supported with client token authorization.
    public func edit(
        _ request: BTPayPalVaultErrorHandlingEditRequest,
        completion: @escaping (BTPayPalVaultEditResult?, Error?) -> Void
    ) {
        edit(request: request, completion: completion)
    }

    /// Allows a customer to retry alternate funding instruments on failed attempts.
    ///
    /// On success, you will receive an instance of `BTPayPalVaultEditResult`; on failure or user cancelation you will receive an error.
    /// If the user cancels out of the flow, the error code will be `.canceled`.
    ///
    /// - Parameter request: A `BTPayPalVaultErrorHandlingEditRequest`
    /// - Returns: A `BTPayPalVaultEditResult` if successful
    /// - Throws: An `Error` describing the failure
    /// - Warning: This feature is currently in beta and may change or be removed in future releases. Additionally, this feature is currently only supported with client token authorization.
    public func edit(_ request: BTPayPalVaultErrorHandlingEditRequest) async throws -> BTPayPalVaultEditResult {
        try await withCheckedThrowingContinuation { continuation in
            edit(request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    // MARK: - Internal Methods
    
    func handleReturn(
        _ url: URL?,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.handleReturnStarted,
            correlationID: clientMetadataID,
            isVaultRequest: isVaultRequest,
            linkType: linkType,
            payPalContextID: payPalContextID
        )

        guard let url, BTPayPalReturnURL.isValidURLAction(url: url, linkType: linkType) else {
            notifyFailure(with: BTPayPalError.invalidURLAction, completion: completion)
            return
        }
        
        guard let action = BTPayPalReturnURL.action(from: url), action != "cancel" else {
            notifyCancel(completion: completion)
            return
        }

        let clientDictionary: [String: String] = [
            "platform": "iOS",
            "product_name": "PayPal",
            "paypal_sdk_version": "version"
        ]

        let responseDictionary: [String: String] = ["webURL": url.absoluteString]

        var account: [String: Any] = [
            "client": clientDictionary,
            "response": responseDictionary,
            "response_type": "web"
        ]

        if paymentType == .checkout {
            account["options"] = ["validate": false]
            if let request = payPalRequest as? BTPayPalCheckoutRequest {
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
        
        apiClient.post("/v1/payment_methods/paypal_accounts", parameters: parameters) { body, _, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }

            guard
                let payPalAccount = body?["paypalAccounts"].asArray()?.first,
                let tokenizedAccount = BTPayPalAccountNonce(json: payPalAccount)
            else {
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

    func handlePayPalEditFIRequest(
        with url: URL,
        riskCorrelationID: String,
        completion: @escaping (BTPayPalVaultEditResult?, Error?) -> Void
    ) {
        // Defensive programming in case PayPal returns a non-HTTP URL so that ASWebAuthenticationSession doesn't crash
        if let urlScheme = url.scheme, !urlScheme.lowercased().hasPrefix("http") {
            notifyEditFIFailure(with: BTPayPalError.asWebAuthenticationSessionURLInvalid(urlScheme), completion: completion)
            return
        }

        performEditSwitchRequest(editURL: url, riskCorrelationID: riskCorrelationID, completion: completion)
    }

    // MARK: - App Switch Methods

    func handleReturnURL(_ url: URL) {
        guard let returnURL = BTPayPalReturnURL(.payPalApp(url: url)) else {
            notifyFailure(with: BTPayPalError.invalidURL("App Switch return URL cannot be nil"), completion: appSwitchCompletion)
            return
        }

        switch returnURL.state {
        case .succeeded, .canceled:
            guard let payPalRequest else {
                notifyFailure(with: BTPayPalError.missingPayPalRequest, completion: appSwitchCompletion)
                return
            }

            handleReturn(url, paymentType: payPalRequest.paymentType, completion: appSwitchCompletion)
        case .unknownPath:
            notifyFailure(with: BTPayPalError.appSwitchReturnURLPathInvalid, completion: appSwitchCompletion)
        }
    }

    // MARK: - Private Methods

    private func tokenize(
        request: BTPayPalRequest,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        linkType = (request as? BTPayPalVaultRequest)?.enablePayPalAppSwitch == true ? .universal : .deeplink

        apiClient.sendAnalyticsEvent(BTPayPalAnalytics.tokenizeStarted, isVaultRequest: isVaultRequest, linkType: linkType)
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }

            guard let configuration, let json = configuration.json else {
                self.notifyFailure(with: BTPayPalError.fetchConfigurationFailed, completion: completion)
                return
            }
            
            self.isConfigFromCache = configuration.isFromCache

            guard json["paypalEnabled"].isTrue else {
                self.notifyFailure(with: BTPayPalError.disabled, completion: completion)
                return
            }

            self.payPalRequest = request
            self.apiClient.post(
                request.hermesPath,
                parameters: request.parameters(
                    with: configuration,
                    universalLink: self.universalLink,
                    isPayPalAppInstalled: self.application.isPayPalAppInstalled()
                )
            ) { body, _, error in
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
                
                guard let body, let approvalURL = BTPayPalApprovalURLParser(body: body) else {
                    self.notifyFailure(with: BTPayPalError.invalidURL("Missing approval URL in gateway response."), completion: completion)
                    return
                }
                
                self.payPalContextID = approvalURL.baToken ?? approvalURL.ecToken

                let dataCollector = BTDataCollector(apiClient: self.apiClient)
                self.clientMetadataID = self.payPalRequest?.riskCorrelationID ?? dataCollector.clientMetadataID(self.payPalContextID)

                switch approvalURL.redirectType {
                case .payPalApp(let url):
                    guard let baToken = approvalURL.baToken else {
                        self.notifyFailure(with: BTPayPalError.missingBAToken, completion: completion)
                        return
                    }

                    self.launchPayPalApp(with: url, baToken: baToken, completion: completion)
                case .webBrowser(let url):
                    self.handlePayPalRequest(with: url, paymentType: request.paymentType, completion: completion)
                }
            }
        }
    }

    private func edit(request: BTPayPalVaultEditRequest, completion: @escaping (BTPayPalVaultEditResult?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(BTPayPalAnalytics.editFIStarted)

        if apiClient.authorization.type != .clientToken {
            notifyEditFIFailure(with: BTPayPalError.invalidAuthorization, completion: completion)
            return
        }

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.notifyEditFIFailure(with: error, completion: completion)
                return
            }

            guard let configuration, let json = configuration.json else {
                self.notifyEditFIFailure(with: BTPayPalError.fetchConfigurationFailed, completion: completion)
                return
            }

            guard json["paypalEnabled"].isTrue else {
                self.notifyEditFIFailure(with: BTPayPalError.disabled, completion: completion)
                return
            }

            let dataCollector = BTDataCollector(apiClient: self.apiClient)

            var riskCorrelationID: String

            if let editRequest = request as? BTPayPalVaultErrorHandlingEditRequest {
                riskCorrelationID = dataCollector.clientMetadataID(editRequest.riskCorrelationID)
            } else {
                riskCorrelationID = dataCollector.clientMetadataID(nil)
            }

            /// set the clientMetadataID to be used in analytics events
            self.clientMetadataID = riskCorrelationID

            let parameters = request.parameters(riskCorrelationID: riskCorrelationID)

            self.apiClient.post("v1/paypal_hermes/generate_edit_fi_url", parameters: parameters) { body, _, error in
                if let error = error as? NSError {
                    guard let jsonResponseBody = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON else {
                        self.notifyEditFIFailure(with: error, completion: completion)
                        return
                    }

                    var dictionary = error.userInfo
                    let errorDetailsIssue = jsonResponseBody["paymentResource"]["errorDetails"][0]["issue"]

                    if !errorDetailsIssue.isError {
                        dictionary[NSLocalizedDescriptionKey] = errorDetailsIssue
                    }

                    self.notifyEditFIFailure(with: BTPayPalError.httpPostRequestError(dictionary), completion: completion)
                    return
                }

                guard
                    let body,
                    let approvalURL = body["paymentResource"]["redirectUrl"].asURL() ?? body["agreementSetup"]["approvalUrl"].asURL()
                else {
                    self.notifyEditFIFailure(
                        with: BTPayPalError.invalidURL("Missing approval URL in gateway response."),
                        completion: completion
                    )
                    return
                }

                self.handlePayPalEditFIRequest(with: approvalURL, riskCorrelationID: riskCorrelationID, completion: completion)
            }
        }
    }

    private func launchPayPalApp(
        with payPalAppRedirectURL: URL,
        baToken: String,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.appSwitchStarted,
            isVaultRequest: isVaultRequest,
            linkType: linkType,
            payPalContextID: payPalContextID
        )

        var urlComponents = URLComponents(url: payPalAppRedirectURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "ba_token", value: baToken),
            URLQueryItem(name: "source", value: "braintree_sdk"),
            URLQueryItem(name: "switch_initiated_time", value: String(Int(round(Date().timeIntervalSince1970 * 1000))))
        ]
        
        guard let redirectURL = urlComponents?.url else {
            self.notifyFailure(with: BTPayPalError.invalidURL("Unable to construct PayPal app redirect URL."), completion: completion)
            return
        }

        application.open(redirectURL) { success in
            self.invokedOpenURLSuccessfully(success, completion: completion)
        }
    }

    private func invokedOpenURLSuccessfully(_ success: Bool, completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void) {
        if success {
            apiClient.sendAnalyticsEvent(
                BTPayPalAnalytics.appSwitchSucceeded,
                isVaultRequest: isVaultRequest,
                linkType: linkType,
                payPalContextID: payPalContextID
            )
            BTPayPalClient.payPalClient = self
            appSwitchCompletion = completion
        } else {
            apiClient.sendAnalyticsEvent(
                BTPayPalAnalytics.appSwitchFailed,
                isVaultRequest: isVaultRequest,
                linkType: linkType,
                payPalContextID: payPalContextID
            )
            notifyFailure(with: BTPayPalError.appSwitchFailed, completion: completion)
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

            guard let url, let returnURL = BTPayPalReturnURL(.webBrowser(url: url)) else {
                notifyFailure(with: BTPayPalError.invalidURL("ASWebAuthenticationSession return URL cannot be nil"), completion: completion)
                return
            }

            switch returnURL.state {
            case .succeeded, .canceled:
                guard let payPalRequest else {
                    notifyFailure(with: BTPayPalError.missingPayPalRequest, completion: appSwitchCompletion)
                    return
                }

                handleReturn(url, paymentType: payPalRequest.paymentType, completion: completion)
            case .unknownPath:
                notifyFailure(with: BTPayPalError.asWebAuthenticationSessionURLInvalid(url.absoluteString), completion: completion)
            }
        } sessionDidAppear: { [self] didAppear in
            if didAppear {
                apiClient.sendAnalyticsEvent(
                    BTPayPalAnalytics.browserPresentationSucceeded,
                    isConfigFromCache: isConfigFromCache,
                    isVaultRequest: isVaultRequest,
                    linkType: linkType,
                    payPalContextID: payPalContextID
                )
            } else {
                apiClient.sendAnalyticsEvent(
                    BTPayPalAnalytics.browserPresentationFailed,
                    isVaultRequest: isVaultRequest,
                    linkType: linkType,
                    payPalContextID: payPalContextID
                )
            }
        } sessionDidCancel: { [self] in
            if !webSessionReturned {
                // User tapped system cancel button on permission alert
                apiClient.sendAnalyticsEvent(
                    BTPayPalAnalytics.browserLoginAlertCanceled,
                    isVaultRequest: isVaultRequest,
                    linkType: linkType,
                    payPalContextID: payPalContextID
                )
            }

            // User canceled by breaking out of the PayPal browser switch flow
            // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
            notifyCancel(completion: completion)
            return
        }
    }

    private func performEditSwitchRequest(
        editURL: URL,
        riskCorrelationID: String,
        completion: @escaping (BTPayPalVaultEditResult?, Error?) -> Void
    ) {
        webSessionReturned = false

        webAuthenticationSession.start(url: editURL, context: self) { [weak self] url, error in
            guard let self else {
                completion(nil, BTPayPalError.deallocated)
                return
            }

            if let error {
                notifyEditFIFailure(with: BTPayPalError.webSessionError(error), completion: completion)
                return
            }

            guard let url, let returnURL = BTPayPalReturnURL(.webBrowser(url: url)) else {
                notifyEditFIFailure(
                    with: BTPayPalError.invalidURL("ASWebAuthenticationSession return URL cannot be nil"),
                    completion: completion
                )
                return
            }

            switch returnURL.state {
            case .succeeded:
                notifyEditFISuccess(with: BTPayPalVaultEditResult(riskCorrelationID: riskCorrelationID), completion: completion)

            case .canceled:
                notifyEditFICancel(completion: completion)

            case .unknownPath:
                notifyEditFIFailure(with: BTPayPalError.asWebAuthenticationSessionURLInvalid(url.absoluteString), completion: completion)
            }
        } sessionDidAppear: { [self] didAppear in
            if didAppear {
                apiClient.sendAnalyticsEvent(
                    BTPayPalAnalytics.editFIBrowserPresentationSucceeded,
                    correlationID: clientMetadataID
                )
            } else {
                apiClient.sendAnalyticsEvent(
                    BTPayPalAnalytics.editFIBrowserPresentationFailed,
                    correlationID: clientMetadataID
                )
            }
        } sessionDidCancel: { [self] in
            if !webSessionReturned {
                // User tapped system cancel button on permission alert
                apiClient.sendAnalyticsEvent(
                    BTPayPalAnalytics.editFIBrowserLoginAlertCanceled,
                    correlationID: clientMetadataID
                )
            }

            // User canceled by breaking out of the PayPal browser switch flow
            // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
            notifyEditFICancel(completion: completion)
            return
        }
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(
        with result: BTPayPalAccountNonce,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.tokenizeSucceeded,
            correlationID: clientMetadataID,
            isVaultRequest: isVaultRequest,
            linkType: linkType,
            payPalContextID: payPalContextID
        )
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.tokenizeFailed,
            correlationID: clientMetadataID,
            errorDescription: error.localizedDescription,
            isVaultRequest: isVaultRequest,
            linkType: linkType,
            payPalContextID: payPalContextID
        )
        completion(nil, error)
    }

    private func notifyCancel(completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void) {
        self.apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.browserLoginCanceled,
            correlationID: clientMetadataID,
            isVaultRequest: isVaultRequest,
            linkType: linkType,
            payPalContextID: payPalContextID
        )
        completion(nil, BTPayPalError.canceled)
    }

    private func notifyEditFISuccess(
        with result: BTPayPalVaultEditResult,
        completion: @escaping (BTPayPalVaultEditResult?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTPayPalAnalytics.editFISucceeded, correlationID: clientMetadataID)
        completion(result, nil)
    }

    private func notifyEditFIFailure(with error: Error, completion: @escaping (BTPayPalVaultEditResult?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.editFIFailed,
            correlationID: clientMetadataID,
            errorDescription: error.localizedDescription
        )
        completion(nil, error)
    }

    private func notifyEditFICancel(completion: @escaping (BTPayPalVaultEditResult?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(BTPayPalAnalytics.editFIBrowserLoginCanceled, correlationID: clientMetadataID)
        completion(nil, BTPayPalError.canceled)
    }
}

extension BTPayPalClient: BTAppContextSwitchClient {

    /// :nodoc:
    @_documentation(visibility: private)
    @objc public static func handleReturnURL(_ url: URL) {
        payPalClient?.handleReturnURL(url)
        BTPayPalClient.payPalClient = nil
    }

    /// :nodoc:
    @_documentation(visibility: private)
    @objc public static func canHandleReturnURL(_ url: URL) -> Bool {
        BTPayPalReturnURL.isValid(url)
    }
}
