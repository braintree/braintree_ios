import Foundation
import PayPalCheckout

@objcMembers
public class BTPayPalNativeCheckoutRequest: NSObject {
    public let amount: String
    
    public init(amount: String) {
        self.amount = amount
    }
}
