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

/// Options for the PayPal Checkout flow.
@objcMembers open class BTPayPalCheckoutRequest: BTPayPalRequest {

    // MARK: - Public Properties

    ///  Used for a one-time payment.
    ///  Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
    public var amount: String

    /// Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    public var intent: BTPayPalRequestIntent

    /// Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    public var offerPayLater: Bool

    /// Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    /// - Note: See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    public var currencyCode: String?

    /// Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement during checkout. Defaults to `false`.
    public var requestBillingAgreement: Bool
    
    /// Optional: Contact information of the recipient for the order
    public var contactInformation: BTContactInformation?

    /// Optional: Server side shipping callback URL to be notified when a customer updates their shipping address or options. A callback request will be sent to the merchant server at this URL.
    public var shippingCallbackURL: URL?
    
    /// Optional: Preference for the contact information section within the payment flow. Defaults to `BTContactPreference.noContactInformation` if not set.
    public var contactPreference: BTContactPreference = .none

    /// Optional: Provides details to users about their recurring billing amount when using PayPal Checkout with Purchase.
    public var amountBreakdown: BTAmountBreakdown?

    // MARK: - Initializers
    
    /// Initializes a PayPal Checkout request for the PayPal App Switch flow
    /// - Parameters:
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Required: Used to determine if the customer will use the PayPal app switch flow.
    ///   - amount: Required: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
    ///   - intent: Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    ///   - userAction: Optional: Changes the call-to-action in the PayPal Checkout flow. Defaults to `.none`.
    ///   - offerPayLater: Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    ///   - currencyCode: Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    ///   - requestBillingAgreement: Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement
    ///   during checkout. Defaults to `false`.
    /// - Warning: This initializer should be used for merchants using the PayPal App Switch flow. This feature is currently in beta and may change or be removed in future releases.
    /// - Note: The PayPal App Switch flow currently only supports the production environment.
    public convenience init(
        userAuthenticationEmail: String? = nil,
        enablePayPalAppSwitch: Bool,
        amount: String,
        intent: BTPayPalRequestIntent = .authorize,
        userAction: BTPayPalRequestUserAction = .none,
        offerPayLater: Bool = false,
        currencyCode: String? = nil,
        requestBillingAgreement: Bool = false,
        contactPreference: BTContactPreference = .none
    ) {
        self.init(
            amount: amount,
            intent: intent,
            userAction: userAction,
            offerPayLater: offerPayLater,
            currencyCode: currencyCode,
            requestBillingAgreement: requestBillingAgreement,
            userAuthenticationEmail: userAuthenticationEmail
        )
        super.enablePayPalAppSwitch = enablePayPalAppSwitch
    }

    /// Initializes a PayPal Native Checkout request
    /// - Parameters:
    ///   - amount: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.'
    ///   - intent: Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    ///   and is limited to 7 digits before the decimal point.
    ///   - userAction: Optional: Changes the call-to-action in the PayPal Checkout flow. Defaults to `.none`.
    ///   - offerPayLater: Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    ///   - currencyCode: Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    ///   - requestBillingAgreement: Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement
    ///   during checkout. Defaults to `false`.
    ///   - shippingCallbackURL: Optional: Server side shipping callback URL to be notified when a customer updates their shipping address or options.
    ///   A callback request will be sent to the merchant server at this URL.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - recurringBillingDetails: Optional: Recurring billing product details.
    ///   - recurringBillingPlanType: Optional: Recurring billing plan type, or charge pattern.
    ///   - amountBreakdown: Optional: Breakdown of items associated to the total cost.
    public init(
        amount: String,
        intent: BTPayPalRequestIntent = .authorize,
        userAction: BTPayPalRequestUserAction = .none,
        offerPayLater: Bool = false,
        currencyCode: String? = nil,
        requestBillingAgreement: Bool = false,
        shippingCallbackURL: URL? = nil,
        userAuthenticationEmail: String? = nil,
        recurringBillingDetails: BTPayPalRecurringBillingDetails? = nil,
        recurringBillingPlanType: BTPayPalRecurringBillingPlanType? = nil,
        amountBreakdown: BTAmountBreakdown? = nil
    ) {
        self.amount = amount
        self.intent = intent
        self.offerPayLater = offerPayLater
        self.currencyCode = currencyCode
        self.requestBillingAgreement = requestBillingAgreement
        self.shippingCallbackURL = shippingCallbackURL
        self.amountBreakdown = amountBreakdown
        
        super.init(
            hermesPath: "v1/paypal_hermes/create_payment_resource",
            paymentType: .checkout,
            userAuthenticationEmail: userAuthenticationEmail,
            recurringBillingDetails: recurringBillingDetails,
            recurringBillingPlanType: recurringBillingPlanType,
            userAction: userAction
        )
    }

    // MARK: Public Methods

    /// :nodoc: Exposed publicly for use by PayPal Native Checkout module. This method is not covered by semantic versioning.
    @_documentation(visibility: private)
    public override func parameters(
        with configuration: BTConfiguration,
        universalLink: URL? = nil,
        fallbackUrlScheme: String? = nil,
        isPayPalAppInstalled: Bool = false
    ) -> [String: Any] {
        var baseParameters = super.parameters(
            with: configuration,
            universalLink: universalLink,
            fallbackUrlScheme: fallbackUrlScheme,
            isPayPalAppInstalled: isPayPalAppInstalled
        )
        var checkoutParameters: [String: Any] = [
            "intent": intent.stringValue,
            "amount": amount,
            "offer_pay_later": offerPayLater
        ]

        let currencyCode = currencyCode != nil ? currencyCode : configuration.json?["paypal"]["currencyIsoCode"].asString()

        if currencyCode != nil {
            checkoutParameters["currency_iso_code"] = currencyCode
        }

        if requestBillingAgreement != false {
            checkoutParameters["request_billing_agreement"] = requestBillingAgreement

            if billingAgreementDescription != nil {
                checkoutParameters["billing_agreement_details"] = ["description": billingAgreementDescription]
            }
        }

        if let shippingCallbackURL {
            baseParameters["shipping_callback_url"] = shippingCallbackURL.absoluteString
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

        if let recipientEmail = contactInformation?.recipientEmail {
            checkoutParameters["recipient_email"] = recipientEmail
        }

        if contactPreference != .none {
            checkoutParameters["contact_preference"] = contactPreference.stringValue
        }

        if let recipientPhoneNumber = try? contactInformation?.recipientPhoneNumber?.toDictionary() {
            checkoutParameters["international_phone"] = recipientPhoneNumber
        }

        if let amountBreakdown {
            baseParameters["amount_breakdown"] = amountBreakdown.parameters()
        }

        return baseParameters.merging(checkoutParameters) { $1 }
    }
}
