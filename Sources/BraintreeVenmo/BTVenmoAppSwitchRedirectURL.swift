import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTVenmoAppSwitchRedirectURL {

    // MARK: - Private Properties

    private var queryParameters: [String: Any?] = [:]

    // MARK: - Initializer

    init(
        paymentContextID: String,
        metadata: BTClientMetadata,
        universalLink: URL,
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
            "customerClient": "MOBILE_APP",
            "x-success": universalLink.appendingPathComponent("success").absoluteString,
            "x-error": universalLink.appendingPathComponent("error").absoluteString,
            "x-cancel": universalLink.appendingPathComponent("cancel").absoluteString
        ]
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
}
