#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/// Options for the PayPal Vault flow.
@objcMembers public class BTPayPalNativeVaultRequest: BTPayPalNativeRequest {

    // MARK: - Public Properties
    // NEXT_MAJOR_VERSION: subclass BTPayPalVaultRequest once BraintreePayPal is in Swift as this contains duplicate logic of BTPayPalRequest.
    // We should remove this duplication and subclass directly once BraintreePayPal is converted to Swift.

    /// Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    public var offerCredit: Bool

    /// Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set `requestBillingAgreement` to `true` on your `BTPayPalCheckoutRequest`.
    public var billingAgreementDescription: String?

    // MARK: - Initializer

    /// Initializes a PayPal Native Vault request
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - billingAgreementDescription: Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set
    ///   `requestBillingAgreement` to `true` on your `BTPayPalCheckoutRequest`.
    public init(
        offerCredit: Bool = false,
        billingAgreementDescription: String? = nil
    ) {
        self.offerCredit = offerCredit
        self.billingAgreementDescription = billingAgreementDescription

        super.init(hermesPath: "v1/paypal_hermes/setup_billing_agreement", paymentType: .vault)
    }
}
