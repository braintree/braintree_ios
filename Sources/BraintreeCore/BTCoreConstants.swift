import Foundation

/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
@objcMembers public class BTCoreConstants: NSObject {

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public static var braintreeSDKVersion: String = "6.0.0-beta4"

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public static let callbackURLScheme: String = "sdk.ios.braintree"

    static var apiVersion: String = "2016-10-07"
    
    static var graphQLVersion: String = "2018-03-06"

    // MARK: - BTHTTPError Constants
    // NEXT_MAJOR_VERSION (v7): When the entire SDK is in Swift we will likely want to move these properties into the BTHTTPError enum
    // and make it public. We cannot do that currently since the enum is used in Obj-C modules and tests and you cannot expose enums
    // with associated values to Obj-C (only Int enums).

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
