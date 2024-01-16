import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTVenmoAppSwitchRedirectURL {

    // MARK: - Internal Properties

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
        metadata: BTClientMetadata,
        forMerchantID merchantID: String?,
        accessToken: String?,
        bundleDisplayName: String?,
        environment: String?
    ) throws {
        guard let accessToken, let bundleDisplayName, let environment, let merchantID else {
            throw BTVenmoError.invalidRedirectURLParameter
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

        queryParameters = [
            "x-success": constructRedirectURL(with: returnURLScheme, result: "success"),
            "x-error": constructRedirectURL(with: returnURLScheme, result: "error"),
            "x-cancel": constructRedirectURL(with: returnURLScheme, result: "cancel"),
            "x-source": bundleDisplayName,
            "braintree_merchant_id": merchantID,
            "braintree_access_token": accessToken,
            "braintree_environment": environment,
            "resource_id": paymentContextID,
            "braintree_sdk_data": base64EncodedBraintreeData ?? "",
            "customerClient": "MOBILE_APP"
        ]
    }

    // MARK: - Internal Methods

    func universalLink() -> URL {
        let universalLinkURL = URL(string: "https://venmo.com/go/checkout")!

        var urlComponent = URLComponents(url: universalLinkURL, resolvingAgainstBaseURL: false)!
        urlComponent.percentEncodedQuery = BTURLUtils.queryString(from: queryParameters as NSDictionary)

        return urlComponent.url!
    }

    func appSwitchLink() -> URL {
        var components = BTVenmoAppSwitchRedirectURL.appSwitchBaseURLComponents()
        components.percentEncodedQuery = BTURLUtils.queryString(from: queryParameters as NSDictionary)
        
        return components.url!
    }

    // MARK: - Private Helper Methods

    private func constructRedirectURL(with scheme: String, result: String) -> URL? {
        var components = URLComponents(string: BTVenmoAppSwitchRedirectURL.xCallbackTemplate)
        components?.scheme = scheme
        components?.percentEncodedPath = "/vzero/auth/venmo/\(result)"
        return components?.url
    }

    private static func appSwitchBaseURLComponents() -> URLComponents {
        var components: URLComponents = URLComponents(string: xCallbackTemplate) ?? URLComponents()
        components.scheme = venmoScheme
        components.percentEncodedPath = "/vzero/auth"
        return components
    }
}
