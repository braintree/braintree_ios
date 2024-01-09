import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTVenmoAppSwitchRedirectURL {

    // MARK: - Internal Properties

    let universalLinkURL = URL(string: "https://venmo.com/go/checkout")!

    /// The base app switch URL for Venmo. Does not include specific parameters.
    static var baseAppSwitchURL: URL? {
        appSwitchBaseURLComponents().url
    }

    // MARK: - Private Properties

    static private let xCallbackTemplate: String = "scheme://x-callback-url/path"
    static private let venmoScheme: String = "com.venmo.touch.v2"

    private var queryParameters: [String: Any?] = [:]

    // MARK: - Initializer

    init(
        returnURLScheme: String,
        paymentContextID: String,
        forMerchantID merchantID: String?,
        accessToken: String?,
        bundleDisplayName: String?,
        environment: String?,
        metadata: BTClientMetadata?
    ) throws {
        guard let accessToken,
              let metadata,
              let bundleDisplayName,
              let environment,
              let merchantID
        else {
            // TODO: return explicit error?
            throw BTVenmoError.unknown
        }

        let venmoMetadata: [String: String] = [
            "version": BTCoreConstants.braintreeSDKVersion,
            "sessionId": metadata.sessionID,
            "integration": metadata.integration.stringValue,
            "platform": "ios"
        ]

        let braintreeData: [String: Any] = ["_meta": venmoMetadata]
        let serializedBraintreeData = try? JSONSerialization.data(withJSONObject: braintreeData)
        let base64EncodedBraintreeData = serializedBraintreeData?.base64EncodedString()

        // TODO: - Confirm preservation of optional query params sent before refactor
        queryParameters = [
            "x-success": returnURL(with: returnURLScheme, result: "success"),
            "x-error": returnURL(with: returnURLScheme, result: "error"),
            "x-cancel": returnURL(with: returnURLScheme, result: "cancel"),
            "x-source": bundleDisplayName,
            "braintree_merchant_id": merchantID,
            "braintree_access_token": accessToken,
            "braintree_environment": environment,
            "resource_id": paymentContextID,
            "braintree_sdk_data": base64EncodedBraintreeData ?? ""
        ]
    }

    // MARK: - Internal Methods

    func universalLink() -> URL {
        // TODO: don't force unwrap
        let universalLinkURL = URL(string: "https://venmo.com/go/checkout")!

        var urlComponent = URLComponents(url: universalLinkURL, resolvingAgainstBaseURL: false)!
        urlComponent.percentEncodedQuery = BTURLUtils.queryString(from: queryParameters as NSDictionary)

        return urlComponent.url!
    }

    func urlSchemeLink() -> URL {
        var components = BTVenmoAppSwitchRedirectURL.appSwitchBaseURLComponents()
        components.percentEncodedQuery = BTURLUtils.queryString(from: queryParameters as NSDictionary)
        return components.url!
    }

    // MARK: - Private Helper Methods

    // TODO: - add docstrings or rename these functions, hard to tell what they do
    private func returnURL(with scheme: String, result: String) -> URL? {
        var components = URLComponents(string: BTVenmoAppSwitchRedirectURL.xCallbackTemplate)
        components?.scheme = scheme
        components?.percentEncodedPath = "/vzero/auth/venmo/\(result)"
        return components?.url
    }

    static private func appSwitchBaseURLComponents() -> URLComponents {
        var components: URLComponents = URLComponents(string: xCallbackTemplate) ?? URLComponents()
        components.scheme = venmoScheme
        components.percentEncodedPath = "/vzero/auth"
        return components
    }
}
