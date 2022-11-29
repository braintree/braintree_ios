#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/// Options for the PayPal Vault flow.
@objcMembers public class BTPayPalNativeVaultRequest: BTPayPalNativeRequest {

    // MARK: - Public Properties
    // next_major_version: subclass BTPayPalVaultRequest once BraintreePayPal is in Swift.

    /// Optional: Offers PayPal Credit if the customer qualifies. Defaults to false.
    public var offerCredit: Bool

    /// Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set requestBillingAgreement to true on your BTPayPalCheckoutRequest.
    public var billingAgreementDescription: String?

    // MARK: - Initializer

    public init(
        offerCredit: Bool = false,
        billingAgreementDescription: String? = nil
    ) {
        self.offerCredit = offerCredit
        self.billingAgreementDescription = billingAgreementDescription

        super.init(hermesPath: "v1/paypal_hermes/setup_billing_agreement", paymentType: .vault)
    }
}
