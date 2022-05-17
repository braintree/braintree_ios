import Foundation
#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers
public class BTPayPalNativeCheckoutNonce: BTPaymentMethodNonce {
    
    public override init?(nonce: String) {
        super.init(nonce: nonce, type: "PayPalNative", isDefault: false)
    }
}
