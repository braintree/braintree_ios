import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// swiftlint:disable type_body_length file_length
/// Used to process Venmo payments
@objc public class BTVenmoClient: NSObject {

    // MARK: - Internal Properties

    // swiftlint:disable:next force_unwrapping
    let appStoreURL = URL(string: "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428")!

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    /// Defaults to `UIApplication.shared`, but exposed for unit tests to inject test doubles
    /// to prevent calls to openURL. Subclassing UIApplication is not possible, since it enforces that only one instance can ever exist.
    nonisolated(unsafe) var application: URLOpener = UIApplication.shared

    /// Defaults to `Bundle.main`, but exposed for unit tests to inject test doubles to stub values in infoDictionary
    var bundle: Bundle = .main

    /// Defaults to `UIDevice.current`, but exposed for unit tests to inject different devices
    var device: UIDevice = .current

    /// Stored property used to determine whether a Venmo account nonce should be vaulted after an app switch return
    var shouldVault: Bool = false

    /// Used internally as a holder for the completion in methods that do not pass a completion such as `handleOpen`.
    /// This allows us to set and return a completion in our methods that otherwise cannot require a completion.
    var appSwitchCompletion: (BTVenmoAccountNonce?, Error?) -> Void = { _, _ in }

    /// Used for linking events from the client to server side request
    /// In the Venmo flow this will be the payment context ID
    private var contextID: String?

    /// Used for sending the type of flow, universal vs deeplink to FPTI
    private var linkType: LinkType?

    private var universalLink: URL

    // MARK: - Static Properties

    /// This static instance of `BTVenmoClient` is used during the app switch process.
    /// We require a static reference of the client to call `handleReturnURL` and return to the app.
    static var venmoClient: BTVenmoClient?

    // MARK: - Initializer

    /// Initialize a new Venmo client instance.
    /// - Parameters:
    ///   - authorization: A valid client token or tokenization key used to authorize API calls.
    ///   - universalLink: The URL for the Venmo app to redirect to after user authentication completes. Must be a valid HTTPS URL dedicated to Braintree app switch returns.
    @objc(initWithAuthorization:universalLink:)
    public init(authorization: String, universalLink: URL) {
        BTAppContextSwitcher.sharedInstance.register(BTVenmoClient.self)

        self.apiClient = BTAPIClient(authorization: authorization)

        /// appending a PayPal app switch specific path to verify we are in the correct flow when
        /// `canHandleReturnURL` is called
        self.universalLink = universalLink.appendingPathComponent("braintreeAppSwitchVenmo")
    }

    // MARK: - Public Methods

    /// Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.
    /// - Parameters:
    ///   - request: A Venmo request.
    ///   - completion: This completion will be invoked when app switch is complete or an error occurs. On success, you will receive
    ///   an instance of `BTVenmoAccountNonce`; on failure or user cancelation you will receive an error.
    ///   If the user cancels out of the flow, the error code will be `.canceled`.
    @objc(tokenizeWithVenmoRequest:completion:)
    // swiftlint:disable:next function_body_length
    public func tokenize(_ request: BTVenmoRequest, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(BTVenmoAnalytics.tokenizeStarted, isVaultRequest: shouldVault)

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }
            
            guard let configuration else {
                self.notifyFailure(with: BTVenmoError.fetchConfigurationFailed, completion: completion)
                return
            }
            
            do {
                _ = try self.verifyAppSwitch(with: configuration)
            } catch {
                self.notifyFailure(with: error, completion: completion)
                return
            }
            
            // Merchants are not allowed to collect user addresses unless ECD (Enriched Customer Data) is enabled on the BT Control Panel.
            if (request.collectCustomerShippingAddress || request.collectCustomerBillingAddress)
                && !configuration.isVenmoEnrichedCustomerDataEnabled {
                self.notifyFailure(with: BTVenmoError.enrichedCustomerDataDisabled, completion: completion)
                return
            }
            
            let merchantProfileID = request.profileID ?? configuration.venmoMerchantID
            let bundleDisplayName = self.bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            
            let metadata = self.apiClient.metadata
            metadata.source = .venmoApp
            
            let graphQLParameters = VenmoCreatePaymentContextGraphQLBody(
                request: request,
                merchantProfileID: merchantProfileID
            )

