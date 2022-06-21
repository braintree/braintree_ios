#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/**
 Options for the PayPal Vault flow.
 */
@objc public class BTPayPalNativeVaultRequest: BTPayPalVaultRequest, BTPayPalNativeRequest {

    let hermesPath: String

    let paymentType: BTPayPalPaymentType = .vault

    /// Initializes a PayPal Vault request.
    @objc public override init() {
        self.hermesPath = "v1/paypal_hermes/setup_billing_agreement"

        super.init()
    }

    func parameters(with configuration: BTConfiguration) -> [AnyHashable : Any] {

        let baseParams = getBaseParameters(with: configuration)

        // Should only include shipping params if they exist
        let shippingParams: [AnyHashable: Any?]? = {
            if let shippingOverride = shippingAddressOverride {
                return [
                  "line1": shippingOverride.streetAddress,
                  "line2": shippingOverride.extendedAddress,
                  "city": shippingOverride.locality,
                  "state": shippingOverride.region,
                  "postal_code": shippingOverride.postalCode,
                  "country_code": shippingOverride.countryCodeAlpha2,
                  "recipient_name": shippingOverride.recipientName,
                ]
            }
            else {
                return nil
            }
        }()

        let params: [AnyHashable : Any?] = [
          "description": self.billingAgreementDescription,
          "offer_paypal_credit": offerCredit,
          "shipping_address": shippingParams,
        ]

        let prunedParams = params.compactMapValues { $0 }

        // Combining the base parameters with the parameters defined here - if there is a conflict,
        // choose the values defined here
        return baseParams.merging(prunedParams) {_, new in new }
    }
}
