import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// TODO: Entire class be internal and likely a struct once rest of Venmo is in Swift
// TODO: methods can all be non-static likely when we convert the rest of Venmo to Swift
@objcMembers public class BTVenmoAppSwitchRequestURL: NSObject {

    static let kXCallbackTemplate: String = "scheme://x-callback-url/path"
    static let kVenmoScheme: String = "com.venmo.touch.v2"

    /// The base app switch URL for Venmo. Does not include specific parameters.
    // TODO: property can be internal once rest of Venmo is in Swift
    public static var baseAppSwitchURL: URL? {
        appSwitchBaseURLComponents()?.url
    }

    /// Create an app switch URL
    /// - Parameters:
    ///   - merchantID: The merchant ID
    ///   - accessToken: The access token used by the Venmo app to tokenize on behalf of the merchant
    ///   - returnURLScheme:  The return URL scheme, e.g. "com.yourcompany.Your-App.payments"
    ///   - bundleDisplayName: The bundle display name for the current app
    ///   - environment: The environment, e.g. "production" or "sandbox"
    ///   - paymentContextID: The Venmo payment context ID (optional)
    ///   - metadata: Additional Braintree metadata
    ///   - Returns: The resulting URL, or `nil` if any of the required parameters are `nil`.
    // TODO: method can be internal once rest of Venmo is in Swift
    @objc(appSwitchURLForMerchantID:accessToken:returnURLScheme:bundleDisplayName:environment:paymentContextID:metadata:)
    public static func appSwitchURLForMerchantID(
        _ merchantID: String?,
        accessToken: String?,
        returnURLScheme: String?,
        bundleDisplayName: String?,
        environment: String?,
        paymentContextID: String?,
        metadata: BTClientMetadata?
    ) -> URL? {
        let successReturnURL = returnURL(with: returnURLScheme, result: "success")
        let errorReturnURL = returnURL(with: returnURLScheme, result: "error")
        let cancelReturnURL = returnURL(with: returnURLScheme, result: "cancel")

        guard let successReturnURL, let errorReturnURL, let cancelReturnURL, let accessToken, let metadata, let bundleDisplayName, let environment, let merchantID else {
            return nil
        }

        let venmoMetadata: [String: String?] = [
            "version": BTCoreConstants.braintreeSDKVersion,
            "sessionId": metadata.sessionID,
            "integration": metadata.integrationString,
            "platform": "ios"
        ]

        let braintreeData: [String: Any] = ["_meta": venmoMetadata]

        var base64EncodedBraintreeData: String? = nil
        do {
            let serializedBraintreeData = try JSONSerialization.data(withJSONObject: braintreeData)
            base64EncodedBraintreeData = serializedBraintreeData.base64EncodedString()
        } catch {
            // TODO: handle error
        }

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
        components?.percentEncodedQuery = BTURLUtils.queryString(from: appSwitchParameters as NSDictionary)
        return components?.url
    }

    // MARK: - Internal Helper Methods

    static func returnURL(with scheme: String?, result: String) -> URL? {
        var components = URLComponents(string: kXCallbackTemplate)
        components?.scheme = scheme
        components?.percentEncodedPath = "/vzero/auth/venmo/\(result)"
        return components?.url
    }

    static func appSwitchBaseURLComponents() -> URLComponents? {
        var components = URLComponents(string: kXCallbackTemplate)
        components?.scheme = kVenmoScheme
        components?.percentEncodedPath = "/vzero/auth"
        return components
    }
}
