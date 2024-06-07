import Foundation

/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
@objcMembers public class BTCoreConstants: NSObject {

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public static var braintreeSDKVersion: String = "6.20.0"

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public static let callbackURLScheme: String = "sdk.ios.braintree"

    /// URL Scheme for Venmo App
    public static let venmoURLScheme: String = "com.venmo.touch.v2"

    /// URL Scheme for PayPal App
    public static let payPalURLScheme: String = "paypal-app-switch-checkout"

    static let apiVersion: String = "2016-10-07"
    
    static let graphQLVersion: String = "2018-03-06"

    static let payPalProductionURL = URL(string: "https://api.paypal.com")!
    
    static let payPalSandboxURL = URL(string: "https://api.sandbox.paypal.com")!

    // MARK: - BTHTTPError Constants

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// The error domain for BTHTTP errors
    public static let httpErrorDomain: String = "com.braintreepayments.BTHTTPErrorDomain"

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Key for userInfo dictionary that contains the NSHTTPURLResponse from server when it returns an HTTP error
    public static let urlResponseKey: String = "com.braintreepayments.BTHTTPURLResponseKey"

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Key for userInfo dictionary that contains the BTJSON body of the HTTP error response
    public static let jsonResponseBodyKey: String = "com.braintreepayments.BTHTTPJSONResponseBodyKey"
}
