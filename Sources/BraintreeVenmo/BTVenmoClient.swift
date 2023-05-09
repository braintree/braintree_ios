import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to process Venmo payments
@objc public class BTVenmoClient: NSObject {

    // MARK: - Internal Properties

    let appStoreURL: URL = URL(string: "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428")!

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    /// Defaults to `UIApplication.shared`, but exposed for unit tests to inject test doubles
    /// to prevent calls to openURL. Its type is `id` and not `UIApplication` because trying to subclass
    /// UIApplication is not possible, since it enforces that only one instance can ever exist
    var application: AnyObject = UIApplication.shared

    /// Defaults to `Bundle.main`, but exposed for unit tests to inject test doubles to stub values in infoDictionary
    var bundle: Bundle = .main

    /// Defaults to `UIDevice.current`, but exposed for unit tests to inject different devices
    var device: UIDevice = .current

    /// Stored property used to determine whether a Venmo account nonce should be vaulted after an app switch return
    var shouldVault: Bool = false

    /// Used internally as a holder for the completion in methods that do not pass a completion such as `handleOpen`.
    /// This allows us to set and return a completion in our methods that otherwise cannot require a completion.
    var appSwitchCompletion: (BTVenmoAccountNonce?, Error?) -> Void = { _, _ in }

    // MARK: - Static Properties

    /// This static instance of `BTVenmoClient` is used during the app switch process.
    /// We require a static reference of the client to call `handleReturnURL` and return to the app.
    static var venmoClient: BTVenmoClient? = nil

    // MARK: - Initializer

    /// Creates an Apple Pay client
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        BTAppContextSwitcher.sharedInstance.register(BTVenmoClient.self)
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    /// Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.
    /// - Parameters:
    ///   - request: A Venmo request.
    ///   - completion: This completion will be invoked when app switch is complete or an error occurs. On success, you will receive
    ///   an instance of `BTVenmoAccountNonce`; on failure, an error; on user cancellation, you will receive `nil` for both parameters.
    @objc(tokenizeWithVenmoRequest:completion:)
    public func tokenize(_ request: BTVenmoRequest, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        let returnURLScheme = BTAppContextSwitcher.sharedInstance.returnURLScheme

        if returnURLScheme == "" {
            NSLog("%@ Venmo requires a return URL scheme to be configured via [BTAppContextSwitcher setReturnURLScheme:]", BTLogLevelDescription.string(for: .critical))
            completion(nil, BTVenmoError.appNotAvailable)
            return
        } else if let bundleIdentifier = bundle.bundleIdentifier, !returnURLScheme.hasPrefix(bundleIdentifier) {
            NSLog("%@ Venmo requires [BTAppContextSwitcher setReturnURLScheme:] to be configured to begin with your app's bundle ID (%@). Currently, it is set to (%@)", BTLogLevelDescription.string(for: .critical), bundleIdentifier, returnURLScheme)
        }

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                completion(nil, error)
                return
            }

            guard let configuration else {
                completion(nil, BTVenmoError.fetchConfigurationFailed)
                return
            }

            do {
                let _ = try self.verifyAppSwitch(with: configuration)
            } catch {
                completion(nil, error)
                return
            }

            let merchantProfileID = request.profileID ?? configuration.venmoMerchantID
            let bundleDisplayName = self.bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String

            let metadata = self.apiClient.metadata
            metadata.source = .venmoApp

            var inputParameters: [String: String?] = [
                "paymentMethodUsage": request.paymentMethodUsage.stringValue,
                "merchantProfileId": merchantProfileID,
                "customerClient": "MOBILE_APP",
                "intent": "CONTINUE"
            ]

            if let displayName = request.displayName {
                inputParameters["displayName"] = displayName
            }

            let inputDictionary: [String: Any] = ["input": inputParameters]
            let graphQLParameters: [String: Any] = [
                "query": "mutation CreateVenmoPaymentContext($input: CreateVenmoPaymentContextInput!) { createVenmoPaymentContext(input: $input) { venmoPaymentContext { id } } }",
                "variables": inputDictionary
            ]

