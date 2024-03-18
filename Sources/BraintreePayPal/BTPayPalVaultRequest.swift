import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Options for the PayPal Vault flow.
@objcMembers open class BTPayPalVaultBaseRequest: BTPayPalRequest {

    // MARK: - Public Properties

    /// Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    public var offerCredit: Bool

    // MARK: - Initializer

    /// Initializes a PayPal Native Vault request
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - enablePayPalAppSwitch: Optional: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`.
    public init(offerCredit: Bool = false) {
        self.offerCredit = offerCredit

        super.init(hermesPath: "v1/paypal_hermes/setup_billing_agreement", paymentType: .vault)
    }

    // MARK: Public Methods

    /// :nodoc: Exposed publicly for use by PayPal Native Checkout module. This method is not covered by semantic versioning.
    @_documentation(visibility: private)
    public override func parameters(with configuration: BTConfiguration) -> [String: Any] {
        let baseParameters = super.parameters(with: configuration)
        var vaultParameters: [String: Any] = ["offer_paypal_credit": offerCredit]

        if billingAgreementDescription != nil {
            vaultParameters["description"] = billingAgreementDescription
        }

        if let shippingAddressOverride {
            let shippingAddressParameters: [String: String?] = [
                "line1": shippingAddressOverride.streetAddress,
                "line2": shippingAddressOverride.extendedAddress,
                "city": shippingAddressOverride.locality,
                "state": shippingAddressOverride.region,
                "postal_code": shippingAddressOverride.postalCode,
                "country_code": shippingAddressOverride.countryCodeAlpha2,
                "recipient_name": shippingAddressOverride.recipientName
            ]

            vaultParameters["shipping_address"] = shippingAddressParameters
        }

        return baseParameters.merging(vaultParameters) { $1 }
    }

}

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
