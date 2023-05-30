import Foundation

/// :nodoc:
@_documentation(visibility: private)
@objcMembers public class BTCoreConstants: NSObject {

    public static var braintreeSDKVersion: String = "6.0.0-beta3"

    public static var apiVersion: String = "2016-10-07"
    
    public static var graphQLVersion: String = "2018-03-06"
    
    public static let callbackURLScheme: String = "sdk.ios.braintree"

    // MARK: - BTHTTPError Constants
    // NEXT_MAJOR_VERSION (v7): When the entire SDK is in Swift we will likely want to move these properties into the BTHTTPError enum
    // and make it public. We cannot do that currently since the enum is used in Obj-C modules and tests and you cannot expose enums
    // with associated values to Obj-C (only Int enums).

    /// The error domain for BTHTTP errors
    public static let httpErrorDomain: String = "com.braintreepayments.BTHTTPErrorDomain"

    /// Key for userInfo dictionary that contains the NSHTTPURLResponse from server when it returns an HTTP error
    public static let urlResponseKey: String = "com.braintreepayments.BTHTTPURLResponseKey"

    /// Key for userInfo dictionary that contains the BTJSON body of the HTTP error response
    public static let jsonResponseBodyKey: String = "com.braintreepayments.BTHTTPJSONResponseBodyKey"

}
