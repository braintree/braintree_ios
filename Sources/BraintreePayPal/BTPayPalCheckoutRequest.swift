import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Payment intent.
///
/// - Note: Must be set to BTPayPalRequestIntentSale for immediate payment, `.authorize` to authorize a payment for capture later, or `.order` to create an order. Defaults to `.authorize`. Only applies to PayPal Checkout.
///
/// [Capture payments later reference](https://developer.paypal.com/docs/integration/direct/payments/capture-payment/)
///
/// [Create and process orders reference](https://developer.paypal.com/docs/integration/direct/payments/create-process-order/)
@objc public enum BTPayPalRequestIntent: Int {
    /// Authorize
    case authorize

    /// Sale
    case sale

    /// Order
    case order

    public var stringValue: String {
        switch self {
        case .sale:
            return "sale"
        case .order:
            return "order"
        default:
            return "authorize"
        }
    }
}

///  The call-to-action in the PayPal Checkout flow.
///
///  - Note: By default the final button will show the localized word for "Continue" and implies that the final amount billed is not yet known.
///  Setting the BTPayPalRequest's userAction to `.payNow` changes the button text to "Pay Now", conveying to
///  the user that billing will take place immediately.
@objc public enum BTPayPalRequestUserAction: Int {
    /// Default
    case none

    /// Pay Now
    case payNow

    var stringValue: String {
        switch self {
        case .payNow:
            return "commit"
        default:
            return ""
        }
    }
}

/// Options for the PayPal Checkout flow.
@objcMembers open class BTPayPalCheckoutRequest: BTPayPalRequest {

    // MARK: - Internal Properties
    
    var amount: String
    var intent: BTPayPalRequestIntent
    var userAction: BTPayPalRequestUserAction
    var offerPayLater: Bool
    var currencyCode: String?
    var requestBillingAgreement: Bool

    // MARK: - Initializer

    /// Initializes a PayPal Native Checkout request
    /// - Parameters:
    ///   - amount: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
    ///   - intent: Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    ///   - userAction: Optional: Changes the call-to-action in the PayPal Checkout flow. Defaults to `.none`.
    ///   - offerPayLater: Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    ///   - currencyCode: Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    ///   - requestBillingAgreement: Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement
    ///   during checkout. Defaults to `false`.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - userPhoneNumber: Optional: A user's phone number to initiate a quicker authentication flow in the scenario where the user has a PayPal account
    ///   identified with the same phone number.
    ///   - lineItems: Optional: The line items for this transaction. It can include up to 249 line items.
    public init(
        amount: String,
        intent: BTPayPalRequestIntent = .authorize,
        userAction: BTPayPalRequestUserAction = .none,
        offerPayLater: Bool = false,
        currencyCode: String? = nil,
        requestBillingAgreement: Bool = false,
        userAuthenticationEmail: String? = nil,
        userPhoneNumber: BTPayPalPhoneNumber? = nil,
        lineItems: [BTPayPalLineItem]? = nil
    ) {
        self.amount = amount
        self.intent = intent
        self.userAction = userAction
        self.offerPayLater = offerPayLater
        self.currencyCode = currencyCode
        self.requestBillingAgreement = requestBillingAgreement
        super.init(
            hermesPath: "v1/paypal_hermes/create_payment_resource",
            paymentType: .checkout,
            lineItems: lineItems,
            userAuthenticationEmail: userAuthenticationEmail,
            userPhoneNumber: userPhoneNumber
        )
    }

    // MARK: Internal Methods

    override func parameters(
        with configuration: BTConfiguration,
        universalLink: URL? = nil,
        isPayPalAppInstalled: Bool = false
    ) -> [String: Any] {
        var baseParameters = super.parameters(with: configuration)
        var checkoutParameters: [String: Any] = [
            "intent": intent.stringValue,
            "amount": amount,
            "offer_pay_later": offerPayLater
        ]

        let currencyCode = currencyCode != nil ? currencyCode : configuration.json?["paypal"]["currencyIsoCode"].asString()

        if currencyCode != nil {
            checkoutParameters["currency_iso_code"] = currencyCode
        }

        if userAction != .none, var experienceProfile = baseParameters["experience_profile"] as? [String: Any] {
            experienceProfile["user_action"] = userAction.stringValue
            baseParameters["experience_profile"] = experienceProfile
        }

        if requestBillingAgreement != false {
            checkoutParameters["request_billing_agreement"] = requestBillingAgreement

            if billingAgreementDescription != nil {
                checkoutParameters["billing_agreement_details"] = ["description": billingAgreementDescription]
            }
        }

        if shippingAddressOverride != nil {
            checkoutParameters["line1"] = shippingAddressOverride?.streetAddress
            checkoutParameters["line2"] = shippingAddressOverride?.extendedAddress
            checkoutParameters["city"] = shippingAddressOverride?.locality
            checkoutParameters["state"] = shippingAddressOverride?.region
            checkoutParameters["postal_code"] = shippingAddressOverride?.postalCode
            checkoutParameters["country_code"] = shippingAddressOverride?.countryCodeAlpha2
            checkoutParameters["recipient_name"] = shippingAddressOverride?.recipientName
        }

        return baseParameters.merging(checkoutParameters) { $1 }
    }
}