            self.apiClient.post("", parameters: graphQLParameters, httpType: .graphQLAPI) { body, _, error in
                if let error = error as? NSError {
                    if error.code == BTCoreConstants.networkConnectionLostCode {
                        self.apiClient.sendAnalyticsEvent("ios.pay-with-venmo.network-connection.failure")
                    }

                    completion(nil, BTVenmoError.invalidRedirectURL("Failed to fetch a Venmo paymentContextID while constructing the requestURL."))
                    return
                }

                guard let body else {
                    completion(nil, BTVenmoError.invalidBodyReturned)
                    return
                }

                guard let paymentContextID = body["data"]["createVenmoPaymentContext"]["venmoPaymentContext"]["id"].asString() else {
                    completion(nil, BTVenmoError.invalidRedirectURL("Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support."))
                    return
                }

                guard let appSwitchURL = BTVenmoAppSwitchRedirectURL().appSwitch(
                    returnURLScheme: returnURLScheme,
                    forMerchantID: merchantProfileID,
                    accessToken: configuration.venmoAccessToken,
                    bundleDisplayName: bundleDisplayName,
                    environment: configuration.venmoEnvironment,
                    paymentContextID: paymentContextID,
                    metadata: metadata
                ) else {
                    completion(nil, BTVenmoError.invalidRedirectURL("The request URL could not be constructed or was nil."))
                    return
                }

                self.performAppSwitch(with: appSwitchURL, shouldVault: request.vault, completion: completion)
            }
        }
    }

    /// Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.
    /// - Parameter request: A `BTVenmoRequest`
    /// - Returns: On success, you will receive an instance of `BTVenmoAccountNonce`
    /// - Throws: An `Error` describing the failure
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

    /// Returns true if the proper Venmo app is installed and configured correctly, returns false otherwise.
    @objc public func isVenmoAppInstalled() -> Bool {
        if let _ = application as? UIApplication {
            guard let appSwitchURL = BTVenmoAppSwitchRedirectURL().baseAppSwitchURL else {
                return false
            }

            return UIApplication.shared.canOpenURL(appSwitchURL)
        } else {
            return application.canOpenURL(BTVenmoAppSwitchRedirectURL().baseAppSwitchURL ?? URL(string: "")!)
        }
    }

    /// Switches to the App Store to download the Venmo application.
    @objc public func openVenmoAppPageInAppStore() {
        apiClient.sendAnalyticsEvent("ios.pay-with-venmo.app-store.invoked")
        if let _ = application as? UIApplication {
            UIApplication.shared.open(appStoreURL)
        } else {
            application.open(appStoreURL)
        }
    }

    // MARK: - Internal Methods

    // MARK: - App Switch Methods

    func handleOpen(_ url: URL) {
        guard let returnURL = BTVenmoAppSwitchReturnURL(url: url) else {
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.failure")
            appSwitchCompletion(nil, BTVenmoError.invalidReturnURL(""))
            return
        }

        switch returnURL.state {
        case .succeededWithPaymentContext:
            let variablesDictionary: [String: String?] = ["id": returnURL.paymentContextID]
            let graphQLParameters: [String: Any] = [
                "query": "query PaymentContext($id: ID!) { node(id: $id) { ... on VenmoPaymentContext { paymentMethodId userName payerInfo { firstName lastName phoneNumber email externalId userName } } } }",
                "variables": variablesDictionary
            ]

            apiClient.post("", parameters: graphQLParameters, httpType: .graphQLAPI) { body, _, error in
                if let error = error as? NSError {
                    if error.code == BTCoreConstants.networkConnectionLostCode {
                        self.apiClient.sendAnalyticsEvent("ios.pay-with-venmo.network-connection.failure")
                    }

                    self.apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.client-failure")
                    self.appSwitchCompletion(nil, error)
                    return
                }

                guard let body else {
                    self.appSwitchCompletion(nil, BTVenmoError.invalidBodyReturned)
                    return
                }

                let venmoAccountNonce: BTVenmoAccountNonce = BTVenmoAccountNonce(with: body)
                self.apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.success")

                if self.shouldVault && self.apiClient.clientToken != nil {
                    self.vault(venmoAccountNonce.nonce)
                } else {
                    self.appSwitchCompletion(venmoAccountNonce, nil)
                    return
                }
            }

        case .succeeded:
            guard let nonce = returnURL.nonce else {
                apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.client-failure")
                appSwitchCompletion(nil, BTVenmoError.invalidReturnURL("nonce"))
                return
            }

            guard let username = returnURL.username else {
                apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.client-failure")
                appSwitchCompletion(nil, BTVenmoError.invalidReturnURL("username"))
                return
            }

            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.success")

            if shouldVault && apiClient.clientToken != nil {
                vault(nonce)
            } else {
                let detailsDictionary: [String: String?] = ["username": returnURL.username]
                let json: BTJSON = BTJSON(
                    value: [
                        "nonce": nonce,
                        "details": detailsDictionary,
                        "description": username
                    ] as [String: Any]
                )

                let venmoAccountNonce = BTVenmoAccountNonce.venmoAccount(with: json)
                appSwitchCompletion(venmoAccountNonce, nil)
                return
            }

        case .failed:
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.failed")
            appSwitchCompletion(nil, returnURL.error)
            return
            
        case .canceled:
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.cancel")
            appSwitchCompletion(nil, nil)
            return
            
        default:
            // should not happen
            break
        }
    }

    func performAppSwitch(with appSwitchURL: URL, shouldVault vault: Bool, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        if let _ = application as? UIApplication {
            UIApplication.shared.open(appSwitchURL) { success in
                self.invokedOpenURLSuccessfully(success, shouldVault: vault, completion: completion)
            }
        } else {
            application.open(appSwitchURL) { success in
                self.invokedOpenURLSuccessfully(success, shouldVault: vault, completion: completion)
            }
        }
    }

    func invokedOpenURLSuccessfully(_ success: Bool, shouldVault vault: Bool, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        shouldVault = success && vault

        if success {
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.initiate.success")
            BTVenmoClient.venmoClient = self
            self.appSwitchCompletion = completion
        } else {
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.initiate.error.failure")
            completion(nil, BTVenmoError.appSwitchFailed)
        }
    }

    // MARK: - Vaulting Methods

    func vault(_ nonce: String) {
        let venmoAccount: [String: String] = ["nonce": nonce]
        let parameters: [String: Any] = ["venmoAccount": venmoAccount]

        apiClient.post("v1/payment_methods/venmo_accounts", parameters: parameters) { body, _, error in
            if let error = error as? NSError {
                if error.code == BTCoreConstants.networkConnectionLostCode {
                    self.apiClient.sendAnalyticsEvent("ios.pay-with-venmo.network-connection.failure")
                }

                self.apiClient.sendAnalyticsEvent("ios.pay-with-venmo.vault.failure")
                self.appSwitchCompletion(nil, error)
                return
            }

            guard let body else {
                self.appSwitchCompletion(nil, BTVenmoError.invalidBodyReturned)
                return
            }

            let venmoAccountJSON: BTJSON = body["venmoAccounts"][0]
            let venmoAccountNonce: BTVenmoAccountNonce = BTVenmoAccountNonce.venmoAccount(with: venmoAccountJSON)

            self.apiClient.sendAnalyticsEvent("ios.pay-with-venmo.vault.success")
            self.appSwitchCompletion(venmoAccountNonce, venmoAccountJSON.asError())
            return
        }
    }

    // MARK: - App Switch Methods

    func verifyAppSwitch(with configuration: BTConfiguration) throws -> Bool {
        if !configuration.isVenmoEnabled {
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.initiate.error.disabled")
            throw BTVenmoError.disabled
        }

        if !isVenmoAppInstalled() {
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.initiate.error.unavailable")
            throw BTVenmoError.appNotAvailable
        }

        guard bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") != nil else {
            throw BTVenmoError.bundleDisplayNameMissing
        }

        return true
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
