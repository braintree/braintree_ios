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
    
    // MARK: - Private Properties

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
    public func tokenize(_ request: BTVenmoRequest, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        Task {
            do {
                let nonce = try await tokenize(request)
                completion(nonce, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    /// Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.
    /// - Parameter request: A `BTVenmoRequest`
    /// - Returns: On success, you will receive an instance of `BTVenmoAccountNonce`
    /// - Throws: An `Error` describing the failure. If the user cancels out of the flow, the error code will be `.canceled`.
    public func tokenize(_ request: BTVenmoRequest) async throws -> BTVenmoAccountNonce {
        apiClient.sendAnalyticsEvent(BTVenmoAnalytics.tokenizeStarted, isVaultRequest: shouldVault)
        
        let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
        
        _ = try verifyAppSwitch(with: configuration)
        
        // Merchants are not allowed to collect user addresses unless ECD (Enriched Customer Data) is enabled on the BT Control Panel.
        if (request.collectCustomerShippingAddress || request.collectCustomerBillingAddress)
            && !configuration.isVenmoEnrichedCustomerDataEnabled {
            throw BTVenmoError.enrichedCustomerDataDisabled
        }
        
        let merchantProfileID = request.profileID ?? configuration.venmoMerchantID
        let bundleDisplayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        
        let metadata = apiClient.metadata
        metadata.source = .venmoApp
        
        let graphQLParameters = VenmoCreatePaymentContextGraphQLBody(
            request: request,
            merchantProfileID: merchantProfileID
        )
        
        let (body, _) = try await apiClient.post("", parameters: graphQLParameters, httpType: .graphQLAPI)
        
        guard let body else {
            throw BTVenmoError.invalidBodyReturned
        }
        
        guard let paymentContextID = body["data"]["createVenmoPaymentContext"]["venmoPaymentContext"]["id"].asString() else {
            let message = "Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support."
            throw BTVenmoError.invalidRedirectURL(message)
        }
        
        contextID = paymentContextID
        
        let appSwitchURL = try BTVenmoAppSwitchRedirectURL(
            paymentContextID: paymentContextID,
            metadata: metadata,
            universalLink: universalLink,
            forMerchantID: merchantProfileID,
            accessToken: configuration.venmoAccessToken,
            bundleDisplayName: bundleDisplayName,
            environment: configuration.venmoEnvironment
        )
        
        guard let universalLinksURL = appSwitchURL.universalLinksURL() else {
            throw BTVenmoError.invalidReturnURL("Universal links URL cannot be nil")
        }
        
        return try await startVenmoFlow(with: universalLinksURL, shouldVault: request.vault)
    }

    /// Switches to the App Store to download the Venmo application.
    @objc public func openVenmoAppPageInAppStore() {
        application.open(appStoreURL, options: [:], completionHandler: nil)
    }

    // MARK: - App Switch Methods

    func handleOpen(_ url: URL) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.handleReturnStarted,
            contextID: contextID,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        
        guard let cleanedURL = URL(string: url.absoluteString.replacingOccurrences(of: "#", with: "?")) else {
            notifyFailure(with: BTVenmoError.invalidReturnURL(url.absoluteString))
            return
        }
        
        guard let returnURL = BTVenmoAppSwitchReturnURL(url: cleanedURL) else {
            notifyFailure(with: BTVenmoError.invalidReturnURL(cleanedURL.absoluteString))
            return
        }
        
        switch returnURL.state {
        case .succeededWithPaymentContext:
            handlePaymentContextSuccess(returnURL)
            
        case .succeeded:
            handleDirectSuccess(returnURL)
            
        case .failed:
            notifyFailure(with: returnURL.error ?? BTVenmoError.unknown)
            
        case .canceled:
            notifyCancel()
            
        default:
            break
        }
    }

    func startVenmoFlow(with appSwitchURL: URL, shouldVault vault: Bool) async throws -> BTVenmoAccountNonce {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.appSwitchStarted,
            contextID: contextID,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        
        let success = await withCheckedContinuation { continuation in
            application.open(appSwitchURL, options: [:]) { @MainActor success in
                continuation.resume(returning: success)
            }
        }
        try await invokedOpenURLSuccessfully(success, shouldVault: vault, appSwitchURL: appSwitchURL)
        
        return try await withCheckedThrowingContinuation { continuation in
            self.appSwitchCompletion = { nonce, error in
                if let nonce = nonce {
                    continuation.resume(returning: nonce)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: BTVenmoError.unknown)
                }
            }
        }
    }

    func invokedOpenURLSuccessfully(
        _ success: Bool,
        shouldVault vault: Bool,
        appSwitchURL: URL
    ) async throws {
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
        } else {
            apiClient.sendAnalyticsEvent(
                BTVenmoAnalytics.appSwitchFailed,
                appSwitchURL: appSwitchURL,
                contextID: contextID,
                isVaultRequest: shouldVault,
                linkType: linkType
            )
            throw BTVenmoError.appSwitchFailed
        }
    }
    
    // MARK: - Private Helpers
    
    private func handlePaymentContextSuccess(_ returnURL: BTVenmoAppSwitchReturnURL) {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let graphQLParameters = VenmoQueryPaymentContextGraphQLBody(paymentContextID: returnURL.paymentContextID)
                let (body, _) = try await self.apiClient.post("", parameters: graphQLParameters, httpType: .graphQLAPI)
                
                guard let body else {
                    self.notifyFailure(with: BTVenmoError.invalidBodyReturned)
                    return
                }
                
                let venmoAccountNonce = BTVenmoAccountNonce(with: body)
                await self.handleVaultingIfNeeded(for: venmoAccountNonce)
            } catch {
                self.notifyFailure(with: error)
            }
        }
    }
    
    private func handleDirectSuccess(_ returnURL: BTVenmoAppSwitchReturnURL) {
        guard let nonce = returnURL.nonce else {
            notifyFailure(with: BTVenmoError.invalidReturnURL("nonce"))
            return
        }
        
        guard let username = returnURL.username else {
            notifyFailure(with: BTVenmoError.invalidReturnURL("username"))
            return
        }
        
        if shouldVault && apiClient.authorization.type == .clientToken {
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let vaultedNonce = try await vault(nonce)
                    _ = self.notifySuccess(with: vaultedNonce)
                } catch {
                    self.notifyFailure(with: error)
                }
            }
        } else {
            let detailsDictionary: [String: String?] = ["username": username]
            let json = BTJSON(value: [
                "nonce": nonce,
                "details": detailsDictionary,
                "description": username
            ] as [String: Any])
            
            let venmoAccountNonce = BTVenmoAccountNonce.venmoAccount(with: json)
            _ = notifySuccess(with: venmoAccountNonce)
        }
    }
    
    private func handleVaultingIfNeeded(for venmoAccountNonce: BTVenmoAccountNonce) async {
        if shouldVault && apiClient.authorization.type == .clientToken {
            do {
                let vaultedNonce = try await vault(venmoAccountNonce.nonce)
                _ = notifySuccess(with: vaultedNonce)
            } catch {
                notifyFailure(with: error)
            }
        } else {
            _ = notifySuccess(with: venmoAccountNonce)
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

    private func notifySuccess(with result: BTVenmoAccountNonce) -> BTVenmoAccountNonce {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.tokenizeSucceeded,
            contextID: contextID,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        appSwitchCompletion(result, nil)
        appSwitchCompletion = { _, _ in }
        return result
    }

    private func notifyFailure(with error: Error) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.tokenizeFailed,
            contextID: contextID,
            errorDescription: error.localizedDescription,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        appSwitchCompletion(nil, error)
        appSwitchCompletion = { _, _ in }
    }

    private func notifyCancel() {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.appSwitchCanceled,
            contextID: contextID,
            errorDescription: BTVenmoError.canceled.localizedDescription,
            isVaultRequest: shouldVault,
            linkType: linkType
        )
        appSwitchCompletion(nil, BTVenmoError.canceled)
        appSwitchCompletion = { _, _ in }
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
