import Foundation
#if canImport(PayPalCheckout)
import PayPalCheckout
#endif
#if canImport(BraintreeCore)
import BraintreeCore
#endif

public class BTPayPalNativeCheckoutClient: NSObject {
    
    public func tokenize() {
        // TODO: Launch native checkout flow
    }
}
