import Foundation

/// Contains information about a PayPal credit amount
@objcMembers public class BTPayPalCreditFinancingAmount: NSObject {
    
    /// 3 letter currency code as defined by <a href="http://www.iso.org/iso/home/standards/currency_codes.htm">ISO 4217</a>.
    public let currency: String
    
    /// An amount defined by <a href="http://www.iso.org/iso/home/standards/currency_codes.htm">ISO 4217</a> for the given currency.
    public let value: String
    
    init(currency: String, value: String) {
        self.currency = currency
        self.value = value
    }
}
