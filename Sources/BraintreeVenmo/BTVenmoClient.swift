import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to process Venmo payments
@objcMembers public class BTVenmoClient: NSObject {

    // MARK: - Internal Properties

    let appStoreURL: URL = URL(string: "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428")!

    // TODO: doc this
    static var venmoClient: BTVenmoClient? = nil

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

    /// Defaults to `BTAppContextSwitcher.sharedInstance.returnURLScheme`, but exposed for unit tests to stub returnURLScheme.
    var returnURLScheme: String = BTAppContextSwitcher.sharedInstance.returnURLScheme

    /// Stored property used to determine whether a Venmo account nonce should be vaulted after an app switch return
    var shouldVault: Bool = false

    // TODO: document this
    var appSwitchCompletion: (BTVenmoAccountNonce?, Error?) -> Void = { _, _ in }

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
    ///   - venmoRequest: A Venmo request.
    ///   - completion: This completion will be invoked when app switch is complete or an error occurs. On success, you will receive
    ///   an instance of `BTVenmoAccountNonce`; on failure, an error; on user cancellation, you will receive `nil` for both parameters.
    @objc(tokenizeVenmoAccountWithVenmoRequest:completion:)
    public func tokenizeVenmoAccount(with venmoRequest: BTVenmoRequest, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        // TODO: why is this needed for Swift?
        returnURLScheme = BTAppContextSwitcher.sharedInstance.returnURLScheme

        if returnURLScheme == "" {
            NSLog("%@ Venmo requires a return URL scheme to be configured via [BTAppContextSwitcher setReturnURLScheme:]", BTLogLevelDescription.string(for: .critical) ?? "[BraintreeSDK] CRITICAL")
            completion(nil, BTVenmoError.appNotAvailable)
            return
        } else if let bundleIdentifier = bundle.bundleIdentifier, !returnURLScheme.hasPrefix(bundleIdentifier) {
            NSLog("%@ Venmo requires [BTAppContextSwitcher setReturnURLScheme:] to be configured to begin with your app's bundle ID (%@). Currently, it is set to (%@)", BTLogLevelDescription.string(for: .critical) ?? "[BraintreeSDK] CRITICAL", bundleIdentifier, returnURLScheme)
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

            var error: Error? = error
            if !self.verifyAppSwitch(with: configuration, error: &error) {
                completion(nil, error)
                return
            }

            let merchantProfileID = venmoRequest.profileID ?? configuration.venmoMerchantID
            let bundleDisplayName = self.bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String

            let metadata = self.apiClient.metadata
            metadata.source = .venmoApp

            var inputParameters: [String: String?] = [
                "paymentMethodUsage": venmoRequest.paymentMethodUsage.stringValue,
                "merchantProfileId": merchantProfileID,
                "customerClient": "MOBILE_APP",
                "intent": "CONTINUE"
            ]

            if let displayName = venmoRequest.displayName {
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

                    completion(nil, BTVenmoError.invalidRequestURL("Failed to fetch a Venmo paymentContextID while constructing the requestURL."))
                    return
                }

                guard let body else {
                    completion(nil, BTVenmoError.invalidBodyReturned)
                    return
                }

                guard let paymentContextID = body["data"]["createVenmoPaymentContext"]["venmoPaymentContext"]["id"].asString() else {
                    completion(nil, BTVenmoError.invalidRequestURL("Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support."))
                    return
                }

                guard let appSwitchURL = BTVenmoAppSwitchRequestURL.appSwitch(
                    forMerchantID: merchantProfileID,
                    accessToken: configuration.venmoAccessToken,
                    returnURLScheme: self.returnURLScheme,
                    bundleDisplayName: bundleDisplayName,
                    environment: configuration.venmoEnvironment,
                    paymentContextID: paymentContextID,
                    metadata: metadata
                ) else {
                    // TODO: solidify error return here - is this accurate?
                    completion(nil, BTVenmoError.invalidRequestURL(""))
                    return
                }

                self.performAppSwitch(with: appSwitchURL, shouldVault: venmoRequest.vault, completion: completion)
            }
        }
    }

    /// Returns true if the proper Venmo app is installed and configured correctly, returns false otherwise.
    // TODO: does this need to be public?
    public func isiOSAppAvailableForAppSwitch() -> Bool {
        application.canOpenURL(BTVenmoAppSwitchRequestURL.baseAppSwitchURL ?? URL(string: "")!)
    }

    /// Switches to the iTunes App Store to download the Venmo app.
    public func openVenmoAppPageInAppStore() {
        apiClient.sendAnalyticsEvent("ios.pay-with-venmo.app-store.invoked")
        application.open(appStoreURL) { _ in }
    }

    // MARK: - Internal Methods

    // MARK: - App Switch Methods

    func handleOpenURL(_ url: URL) {
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
                }

                guard let body else {
                    self.appSwitchCompletion(nil, BTVenmoError.invalidBodyReturned)
                    return
                }

                let venmoAccountNonce: BTVenmoAccountNonce = BTVenmoAccountNonce(with: body)
                self.apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.success")

                if self.shouldVault && self.apiClient.clientToken != nil {
                    self.vaultVenmoAccountNonce(venmoAccountNonce.nonce)
                } else {
                    self.appSwitchCompletion(venmoAccountNonce, nil)
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
                vaultVenmoAccountNonce(nonce)
            } else {
                let detailsDictionary: [String: String?] = ["username": returnURL.username]
                let json: BTJSON = BTJSON(
                    value: [
                        "nonce": nonce,
                        "details": detailsDictionary,
                        "description": username
                    ]
                )

                let venmoAccountNonce = BTVenmoAccountNonce(with: json)
                appSwitchCompletion(venmoAccountNonce, nil)
                return
            }

        case .failed:
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.failed")
            appSwitchCompletion(nil, returnURL.error)

        case .canceled:
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.handle.cancel")
            appSwitchCompletion(nil, nil)

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

    func vaultVenmoAccountNonce(_ nonce: String) {
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
            let venmoAccountNonce: BTVenmoAccountNonce = BTVenmoAccountNonce(with: venmoAccountJSON)

            self.apiClient.sendAnalyticsEvent("ios.pay-with-venmo.vault.success")
            self.appSwitchCompletion(venmoAccountNonce, venmoAccountJSON.asError())
        }
    }

    // MARK: - App Switch Methods

    func verifyAppSwitch(with configuration: BTConfiguration, error: inout Error?) -> Bool {
        if !configuration.isVenmoEnabled {
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.initiate.error.disabled")
            error = BTVenmoError.disabled
            return false
        }

        if !isiOSAppAvailableForAppSwitch() {
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.initiate.error.unavailable")
            error = BTVenmoError.appNotAvailable
            return false
        }

        guard bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") != nil else {
            error = BTVenmoError.bundleDisplayNameMissing
            return false
        }

        return true
    }
}

// MARK: - BTAppContextSwitchClient Protocol Conformance

extension BTVenmoClient: BTAppContextSwitchClient {

    public static func handleReturnURL(_ url: URL) {
        venmoClient?.handleOpenURL(url)
        BTVenmoClient.venmoClient = nil
    }

    public static func canHandleReturnURL(_ url: URL) -> Bool {
        BTVenmoAppSwitchReturnURL.isValid(url: url)
    }
}
