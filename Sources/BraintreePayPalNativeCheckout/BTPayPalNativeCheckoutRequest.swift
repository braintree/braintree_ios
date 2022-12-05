#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

///  Payment intent.
///
///  - Note: Must be set to `.sale` for immediate payment, `.authorize` to authorize a payment for capture later, or `.order` to create an order. Defaults to `authorize`.
///  - SeeAlso: see https://developer.paypal.com/docs/integration/direct/payments/capture-payment/ Capture payments later
///  - SeeAlso: https://developer.paypal.com/docs/integration/direct/payments/create-process-order/ Create and process orders
@objc public enum BTPayPalNativeRequestIntent: Int {
    /// Authorize
    case authorize

    /// Sale
    case sale

    /// Order
    case order
}

/// Options for the PayPal Checkout flow.
@objcMembers public class BTPayPalNativeCheckoutRequest: BTPayPalNativeRequest {
    
    // MARK: - Public Properties
    // NEXT_MAJOR_VERSION: subclass BTPayPalCheckoutRequest once BraintreePayPal is in Swift as this contains duplicate logic of BTPayPalRequest.
    // We should remove this duplication and subclass directly once BraintreePayPal is converted to Swift.

    /// Used for a one-time payment.
    ///
    /// Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
    public let amount: String

    /// Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    public var intent: BTPayPalNativeRequestIntent

    /// Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    public var offerPayLater: Bool
    
    /// Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///
    /// - Note: See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    public var currencyCode: String?
    
    /// Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement during checkout.
    public var requestBillingAgreement: Bool

    /// Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set `requestBillingAgreement` to `true` on your `BTPayPalNativeVaultRequest`.
    public var billingAgreementDescription: String?

    // MARK: - Internal Properties

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

    /// Initializes a PayPal Native Checkout request
    /// - Parameters:
    ///   - amount: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.'
    ///   - intent: Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    ///   and is limited to 7 digits before the decimal point.
    ///   - offerPayLater: Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    ///   - currencyCode: Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    ///   - requestBillingAgreement: Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement during checkout.
    ///   - billingAgreementDescription: Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also
    ///   set `requestBillingAgreement` to `true` on your `BTPayPalNativeVaultRequest`.
    public init(
        amount: String,
        intent: BTPayPalNativeRequestIntent = .authorize,
        offerPayLater: Bool = false,
        currencyCode: String? = nil,
        requestBillingAgreement: Bool = false,
        billingAgreementDescription: String? = nil
    ) {
        self.amount = amount
        self.intent = intent
        self.offerPayLater = offerPayLater
        self.currencyCode = currencyCode
        self.requestBillingAgreement = requestBillingAgreement
        self.billingAgreementDescription = billingAgreementDescription

        super.init(hermesPath: "v1/paypal_hermes/create_payment_resource", paymentType: .checkout)
    }
}
