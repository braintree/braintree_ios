import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: BTPayPalVaultBaseRequest {

    // MARK: - Public Properties

    /// Optional: Used to determine if the customer will use the PayPal app switch flow.
    /// Defaults to `false`.
    /// - Note: This property is currently in beta and may change or be removed in future releases.
    public var enablePayPalAppSwitch: Bool

    /// Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    public var userAuthenticationEmail: String?

    /// The URL to use for the PayPal app switch flow. Must be a valid HTTPS URL dedicated to Braintree app switch returns.
    var universalLink: URL?

    // MARK: - Initializer

    /// Initializes a PayPal Vault request
    /// - Note: This initializer should be used for merchants using the PayPal App Switch flow
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Optional: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`.
    ///   This property is currently in beta and may change or be removed in future releases.
    ///   - universalLink: The URL to use for the PayPal app switch flow. Must be a valid HTTPS URL dedicated to Braintree app switch returns.
    public convenience init(
        userAuthenticationEmail: String,
        enablePayPalAppSwitch: Bool,
        universalLink: URL,
        offerCredit: Bool = false
    ) {
        self.init(offerCredit: offerCredit, userAuthenticationEmail: userAuthenticationEmail, enablePayPalAppSwitch: enablePayPalAppSwitch)
        self.universalLink = universalLink
    }

    /// Initializes a PayPal Vault request
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Optional: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`.
    ///   This property is currently in beta and may change or be removed in future releases.
    public init(offerCredit: Bool = false, userAuthenticationEmail: String? = nil, enablePayPalAppSwitch: Bool = false) {
        self.enablePayPalAppSwitch = enablePayPalAppSwitch
        self.userAuthenticationEmail = userAuthenticationEmail
        super.init(offerCredit: offerCredit)
    }

    public override func parameters(with configuration: BTConfiguration) -> [String: Any] {
        var baseParameters = super.parameters(with: configuration)

        if let userAuthenticationEmail {
            baseParameters["payer_email"] = userAuthenticationEmail
        }
        
        if enablePayPalAppSwitch, let universalLink {
            let appSwitchParameters: [String: Any] = [
                "launch_paypal_app": enablePayPalAppSwitch,
                "os_version": UIDevice.current.systemVersion,
                "os_type": UIDevice.current.systemName,
                "merchant_app_return_url": universalLink.absoluteString
            ]
            return baseParameters.merging(appSwitchParameters) { $1 }
        }

        return baseParameters
    }
}
