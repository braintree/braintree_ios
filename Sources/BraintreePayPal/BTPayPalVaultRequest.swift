import Foundation

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: BTPayPalVaultBaseRequest {

    // MARK: - Public Properties

    /// Optional: Used to determine if the customer will use the PayPal app switch flow.
    /// Defaults to `false`.
    /// - Note: This property is currently available in limited release
    public var enablePayPalAppSwitch: Bool

    // MARK: - Initializer

    /// Initializes a PayPal Native Vault request
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - enablePayPalAppSwitch: Optional: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`.
    public init(offerCredit: Bool = false, enablePayPalAppSwitch: Bool = false) {
        self.enablePayPalAppSwitch = enablePayPalAppSwitch
        super.init(offerCredit: offerCredit)
    }
}
