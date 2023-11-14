import Foundation

/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
@objcMembers public class BTCoreConstants: NSObject {

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public static var braintreeSDKVersion: String = "6.8.0"

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public static let callbackURLScheme: String = "sdk.ios.braintree"

    static let apiVersion: String = "2016-10-07"
    
    static let graphQLVersion: String = "2018-03-06"

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
