import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: BTPayPalRequest {

    // MARK: - Public Properties

    /// Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    public var offerCredit: Bool

    // MARK: - Initializer

    /// Initializes a PayPal Native Vault request
    /// - Parameter offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    public init(offerCredit: Bool = false) {
        self.offerCredit = offerCredit

        super.init(hermesPath: "v1/paypal_hermes/setup_billing_agreement", paymentType: .vault)
    }
}
