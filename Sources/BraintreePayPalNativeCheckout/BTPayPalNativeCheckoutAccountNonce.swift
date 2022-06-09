import Foundation

@objcMembers
public class BTPayPalNativeCheckoutAccountNonce: NSObject {
    public let nonce: String
    
    init(nonce: String) {
        self.nonce = nonce
    }
}
