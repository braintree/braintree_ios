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
    nonisolated(unsafe) var application: URLOpener = UIApplication.shared

    /// Exposed for testing the approvalURL construction
    var approvalURL: URL?

    /// Exposed for testing the clientMetadataID associated with this request.
    /// Used in POST body for FPTI analytics & `/paypal_account` fetch.
    /// The key is the PayPal context ID (e.g., BA or EC token), and the value is the corresponding client metadata ID.
    var clientMetadataIDs: [String: String] = [:]
    
    /// Exposed for testing the intent associated with this request
    var payPalRequest: BTPayPalRequest?
    
    /// Used for sending the type of flow, universal vs deeplink to FPTI
    /// Exposed for testing app switch responses
    var didPayPalServerAttemptAppSwitch: Bool?

    /// Exposed for testing, the ASWebAuthenticationSession instance used for the PayPal flow
    var webAuthenticationSession: BTWebAuthenticationSession

    /// Used internally as a holder for the completion in methods that do not pass a completion such as `handleOpen`.
    /// This allows us to set and return a completion in our methods that otherwise cannot require a completion.
    var appSwitchCompletion: (BTPayPalAccountNonce?, Error?) -> Void = { _, _ in }

    /// True if `tokenize()` was called with a Vault request object type
    var isVaultRequest: Bool = false
    
    /// Tracks if we have already called `UIApplication.shared.open` and have an active session in progress
    var hasOpenedURL = false
    
    // MARK: - Static Properties

    /// This static instance of `BTPayPalClient` is used during the app switch process.
    /// We require a static reference of the client to call `handleReturnURL` and return to the app.
    static var payPalClient: BTPayPalClient?

    // MARK: - Private Properties

    private var universalLink: URL?
    
    private var fallbackURLScheme: String?

    /// Indicates if the user returned back to the merchant app from the `BTWebAuthenticationSession`
    /// Will only be `true` if the user proceed through the `UIAlertController`
    private var webSessionReturned: Bool = false

    /// Used for linking events from the client to server side request
    /// In the PayPal flow this will be either an EC token or a Billing Agreement token
    private var contextID: String?
    
    /// Used to determine whether or not to render the WAS popup.
    /// If the experiement is enabled, set the `prefersEphemeralWebBrowserSession` flag to true.
    private var experiment: String?
    
    /// Used for analytics purposes, to determine if browser-presentation event is associated with a locally cached, or remotely fetched `BTConfiguration`
    private var isConfigFromCache: Bool?
    
    /// Used for analytics purpose to determine if the context type is `BA-TOKEN` or `EC-TOKEN`
    private var contextType: String?
    
    /// Used for analytics purpose to determine the funding source of the flow i.e. credit, payLater
    private var fundingSource: BTPayPalFundingSource?

    // MARK: - Initializer

    /// Initialize a new PayPal client instance.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls.
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        BTAppContextSwitcher.sharedInstance.register(BTPayPalClient.self)

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

    /// Initialize a new PayPal client instance for the PayPal App Switch flow.
    /// - Parameters:
    ///   - authorization: A valid client token or tokenization key used to authorize API calls.
    ///   - universalLink: The URL to use for the PayPal app switch flow. Must be a valid HTTPS URL dedicated to Braintree app switch returns. This URL must be allow-listed in your Braintree Control Panel.
    ///   - fallbackURLScheme: Optional: A custom URL scheme to use as a fallback if the universal link fails. Pass only the scheme name using alphanumeric characters, hyphens, and periods—without `://` (e.g., `"com.my-app.payments"` not `"com.my-app.payments://"`). This scheme must be registered in your app's Info.plist. You must also contact Braintree to register your URL scheme.
    /// - Warning: This initializer should be used for merchants using the PayPal App Switch flow. This feature is currently in beta and may change or be removed in future releases.
    @objc(initWithAuthorization:universalLink:fallbackURLScheme:)
    public convenience init(authorization: String, universalLink: URL, fallbackURLScheme: String? = nil) {
        self.init(authorization: authorization)

        /// appending a PayPal app switch specific path to verify we are in the correct flow when
        /// `canHandleReturnURL` is called
        self.universalLink = universalLink.appendingPathComponent("braintreeAppSwitchPayPal")
        self.fallbackURLScheme = fallbackURLScheme
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
        Task { @MainActor in
            do {
                let nonce = try await tokenize(request)
                completion(nonce, nil)
            } catch {
                completion(nil, error)
            }
        }
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
        isVaultRequest = true
        contextType = "BA-TOKEN"
        fundingSource = getFundingSource(from: request)
        return try await tokenize(request: request)
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
        Task { @MainActor in
            do {
                let nonce = try await tokenize(request)
                completion(nonce, nil)
            } catch {
                completion(nil, error)
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
    /// - Parameter request: A `BTPayPalCheckoutRequest`
    /// - Returns: A `BTPayPalAccountNonce` if successful
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ request: BTPayPalCheckoutRequest) async throws -> BTPayPalAccountNonce {
        isVaultRequest = false
        contextType = "EC-TOKEN"
        fundingSource = getFundingSource(from: request)
        return try await tokenize(request: request)
    }

    // MARK: - Internal Methods
    
    // swiftlint:disable function_body_length
    func handleReturn(
        _ url: URL?,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        contextID = extractToken(from: url)

        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.handleReturnStarted,
            applicationState: UIApplication.shared.applicationStateString,
            appSwitchURL: url,
            contextID: contextID,
            contextType: contextType,
            correlationID: contextID.flatMap { clientMetadataIDs[$0] },
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )

        guard
            let url,
            BTPayPalReturnURL.isValidURLAction(
                url: url,
                didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch ?? false
            ) else {
            notifyFailure(with: BTPayPalError.invalidURLAction, completion: completion)
            return
        }
        
        guard let action = BTPayPalReturnURL.action(from: url), action != "cancel" else {
            notifyCancel(completion: completion)
            return
        }
        
        guard let payPalRequest else {
            notifyFailure(with: BTPayPalError.missingPayPalRequest, completion: completion)
            return
        }

        let encodableParams = PayPalAccountPOSTEncodable(
            metadata: apiClient.metadata,
            request: payPalRequest,
            client: apiClient,
            paymentType: paymentType,
            url: url,
            correlationID: contextID.flatMap { clientMetadataIDs[$0] }
        )
        
        apiClient.post("/v1/payment_methods/paypal_accounts", parameters: encodableParams) { body, _, error in
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
        
        /// reset the `hasOpenedURL` flag to allow for future app switch attempts
        /// in cases where the customer abandons the flow without a return URL or failure
        /// returned to the SDK then reopens the merchant app and attempts the PayPal flow again
        hasOpenedURL = false
    }
    
    func handlePayPalRequest(with url: URL, paymentType: BTPayPalPaymentType) async throws -> BTPayPalAccountNonce {
        // Defensive programming in case PayPal returns a non-HTTP URL so that ASWebAuthenticationSession doesn't crash
        if let scheme = url.scheme, !scheme.lowercased().hasPrefix("http") {
            notifyFailure(with: BTPayPalError.asWebAuthenticationSessionURLInvalid(scheme))
            throw BTPayPalError.asWebAuthenticationSessionURLInvalid(scheme)
        }
        return try await performSwitchRequest(appSwitchURL: url, paymentType: paymentType)
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

    func invokedOpenURLSuccessfully(_ success: Bool, url: URL, completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void) {
        if success {
            apiClient.sendAnalyticsEvent(
                BTPayPalAnalytics.appSwitchSucceeded,
                applicationState: UIApplication.shared.applicationStateString,
                appSwitchURL: url,
                contextID: contextID,
                contextType: contextType,
                didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
                didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
                fundingSource: fundingSource?.rawValue,
                isVaultRequest: isVaultRequest
            )
            BTPayPalClient.payPalClient = self
            appSwitchCompletion = completion
        } else {
            apiClient.sendAnalyticsEvent(
                BTPayPalAnalytics.appSwitchFailed,
                applicationState: UIApplication.shared.applicationStateString,
                appSwitchURL: url,
                contextID: contextID,
                contextType: contextType,
                didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
                didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
                fundingSource: fundingSource?.rawValue,
                isVaultRequest: isVaultRequest
            )
            
            openURLInDefaultBrowser(url, completion: completion)
        }
    }
    
    private func openURLInDefaultBrowser(_ url: URL, completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.defaultBrowserStarted,
            applicationState: UIApplication.shared.applicationStateString,
            appSwitchURL: url,
            contextID: contextID,
            contextType: contextType,
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )
        
        application.open(url, options: [:]) { success in
            self.invokedOpenURLInDefaultBrowser(success, url: url, completion: completion)
        }
    }
    
    func invokedOpenURLInDefaultBrowser(
        _ isSuccess: Bool,
        url: URL,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        let eventName = isSuccess ? BTPayPalAnalytics.defaultBrowserSucceeded : BTPayPalAnalytics.defaultBrowserFailed

        apiClient.sendAnalyticsEvent(
            eventName,
            applicationState: UIApplication.shared.applicationStateString,
            appSwitchURL: url,
            contextID: contextID,
            contextType: contextType,
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest
        )

        if isSuccess {
            BTPayPalClient.payPalClient = self
            appSwitchCompletion = completion
        } else {
            hasOpenedURL = false
            notifyFailure(with: BTPayPalError.appSwitchFailed, completion: completion)
        }
    }

    // MARK: - App Switch Methods

    func handleReturnURL(_ url: URL) {
        /// reset the `hasOpenedURL` flag to allow for future app switch
        /// attempts after we have returned successfully
        hasOpenedURL = false

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

    private func tokenize(request: BTPayPalRequest) async throws -> BTPayPalAccountNonce {
        self.payPalRequest = request

        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.tokenizeStarted,
            applicationState: UIApplication.shared.applicationStateString,
            contextType: contextType,
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )

        let configuration: BTConfiguration
        do {
            configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
        } catch {
            notifyFailure(with: BTPayPalError.fetchConfigurationFailed)
            throw BTPayPalError.fetchConfigurationFailed
        }

        guard let json = configuration.json else {
            notifyFailure(with: BTPayPalError.fetchConfigurationFailed)
            throw BTPayPalError.fetchConfigurationFailed
        }

        self.isConfigFromCache = configuration.isFromCache

        guard configuration.isPayPalEnabled else {
            notifyFailure(with: BTPayPalError.disabled)
            throw BTPayPalError.disabled
        }

        self.payPalRequest = request

        let parameters = request.encodedPostBodyWith(
            configuration: configuration,
            isPayPalAppInstalled: self.application.isPayPalAppInstalled(),
            universalLink: self.universalLink,
            fallbackURLScheme: self.fallbackURLScheme
        )

        do {
            let (body, _) = try await self.apiClient.post(request.hermesPath, parameters: parameters)

            guard let body, let approvalURL = BTPayPalApprovalURLParser(body: body) else {
                notifyFailure(with: BTPayPalError.invalidURL("Missing approval URL in gateway response."))
                throw BTPayPalError.invalidURL("Missing approval URL in gateway response.")
            }

            self.contextID = approvalURL.baToken ?? approvalURL.ecToken

            self.experiment = approvalURL.experiment

            let dataCollector = BTDataCollector(authorization: self.apiClient.authorization.originalValue)
            let correlationID = self.payPalRequest?.riskCorrelationID ?? dataCollector.clientMetadataID(self.contextID)

            if let contextID = self.contextID {
                self.clientMetadataIDs[contextID] = correlationID
            }

            switch approvalURL.redirectType {
            case .payPalApp(let url):
                self.didPayPalServerAttemptAppSwitch = true
                guard (self.isVaultRequest ? approvalURL.baToken : approvalURL.ecToken) != nil else {
                    let error = self.isVaultRequest ? BTPayPalError.missingBAToken : BTPayPalError.missingECToken
                    notifyFailure(with: error)
                    throw error
                }
                let merchantID = json["merchantId"].asString()
                return try await self.launchPayPalApp(with: url, merchantID: merchantID)
            case .webBrowser(let url):
                self.didPayPalServerAttemptAppSwitch = false
                return try await self.handlePayPalRequest(with: url, paymentType: request.paymentType)
            }
        } catch let error as NSError {
            guard let jsonResponseBody = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON else {
                notifyFailure(with: error)
                throw error
            }

            let errorDetailsIssue = jsonResponseBody["paymentResource"]["errorDetails"]["issue"].asString()
            var dictionary = error.userInfo
            dictionary[NSLocalizedDescriptionKey] = errorDetailsIssue
            let httpError = BTPayPalError.httpPostRequestError(dictionary)
            notifyFailure(with: httpError)
            throw httpError
        }
    }
    
    private func getFundingSource(from request: BTPayPalRequest) -> BTPayPalFundingSource {
        if let checkoutRequest = request as? BTPayPalCheckoutRequest {
            if checkoutRequest.offerCredit { return .credit }
            if checkoutRequest.offerPayLater { return .payLater }
        }
        if let vaultRequest = request as? BTPayPalVaultRequest, vaultRequest.offerCredit { return .credit }
        return .payPal
    }

    private func launchPayPalApp(with payPalAppRedirectURL: URL, merchantID: String? = nil) async throws -> BTPayPalAccountNonce {
        try await withCheckedThrowingContinuation { continuation in
            launchPayPalApp(with: payPalAppRedirectURL, merchantID: merchantID) { nonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let nonce {
                    continuation.resume(returning: nonce)
                }
            }
        }
    }

    private func launchPayPalApp(
        with payPalAppRedirectURL: URL,
        merchantID: String? = nil,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        /// Prevent multiple calls to open the app
        guard !hasOpenedURL else {
            apiClient.sendAnalyticsEvent(
                BTPayPalAnalytics.tokenizeDuplicateRequest,
                applicationState: UIApplication.shared.applicationStateString,
                appSwitchURL: payPalAppRedirectURL,
                contextID: contextID,
                contextType: contextType,
                didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
                didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
                fundingSource: fundingSource?.rawValue,
                isVaultRequest: isVaultRequest,
                shopperSessionID: payPalRequest?.shopperSessionID
            )

            return
        }
        
        hasOpenedURL = true
        contextID = extractToken(from: payPalAppRedirectURL)

        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.appSwitchStarted,
            applicationState: UIApplication.shared.applicationStateString,
            appSwitchURL: payPalAppRedirectURL,
            contextID: contextID,
            contextType: contextType,
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )

        var urlComponents = URLComponents(url: payPalAppRedirectURL, resolvingAgainstBaseURL: true)
        let additionalQueryItems: [URLQueryItem] = [
            URLQueryItem(name: "source", value: "braintree_sdk"),
            URLQueryItem(name: "switch_initiated_time", value: String(Int(round(Date().timeIntervalSince1970 * 1000)))),
            URLQueryItem(name: "flow_type", value: isVaultRequest ? "va" : "ecs"),
            URLQueryItem(name: "merchant", value: merchantID ?? "unknown"),
            URLQueryItem(name: "funding_source", value: fundingSource?.rawValue ?? BTPayPalFundingSource.payPal.rawValue)
        ]
        
        urlComponents?.queryItems?.append(contentsOf: additionalQueryItems)
        
        guard let redirectURL = urlComponents?.url else {
            self.notifyFailure(with: BTPayPalError.invalidURL("Unable to construct PayPal app redirect URL."), completion: completion)
            hasOpenedURL = false
            return
        }

        application.open(redirectURL, options: [.universalLinksOnly: NSNumber(value: true)]) { success in
            self.invokedOpenURLSuccessfully(success, url: redirectURL, completion: completion)
        }
    }

    private func performSwitchRequest(appSwitchURL: URL, paymentType: BTPayPalPaymentType) async throws -> BTPayPalAccountNonce {
        try await withCheckedThrowingContinuation { continuation in
            performSwitchRequest(appSwitchURL: appSwitchURL, paymentType: paymentType) { nonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let nonce {
                    continuation.resume(returning: nonce)
                }
            }
        }
    }

    private func performSwitchRequest(
        appSwitchURL: URL,
        paymentType: BTPayPalPaymentType,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.browserPresentationStarted,
            applicationState: UIApplication.shared.applicationStateString,
            appSwitchURL: appSwitchURL,
            contextID: contextID,
            contextType: contextType,
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )
        
        approvalURL = appSwitchURL
        webSessionReturned = false
        
        configureSessionIfNeeded(for: experiment)

        webAuthenticationSession.start(url: appSwitchURL, context: self) { [weak self] url, error in
            self?.contextID = self?.extractToken(from: url)
            
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
            contextID = extractToken(from: appSwitchURL)
            
            if didAppear {
                apiClient.sendAnalyticsEvent(
                    BTPayPalAnalytics.browserPresentationSucceeded,
                    applicationState: UIApplication.shared.applicationStateString,
                    appSwitchURL: appSwitchURL,
                    contextID: contextID,
                    contextType: contextType,
                    didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
                    didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
                    fundingSource: fundingSource?.rawValue,
                    isConfigFromCache: isConfigFromCache,
                    isVaultRequest: isVaultRequest,
                    shopperSessionID: payPalRequest?.shopperSessionID
                )
            } else {
                apiClient.sendAnalyticsEvent(
                    BTPayPalAnalytics.browserPresentationFailed,
                    applicationState: UIApplication.shared.applicationStateString,
                    appSwitchURL: appSwitchURL,
                    contextID: contextID,
                    contextType: contextType,
                    didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
                    didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
                    fundingSource: fundingSource?.rawValue,
                    isVaultRequest: isVaultRequest,
                    shopperSessionID: payPalRequest?.shopperSessionID
                )
            }
        } sessionDidCancel: { [self] in
            contextID = extractToken(from: appSwitchURL)
            
            if !webSessionReturned {
                // User tapped system cancel button on permission alert
                apiClient.sendAnalyticsEvent(
                    BTPayPalAnalytics.browserLoginAlertCanceled,
                    applicationState: UIApplication.shared.applicationStateString,
                    appSwitchURL: appSwitchURL,
                    contextID: contextID,
                    contextType: contextType,
                    didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
                    didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
                    fundingSource: fundingSource?.rawValue,
                    isVaultRequest: isVaultRequest
                )
            }

            // User canceled by breaking out of the PayPal browser switch flow
            // (e.g. System "Cancel" button on permission alert or browser during ASWebAuthenticationSession)
            notifyCancel(completion: completion)
            return
        } sessionDidDuplicate: { [self] in
            contextID = extractToken(from: appSwitchURL)
            
            apiClient.sendAnalyticsEvent(
                BTPayPalAnalytics.tokenizeDuplicateRequest,
                applicationState: UIApplication.shared.applicationStateString,
                appSwitchURL: appSwitchURL,
                contextID: contextID,
                contextType: contextType,
                didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
                didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
                fundingSource: fundingSource?.rawValue,
                isVaultRequest: isVaultRequest,
                shopperSessionID: payPalRequest?.shopperSessionID
            )
        }
    }
    
    /// extract BA or EC token from the URL to set `contextID` correctly
    private func extractToken(from url: URL?) -> String? {
        guard let url else { return nil }

        let baToken = BTURLUtils.queryParameters(for: url)["ba_token"]
        let ecToken = BTURLUtils.queryParameters(for: url)["token"]
        return baToken ?? ecToken
    }
    
    private func configureSessionIfNeeded(for experiment: String? = nil) {
        if experiment == "InAppBrowserNoPopup" {
            webSessionReturned = true
            webAuthenticationSession.prefersEphemeralWebBrowserSession = true
        }
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(with result: BTPayPalAccountNonce) -> BTPayPalAccountNonce {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.tokenizeSucceeded,
            applicationState: UIApplication.shared.applicationStateString,
            contextID: contextID,
            contextType: contextType,
            correlationID: contextID.flatMap { clientMetadataIDs[$0] },
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )
        return result
    }

    private func notifySuccess(
        with result: BTPayPalAccountNonce,
        completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.tokenizeSucceeded,
            applicationState: UIApplication.shared.applicationStateString,
            contextID: contextID,
            contextType: contextType,
            correlationID: contextID.flatMap { clientMetadataIDs[$0] },
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )
        completion(result, nil)
    }

    private func notifyFailure(with error: Error) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.tokenizeFailed,
            applicationState: UIApplication.shared.applicationStateString,
            contextID: contextID,
            contextType: contextType,
            correlationID: contextID.flatMap { clientMetadataIDs[$0] },
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            errorDescription: error.localizedDescription,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.tokenizeFailed,
            applicationState: UIApplication.shared.applicationStateString,
            contextID: contextID,
            contextType: contextType,
            correlationID: contextID.flatMap { clientMetadataIDs[$0] },
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            errorDescription: error.localizedDescription,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )
        completion(nil, error)
    }

    private func notifyCancel(completion: @escaping (BTPayPalAccountNonce?, Error?) -> Void) {
        self.apiClient.sendAnalyticsEvent(
            BTPayPalAnalytics.browserLoginCanceled,
            contextID: contextID,
            contextType: contextType,
            correlationID: contextID.flatMap { clientMetadataIDs[$0] },
            didEnablePayPalAppSwitch: payPalRequest?.enablePayPalAppSwitch,
            didPayPalServerAttemptAppSwitch: didPayPalServerAttemptAppSwitch,
            fundingSource: fundingSource?.rawValue,
            isVaultRequest: isVaultRequest,
            shopperSessionID: payPalRequest?.shopperSessionID
        )
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
        BTPayPalReturnURL.isValid(url, fallbackURLScheme: payPalClient?.fallbackURLScheme)
    }
}
