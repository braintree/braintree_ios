import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTVenmoAppSwitchRedirectURL {

    let xCallbackTemplate: String = "scheme://x-callback-url/path"
    let venmoScheme: String = "com.venmo.touch.v2"

    /// The base app switch URL for Venmo. Does not include specific parameters.
    var baseAppSwitchURL: URL? {
        appSwitchBaseURLComponents().url
    }

    /// Create an app switch URL
    /// - Parameters:
    ///   - returnURLScheme:  The return URL scheme, e.g. "com.yourcompany.Your-App.payments"
    ///   - merchantID: The merchant ID
    ///   - accessToken: The access token used by the Venmo app to tokenize on behalf of the merchant
    ///   - bundleDisplayName: The bundle display name for the current app
    ///   - environment: The environment, e.g. "production" or "sandbox"
    ///   - paymentContextID: The Venmo payment context ID (optional)
    ///   - metadata: Additional Braintree metadata
    ///   - Returns: The resulting URL, or `nil` if any of the required parameters are `nil`.
    func appSwitch(
        returnURLScheme: String,
        forMerchantID merchantID: String?,
        accessToken: String?,
        bundleDisplayName: String?,
        environment: String?,
        paymentContextID: String?,
        metadata: BTClientMetadata?
    ) -> URL? {
        let successReturnURL = returnURL(with: returnURLScheme, result: "success")
        let errorReturnURL = returnURL(with: returnURLScheme, result: "error")
        let cancelReturnURL = returnURL(with: returnURLScheme, result: "cancel")

        guard let successReturnURL,
                let errorReturnURL,
                let cancelReturnURL,
                let accessToken,
                let metadata,
                let bundleDisplayName,
                let environment,
                let merchantID
        else {
            return nil
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

        var appSwitchParameters: [String: Any] = [
            "x-success": successReturnURL,
            "x-error": errorReturnURL,
            "x-cancel": cancelReturnURL,
            "x-source": bundleDisplayName,
            "braintree_merchant_id": merchantID,
            "braintree_access_token": accessToken,
            "braintree_environment": environment,
            "braintree_sdk_data": base64EncodedBraintreeData ?? ""
        ]

        if let paymentContextID {
            appSwitchParameters["resource_id"] = paymentContextID
        }

        var components = appSwitchBaseURLComponents()
        components.percentEncodedQuery = BTURLUtils.queryString(from: appSwitchParameters as NSDictionary)
        return components.url
    }

    // MARK: - Internal Helper Methods

    func returnURL(with scheme: String, result: String) -> URL? {
        var components = URLComponents(string: xCallbackTemplate)
        components?.scheme = scheme
        components?.percentEncodedPath = "/vzero/auth/venmo/\(result)"
        return components?.url
    }

    func appSwitchBaseURLComponents() -> URLComponents {
        var components: URLComponents = URLComponents(string: xCallbackTemplate) ?? URLComponents()
        components.scheme = venmoScheme
        components.percentEncodedPath = "/vzero/auth"
        return components
    }
}
