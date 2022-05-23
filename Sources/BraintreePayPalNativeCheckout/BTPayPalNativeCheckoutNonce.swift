import Foundation

@objcMembers
public class BTPayPalNativeCheckoutNonce: NSObject {
    public let nonce: String
    
    init(nonce: String) {
        self.nonce = nonce
    }
}
