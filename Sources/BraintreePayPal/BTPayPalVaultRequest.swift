import Foundation

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: BTPayPalVaultBaseRequest {

    // MARK: - Public Properties

    /// Optional: Used to determine if the customer will use the PayPal app switch flow.
    /// Defaults to `false`.
    /// - Note: This property is currently in beta and may change or be removed in future releases.
    public var enablePayPalAppSwitch: Bool

    // MARK: - Initializer

    /// Initializes a PayPal Vault request
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Optional: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`.
    ///   This property is currently in beta and may change or be removed in future releases.
    public init(offerCredit: Bool = false, userAuthenticationEmail: String? = nil, enablePayPalAppSwitch: Bool = false) {
        self.enablePayPalAppSwitch = enablePayPalAppSwitch
        super.init(offerCredit: offerCredit, userAuthenticationEmail: userAuthenticationEmail)
    }
}