            self.apiClient.post("", parameters: graphQLParameters, httpType: .graphQLAPI) { body, _, error in
                if let error = error as? NSError {
                    let jsonResponse: BTJSON? = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
                    let errorMessage = jsonResponse?["error"]["message"].asString()
                    let defaultMessage = "Failed to fetch a Venmo paymentContextID while constructing the requestURL."
                    self.notifyFailure(
                        with: BTVenmoError.invalidRedirectURL(errorMessage ?? defaultMessage),
                        completion: completion
                    )
                    return
                }

                guard let body else {
                    self.notifyFailure(with: BTVenmoError.invalidBodyReturned, completion: completion)
                    return
                }

                guard let paymentContextID = body["data"]["createVenmoPaymentContext"]["venmoPaymentContext"]["id"].asString() else {
                    let message = "Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support."
                    self.notifyFailure(
                        with: BTVenmoError.invalidRedirectURL(message),
                        completion: completion
                    )
                    return
                }

                self.contextID = paymentContextID

                do {
                    let appSwitchURL = try BTVenmoAppSwitchRedirectURL(
                        paymentContextID: paymentContextID,
                        metadata: metadata,
                        universalLink: self.universalLink,
                        forMerchantID: merchantProfileID,
                        accessToken: configuration.venmoAccessToken,
                        bundleDisplayName: bundleDisplayName,
                        environment: configuration.venmoEnvironment
                    )

                    guard let universalLinksURL = appSwitchURL.universalLinksURL() else {
                        self.notifyFailure(
                            with: BTVenmoError.invalidReturnURL("Universal links URL cannot be nil"),
                            completion: completion
                        )
                        return
                    }

                    self.startVenmoFlow(with: universalLinksURL, shouldVault: request.vault, completion: completion)
                } catch {
                    self.notifyFailure(with: error, completion: completion)
                    return
                }
            }
        }
    }

    /// Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.
    /// - Parameter request: A `BTVenmoRequest`
    /// - Returns: On success, you will receive an instance of `BTVenmoAccountNonce`
    /// - Throws: An `Error` describing the failure. If the user cancels out of the flow, the error code will be `.canceled`.
    public func tokenize(_ request: BTVenmoRequest) async throws -> BTVenmoAccountNonce {
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

    /// Switches to the App Store to download the Venmo application.
    @objc public func openVenmoAppPageInAppStore() {
        application.open(appStoreURL, options: [:], completionHandler: nil)
    }

    // MARK: - App Switch Methods

    // swiftlint:disable:next function_body_length
    func handleOpen(_ url: URL) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.handleReturnStarted,
            contextID: contextID,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        guard let cleanedURL = URL(string: url.absoluteString.replacingOccurrences(of: "#", with: "?")) else {
            notifyFailure(with: BTVenmoError.invalidReturnURL(url.absoluteString), completion: appSwitchCompletion)
            return
        }

        guard let returnURL = BTVenmoAppSwitchReturnURL(url: cleanedURL) else {
            notifyFailure(with: BTVenmoError.invalidReturnURL(cleanedURL.absoluteString), completion: appSwitchCompletion)
            return
        }

        switch returnURL.state {
        case .succeededWithPaymentContext:
            let graphQLParameters = VenmoQueryPaymentContextGraphQLBody(paymentContextID: returnURL.paymentContextID)

            apiClient.post("", parameters: graphQLParameters, httpType: .graphQLAPI) { body, _, error in
                if let error {
                    self.notifyFailure(with: error, completion: self.appSwitchCompletion)
                    return
                }

                guard let body else {
                    self.notifyFailure(with: BTVenmoError.invalidBodyReturned, completion: self.appSwitchCompletion)
                    return
                }

                let venmoAccountNonce = BTVenmoAccountNonce(with: body)

                if self.shouldVault && self.apiClient.authorization.type == .clientToken {
                    Task {
                        do {
                            let vaultedNonce = try await self.vault(venmoAccountNonce.nonce)
                            self.notifySuccess(with: vaultedNonce, completion: self.appSwitchCompletion)
                        } catch {
                            self.notifyFailure(with: error, completion: self.appSwitchCompletion)
                        }
                    }
                } else {
                    self.notifySuccess(with: venmoAccountNonce, completion: self.appSwitchCompletion)
                    return
                }
            }

        case .succeeded:
            guard let nonce = returnURL.nonce else {
                notifyFailure(with: BTVenmoError.invalidReturnURL("nonce"), completion: appSwitchCompletion)
                return
            }

            guard let username = returnURL.username else {
                notifyFailure(with: BTVenmoError.invalidReturnURL("username"), completion: appSwitchCompletion)
                return
            }

            if shouldVault && apiClient.authorization.type == .clientToken {
                Task {
                    do {
                        let vaultedNonce = try await vault(nonce)
                        notifySuccess(with: vaultedNonce, completion: appSwitchCompletion)
                    } catch {
                        notifyFailure(with: error, completion: appSwitchCompletion)
                    }
                }
            } else {
                let detailsDictionary: [String: String?] = ["username": returnURL.username]
                let json = BTJSON(value: ["nonce": nonce, "details": detailsDictionary, "description": username] as [String: Any])

                let venmoAccountNonce = BTVenmoAccountNonce.venmoAccount(with: json)
                notifySuccess(with: venmoAccountNonce, completion: appSwitchCompletion)
                return
            }

        case .failed:
            notifyFailure(with: returnURL.error ?? BTVenmoError.unknown, completion: appSwitchCompletion)
            return
            
        case .canceled:
            notifyCancel(completion: appSwitchCompletion)
            return
            
        default:
            // should not happen
            break
        }
    }

    func startVenmoFlow(with appSwitchURL: URL, shouldVault vault: Bool, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.appSwitchStarted,
            contextID: contextID,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        application.open(appSwitchURL, options: [:]) { success in
            self.invokedOpenURLSuccessfully(success, shouldVault: vault, appSwitchURL: appSwitchURL, completion: completion)
        }
    }

    func invokedOpenURLSuccessfully(
        _ success: Bool,
        shouldVault vault: Bool,
        appSwitchURL: URL,
        completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void
    ) {
        shouldVault = success && vault

        if success {
            apiClient.sendAnalyticsEvent(
                BTVenmoAnalytics.appSwitchSucceeded,
                appSwitchURL: appSwitchURL,
                contextID: contextID,
                isVaultRequest: shouldVault,
                linkType: linkType
            )
            BTVenmoClient.venmoClient = self
            self.appSwitchCompletion = completion
        } else {
            apiClient.sendAnalyticsEvent(
                BTVenmoAnalytics.appSwitchFailed,
                appSwitchURL: appSwitchURL,
                contextID: contextID,
                isVaultRequest: shouldVault,
                linkType: linkType
            )
            notifyFailure(with: BTVenmoError.appSwitchFailed, completion: completion)
        }
    }

    // MARK: - Vaulting Methods
    
    func vault(_ nonce: String) async throws -> BTVenmoAccountNonce {
        let parameters = VenmoAccountsPOSTBody(nonce: nonce)
        
        let (body, _) = try await apiClient.post("v1/payment_methods/venmo_accounts", parameters: parameters)
        
        guard let body else {
            throw BTVenmoError.invalidBodyReturned
        }
        
        let venmoAccountJSON: BTJSON = body["venmoAccounts"][0]
        
        if let venmoJSONError = venmoAccountJSON.asError() {
            throw venmoJSONError
        }
        
        return BTVenmoAccountNonce.venmoAccount(with: venmoAccountJSON)
    }

    // MARK: - App Switch Methods

    func verifyAppSwitch(with configuration: BTConfiguration) throws -> Bool {
        if !configuration.isVenmoEnabled {
            throw BTVenmoError.disabled
        }

        guard bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") != nil else {
            throw BTVenmoError.bundleDisplayNameMissing
        }

        return true
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(
        with result: BTVenmoAccountNonce,
        completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.tokenizeSucceeded,
            contextID: contextID,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.tokenizeFailed,
            contextID: contextID,
            errorDescription: error.localizedDescription,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        completion(nil, error)
    }

    private func notifyCancel(completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.appSwitchCanceled,
            contextID: contextID,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        completion(nil, BTVenmoError.canceled)
    }
}

// MARK: - BTAppContextSwitchClient Protocol Conformance

extension BTVenmoClient: BTAppContextSwitchClient {
    
    /// :nodoc:
    @_documentation(visibility: private)
    @objc public static func handleReturnURL(_ url: URL) {
        venmoClient?.handleOpen(url)
        BTVenmoClient.venmoClient = nil
    }
    
    /// :nodoc:
    @_documentation(visibility: private)
    @objc public static func canHandleReturnURL(_ url: URL) -> Bool {
        BTVenmoAppSwitchReturnURL.isValid(url: url)
    }
}
