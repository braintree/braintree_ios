import Foundation

/// :nodoc:
@objcMembers public class BTCoreConstants: NSObject {

    // TODO: update release script to update this constant during the release process
    /// :nodoc:
    public static var braintreeSDKVersion: String = "6.0.0-beta1"

    /// :nodoc:
    public static var apiVersion: String = "2016-10-07"
    
    /// :nodoc:
    public static var graphQLVersion: String = "2018-03-06"

    /// :nodoc:
    public static var networkConnectionLostCode: Int = -1005
    
    /// :nodoc:
    public static let callbackURLScheme: String = "sdk.ios.braintree"
}
