import Foundation
import BraintreeCore

/**
 Options for the PayPal Vault flow.
 */
@objc public class BTPayPalNativeVaultRequest: BTPayPalNativeRequest {

    // MARK: - Public

    /**
     Optional: Offers PayPal Credit if the customer qualifies. Defaults to false.
     */
    @objc public var offerCredit: Bool = false

    // MARK: - Internal

    let hermesPath = "v1/paypal_hermes/setup_billing_agreement"
    let paymentType = BTPayPalNativeRequest.PaymentType.vault

    override func parameters(with configuration: BTConfiguration) -> [String : Any] {
        var parameters = super.parameters(with: configuration)

        if let billingAgreementDesc = billingAgreementDescription {
            parameters["description"] = billingAgreementDesc
        }

        parameters["offer_paypal_credit"] = offerCredit

        if let addressOverride = shippingAddressOverride {
            var shippingAddressParams: [String : String] = [:]
            shippingAddressParams["line1"] = addressOverride.streetAddress
            shippingAddressParams["line2"] = addressOverride.extendedAddress
            shippingAddressParams["city"] = addressOverride.locality
            shippingAddressParams["state"] = addressOverride.region
            shippingAddressParams["postal_code"] = addressOverride.postalCode
            shippingAddressParams["country_code"] = addressOverride.countryCodeAlpha2
            shippingAddressParams["recipient_name"] = addressOverride.recipientName
            parameters["shipping_address"] = shippingAddressParams
        }

        return parameters
    }
}
