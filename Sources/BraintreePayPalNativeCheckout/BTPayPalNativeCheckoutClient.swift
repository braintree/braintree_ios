import Foundation
#if canImport(PayPalCheckout)
import PayPalCheckout
#endif
#if canImport(BraintreeCore)
import BraintreeCore
#endif

public class BTPayPalNativeCheckoutClient: NSObject {
    
    public init(clientID: String, returnUrl: String) {
        let config = CheckoutConfig(clientID: clientID, returnUrl: returnUrl)
        
        Checkout.set(config: config)
    }
}
