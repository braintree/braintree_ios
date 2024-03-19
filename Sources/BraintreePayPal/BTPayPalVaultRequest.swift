import UIKit
import BraintreeCore

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
    
    // MARK: Public Methods
    
    /// :nodoc: Exposed publicly for use by PayPal Native Checkout module. This method is not covered by semantic versioning.
    @_documentation(visibility: private)
    public override func parameters(with configuration: BTConfiguration) -> [String: Any] {
        let baseParameters = super.parameters(with: configuration)
        
        if enablePayPalAppSwitch {
            let appSwitchParameters: [String: Any] = [
                "launch_paypal_app": enablePayPalAppSwitch,
                "os_version": UIDevice.current.systemVersion,
                "os_type": UIDevice.current.systemName,
                "merchant_app_return_url": "https://www.fake-url.com" // TODO: - Add value from BTAppContextSwitcher.shared.universalLink
            ]
            return baseParameters.merging(appSwitchParameters) { $1 }
        }

        return baseParameters
    }
}
