import Foundation

@objcMembers public class BTHTTPError: NSObject {
    ///  The error domain for BTHTTP errors
    public static let domain: String = "com.braintreepayments.BTHTTPErrorDomain"

    ///  Key for userInfo dictionary that contains the NSHTTPURLResponse from server when it returns an HTTP error
    public static let urlResponseKey: String = "com.braintreepayments.BTHTTPURLResponseKey"

    ///  Key for userInfo dictionary that contains the BTJSON body of the HTTP error response
    public static let jsonResponseBodyKey: String = "com.braintreepayments.BTHTTPJSONResponseBodyKey"
}
