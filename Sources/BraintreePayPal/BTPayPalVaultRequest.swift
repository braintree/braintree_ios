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
    }

    // MARK: - Internal Properties

    // TODO: Make internal once rest of PayPal module is in Swift
    public let hermesPath: String = "v1/paypal_hermes/setup_billing_agreement"
    public let paymentType: BTPayPalPaymentType = .vault

    // TODO: Make internal once rest of PayPal module is in Swift
    public func parameters(with configuration: BTConfiguration) -> [String: Any] {
        let baseParameters: [String: Any] = baseParameters(with: configuration)
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
