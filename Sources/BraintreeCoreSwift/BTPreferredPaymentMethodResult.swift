import Foundation

///  Contains information about which payment methods are preferred on the device.
///  This class is currently in beta and may change in future releases.
@objcMembers public class BTPreferredPaymentMethodsResult: NSObject {

    ///  :nodoc:
    ///  True if PayPal is a preferred payment method. False otherwise.
    public var isPayPalPreferred: Bool = false

    ///  :nodoc:
    ///  True if Venmo app is installed on the customer's device. False otherwise.
    public var isVenmoPreferred: Bool = false

    init(json: BTJSON? = nil, venmoInstalled: Bool = false) {
        // TODO: does this need to be public?
        let paypalPreferred: Bool = json?["data"]["preferredPaymentMethods"]["paypalPreferred"].isTrue ?? false ? true : false
        self.isPayPalPreferred = paypalPreferred
        self.isVenmoPreferred = venmoInstalled
    }
}
