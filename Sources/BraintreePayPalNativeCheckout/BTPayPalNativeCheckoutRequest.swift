#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/// Options for the PayPal Checkout and PayPal Checkout with Vault flows.
@objc public class BTPayPalNativeCheckoutRequest: BTPayPalCheckoutRequest, BTPayPalNativeRequest {

    let paymentType: BTPayPalPaymentType = .checkout

    let hermesPath: String = "v1/paypal_hermes/create_payment_resource"

    var intentAsString: String {
        switch intent {
        case .sale:
            return "sale"
        case .order:
            return "order"
        default:
            return "authorize"
        }
    }

    func parameters(with configuration: BTConfiguration) -> [AnyHashable: Any] {
        let baseParams = getBaseParameters(with: configuration)

        let billingAgreementDictionary: [AnyHashable: Any]? = {
            if let description = billingAgreementDescription {
                return ["description": description]
            }
            else {
                return nil
            }
        }()

        let paypalParams = [
            // Values from BTPayPalCheckoutRequest
            "intent": intentAsString,
            "amount": amount,
            "offer_pay_later": offerPayLater,
            "currency_iso_code": currencyCode ?? configuration.json["paypal"]["currencyIsoCode"].asString(),
            "request_billing_agreement": requestBillingAgreement ? true : nil,
            "billing_agreement_details": requestBillingAgreement ? billingAgreementDictionary : nil,
            "line1": shippingAddressOverride?.streetAddress,
            "line2": shippingAddressOverride?.extendedAddress,
            "city": shippingAddressOverride?.locality,
            "state": shippingAddressOverride?.region,
            "postal_code": shippingAddressOverride?.postalCode,
            "country_code": shippingAddressOverride?.countryCodeAlpha2,
            "recipient_name": shippingAddressOverride?.recipientName,
        ].compactMapValues { $0 }

        // Combining the base parameters with the parameters defined here - if there is a conflict,
        // choose the values defined here
        return baseParams.merging(paypalParams) { _, new in new }
    }
}
