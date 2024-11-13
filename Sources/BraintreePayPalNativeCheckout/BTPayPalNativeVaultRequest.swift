import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

@available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
/// Options for the PayPal Vault flow.
@objcMembers public class BTPayPalNativeVaultRequest: BTPayPalVaultBaseRequest {

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
        super.init(offerCredit: offerCredit)
        self.billingAgreementDescription = billingAgreementDescription
    }
}
