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
    var application: URLOpener = UIApplication.shared

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
    static var venmoClient: BTVenmoClient?

    /// Used for linking events from the client to server side request
    /// In the Venmo flow this will be the payment context ID
    private var payPalContextID: String?

    /// Used for sending the type of flow, universal vs deeplink to FPTI
    private var linkType: LinkType?

    private var universalLink: URL?

    // MARK: - Initializer

    /// Creates a Venmo client
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        BTAppContextSwitcher.sharedInstance.register(BTVenmoClient.self)
        self.apiClient = apiClient
    }

    /// Initialize a new Venmo client instance.
    /// - Parameters:
    ///   - apiClient: The API Client
    ///   - universalLink: The URL for the Venmo app to redirect to after user authentication completes. Must be a valid HTTPS URL dedicated to Braintree app switch returns.
    @objc(initWithAPIClient:universalLink:)
    public convenience init(apiClient: BTAPIClient, universalLink: URL) {
        self.init(apiClient: apiClient)
        
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
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    public func tokenize(_ request: BTVenmoRequest, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        linkType = request.fallbackToWeb ? .universal : .deeplink
        apiClient.sendAnalyticsEvent(BTVenmoAnalytics.tokenizeStarted, isVaultRequest: shouldVault, linkType: linkType)
        let returnURLScheme = BTAppContextSwitcher.sharedInstance._returnURLScheme

        if (universalLink?.absoluteString.isEmpty == true || universalLink?.absoluteString == nil) && returnURLScheme.isEmpty {
            NSLog(
                "%@ Venmo requires a return URL scheme or universal link to be configured.",
                BTLogLevelDescription.string(for: .critical)
            )
            notifyFailure(
                with: BTVenmoError.invalidReturnURL("Venmo requires a return URL scheme or universal link to be configured."),
                completion: completion
            )
            return
        } else if
            let bundleIdentifier = bundle.bundleIdentifier,
                !returnURLScheme.hasPrefix(bundleIdentifier)
                && (universalLink?.absoluteString.isEmpty == true || universalLink?.absoluteString == nil) {
            NSLog(
                // swiftlint:disable:next line_length
                "%@ Venmo requires [BTAppContextSwitcher setReturnURLScheme:] to be configured to begin with your app's bundle ID (%@). Currently, it is set to (%@)",
                BTLogLevelDescription.string(for: .critical),
                bundleIdentifier,
                returnURLScheme
            )
        }

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
                _ = try self.verifyAppSwitch(with: configuration, fallbackToWeb: request.fallbackToWeb)
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
            
            let graphQLParameters = self.buildGraphQLDictionary(with: request, merchantProfileID: merchantProfileID)

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

                self.payPalContextID = paymentContextID

                do {
                    let appSwitchURL = try BTVenmoAppSwitchRedirectURL(
                        paymentContextID: paymentContextID,
                        metadata: metadata,
                        returnURLScheme: returnURLScheme,
                        universalLink: self.universalLink,
                        forMerchantID: merchantProfileID,
                        accessToken: configuration.venmoAccessToken,
                        bundleDisplayName: bundleDisplayName,
                        environment: configuration.venmoEnvironment
                    )

                    if request.fallbackToWeb {
                        guard let universalLinksURL = appSwitchURL.universalLinksURL() else {
                            self.notifyFailure(
                                with: BTVenmoError.invalidReturnURL("Universal links URL cannot be nil"),
                                completion: completion
                            )
                            return
                        }

                        self.startVenmoFlow(with: universalLinksURL, shouldVault: request.vault, completion: completion)
                    } else {
                        guard let urlSchemeURL = appSwitchURL.urlSchemeURL() else {
                            self.notifyFailure(with: BTVenmoError.invalidReturnURL("App switch URL cannot be nil"), completion: completion)
                            return
                        }

                        self.startVenmoFlow(with: urlSchemeURL, shouldVault: request.vault, completion: completion)
                    }
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

    /// Returns true if the proper Venmo app is installed and configured correctly, returns false otherwise.
    @objc public func isVenmoAppInstalled() -> Bool {
        guard let appSwitchURL = BTVenmoAppSwitchRedirectURL.baseAppSwitchURL else {
            return false
        }

        return application.canOpenURL(appSwitchURL)
    }

    /// Switches to the App Store to download the Venmo application.
    @objc public func openVenmoAppPageInAppStore() {
        application.open(appStoreURL, completionHandler: nil)
    }

    // MARK: - Internal Methods

    func buildGraphQLDictionary(with request: BTVenmoRequest, merchantProfileID: String?) -> [String: Any] {
        var inputParameters: [String: Any?] = [
            "paymentMethodUsage": request.paymentMethodUsage.stringValue,
            "merchantProfileId": merchantProfileID,
            "customerClient": "MOBILE_APP",
            "intent": "CONTINUE",
            "isFinalAmount": "\(request.isFinalAmount)"
        ]

        if let displayName = request.displayName {
            inputParameters["displayName"] = displayName
        }

        var paysheetDetails: [String: Any] = [
            "collectCustomerBillingAddress": "\(request.collectCustomerBillingAddress)",
            "collectCustomerShippingAddress": "\(request.collectCustomerShippingAddress)"
        ]

        var transactionDetails: [String: Any] = [:]
        if let subTotalAmount = request.subTotalAmount {
            transactionDetails["subTotalAmount"] = subTotalAmount
        }

        if let discountAmount = request.discountAmount {
            transactionDetails["discountAmount"] = discountAmount
        }

        if let taxAmount = request.taxAmount {
            transactionDetails["taxAmount"] = taxAmount
        }

        if let shippingAmount = request.shippingAmount {
            transactionDetails["shippingAmount"] = shippingAmount
        }

        if let totalAmount = request.totalAmount {
            transactionDetails["totalAmount"] = totalAmount
        }

        if let lineItems = request.lineItems, !lineItems.isEmpty {
            for item in lineItems {
                if item.unitTaxAmount == nil || item.unitTaxAmount?.isEmpty == true {
                    item.unitTaxAmount = "0"
                }
            }
            let lineItemsArray = lineItems.compactMap { $0.requestParameters() }
            transactionDetails["lineItems"] = lineItemsArray
        }

        if !transactionDetails.isEmpty {
            paysheetDetails["transactionDetails"] = transactionDetails
        }

        inputParameters["paysheetDetails"] = paysheetDetails

        let inputDictionary: [String: Any] = ["input": inputParameters]

        let graphQLParameters: [String: Any] = [
            // swiftlint:disable:next line_length
            "query": "mutation CreateVenmoPaymentContext($input: CreateVenmoPaymentContextInput!) { createVenmoPaymentContext(input: $input) { venmoPaymentContext { id } } }",
            "variables": inputDictionary
        ]

        return graphQLParameters
    }

    // MARK: - App Switch Methods

    // swiftlint:disable:next function_body_length
    func handleOpen(_ url: URL) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.handleReturnStarted,
            isVaultRequest: shouldVault,
            linkType: linkType,
            payPalContextID: payPalContextID
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
            let variablesDictionary: [String: String?] = ["id": returnURL.paymentContextID]
            let graphQLParameters: [String: Any] = [
                // swiftlint:disable:next line_length
                "query": "query PaymentContext($id: ID!) { node(id: $id) { ... on VenmoPaymentContext { paymentMethodId userName payerInfo { firstName lastName phoneNumber email externalId userName shippingAddress { fullName addressLine1 addressLine2 adminArea1 adminArea2 postalCode countryCode } billingAddress { fullName addressLine1 addressLine2 adminArea1 adminArea2 postalCode countryCode } } } } }",
                "variables": variablesDictionary
            ]

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
                    self.vault(venmoAccountNonce.nonce)
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
                vault(nonce)
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
            isVaultRequest: shouldVault,
            linkType: linkType,
            payPalContextID: payPalContextID
        )
        application.open(appSwitchURL) { success in
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
                isVaultRequest: shouldVault,
                linkType: linkType,
                payPalContextID: payPalContextID
            )
            BTVenmoClient.venmoClient = self
            self.appSwitchCompletion = completion
        } else {
            apiClient.sendAnalyticsEvent(
                BTVenmoAnalytics.appSwitchFailed,
                appSwitchURL: appSwitchURL,
                isVaultRequest: shouldVault,
                linkType: linkType,
                payPalContextID: payPalContextID
            )
            notifyFailure(with: BTVenmoError.appSwitchFailed, completion: completion)
        }
    }

    // MARK: - Vaulting Methods

    func vault(_ nonce: String) {
        let venmoAccount: [String: String] = ["nonce": nonce]
        let parameters: [String: Any] = ["venmoAccount": venmoAccount]

        apiClient.post("v1/payment_methods/venmo_accounts", parameters: parameters) { body, _, error in
            if let error {
                self.notifyFailure(with: error, completion: self.appSwitchCompletion)
                return
            }
            
            guard let body else {
                self.notifyFailure(with: BTVenmoError.invalidBodyReturned, completion: self.appSwitchCompletion)
                return
            }
            
            let venmoAccountJSON: BTJSON = body["venmoAccounts"][0]

            if let venmoJSONError = venmoAccountJSON.asError() {
                self.notifyFailure(with: venmoJSONError, completion: self.appSwitchCompletion)
                return
            }

            let venmoAccountNonce = BTVenmoAccountNonce.venmoAccount(with: venmoAccountJSON)
            self.notifySuccess(with: venmoAccountNonce, completion: self.appSwitchCompletion)
            return
        }
    }

    // MARK: - App Switch Methods

    func verifyAppSwitch(with configuration: BTConfiguration, fallbackToWeb: Bool) throws -> Bool {
        if !configuration.isVenmoEnabled {
            throw BTVenmoError.disabled
        }


        if !fallbackToWeb && !isVenmoAppInstalled() {
            throw BTVenmoError.appNotAvailable
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
            isVaultRequest: shouldVault,
            linkType: linkType,
            payPalContextID: payPalContextID
        )
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.tokenizeFailed,
            errorDescription: error.localizedDescription,
            isVaultRequest: shouldVault,
            linkType: linkType,
            payPalContextID: payPalContextID
        )
        completion(nil, error)
    }

    private func notifyCancel(completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTVenmoAnalytics.appSwitchCanceled,
            isVaultRequest: shouldVault,
            linkType: linkType,
            payPalContextID: payPalContextID
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
