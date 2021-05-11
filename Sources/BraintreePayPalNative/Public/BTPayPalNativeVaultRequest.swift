import Foundation

/**
 Options for the PayPal Vault flow.
 */
@objc public class BTPayPalNativeVaultRequest: BTPayPalNativeRequest {

    /**
     Optional: Offers PayPal Credit if the customer qualifies. Defaults to false.
     */
    @objc public var offerCredit: Bool = false
}
