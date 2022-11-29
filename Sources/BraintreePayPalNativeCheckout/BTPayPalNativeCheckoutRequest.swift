#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/// Options for the PayPal Checkout and PayPal Checkout with Vault flows.
@objcMembers public class BTPayPalNativeCheckoutRequest: BTPayPalRequest, BTPayPalNativeRequest {
    
    // MARK: - Public Properties
    
    // next_major_version: obtain the public properties below by subclassing BTPayPalCheckoutRequest once it is converted to Swift.
    
    /// Optional: Payment intent. Defaults to BTPayPalRequestIntentAuthorize. Only applies to PayPal Checkout.
    public var intent: BTPayPalRequestIntent = .authorize
    
    /// Used for a one-time payment.
    ///
    /// Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
    public let amount: String
    
    /// Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to false. Only available with PayPal Checkout.
    public var offerPayLater: Bool = false
    
    /// Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///
    /// - Note: See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    public let currencyCode: String?
    
    /// Optional: If set to true, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement during checkout.
    public var requestBillingAgreement: Bool = false

    // MARK: - Internal Properties
    
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
    
    // MARK: - Initializer
    
    public init(
        intent: BTPayPalRequestIntent = .authorize,
        amount: String,
        offerPayLater: Bool = false,
        currencyCode: String? = nil,
        requestBillingAgreement: Bool = false
    ) {
        self.intent = intent
        self.amount = amount
        self.offerPayLater = offerPayLater
        self.currencyCode = currencyCode
        self.requestBillingAgreement = requestBillingAgreement
    }
    
    // MARK: - Internal Methods

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
