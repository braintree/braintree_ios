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

    private var queryParameters: [String: Any?] = [:]

    // MARK: - Initializer

    init(
        paymentContextID: String,
        metadata: BTClientMetadata,
        returnURLScheme: String?,
        universalLink: URL?,
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
            "x-source": bundleDisplayName,
            "braintree_merchant_id": merchantID,
            "braintree_access_token": accessToken,
            "braintree_environment": environment,
            "resource_id": paymentContextID,
            "braintree_sdk_data": base64EncodedBraintreeData ?? "",
            "customerClient": "MOBILE_APP"
        ]

        if let universalLink {
            queryParameters["x-success"] = universalLink.appendingPathComponent("success").absoluteString
            queryParameters["x-error"] = universalLink.appendingPathComponent("error").absoluteString
            queryParameters["x-cancel"] = universalLink.appendingPathComponent("cancel").absoluteString
        } else if let returnURLScheme {
            queryParameters["x-success"] = constructRedirectURL(with: returnURLScheme, result: "success")
            queryParameters["x-error"] = constructRedirectURL(with: returnURLScheme, result: "error")
            queryParameters["x-cancel"] = constructRedirectURL(with: returnURLScheme, result: "cancel")
        }
    }

    // MARK: - Internal Methods

    func universalLinksURL() -> URL? {
        guard let universalLinkURL = URL(string: "https://venmo.com/go/checkout") else {
            return nil
        }

        guard var urlComponent = URLComponents(url: universalLinkURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        urlComponent.percentEncodedQuery = BTURLUtils.queryString(from: queryParameters as NSDictionary)

        return urlComponent.url
    }

    func urlSchemeURL() -> URL? {
        var components = BTVenmoAppSwitchRedirectURL.appSwitchBaseURLComponents()
        components.percentEncodedQuery = BTURLUtils.queryString(from: queryParameters as NSDictionary)
        
        return components.url
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
        components.scheme = BTCoreConstants.venmoURLScheme
        components.percentEncodedPath = "/vzero/auth"
        return components
    }
}
