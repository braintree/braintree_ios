import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Payment intent.
///
/// - Note: Must be set to BTPayPalRequestIntentSale for immediate payment, BTPayPalRequestIntentAuthorize to authorize a payment for capture later, or BTPayPalRequestIntentOrder to create an order. Defaults to BTPayPalRequestIntentAuthorize. Only applies to PayPal Checkout.
///
/// [Capture payments later reference](https://developer.paypal.com/docs/integration/direct/payments/capture-payment/)
///
///[Create and process orders reference](https://developer.paypal.com/docs/integration/direct/payments/create-process-order/)
@objc public enum BTPayPalRequestIntent: Int {
    /// Authorize
    case authorize

    /// Sale
    case sale

    /// Order
    case order
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
}

/// Options for the PayPal Checkout flow.
@objcMembers public class BTPayPalCheckoutRequest: BTPayPalRequest {

    // MARK: - Public Properties

    ///  Used for a one-time payment.
    ///
    ///  Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
    public let amount: String

    /// Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    public var intent: BTPayPalRequestIntent?

    /// Optional: Changes the call-to-action in the PayPal Checkout flow. Defaults to `.default`.
    public var userAction: BTPayPalRequestUserAction

    /// Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    public var offerPayLater: Bool

    /// Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///
    /// - Note: See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    public var currencyCode: String?

    /// Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement during checkout. Defaults to `false`.
    public var requestBillingAgreement: Bool

    // MARK: - Internal Properties

    // TODO: Make internal and move into enum once rest of PayPal module is in Swift
    public var intentAsString: String {
        switch intent {
        case .sale:
            return "sale"
        case .order:
            return "order"
        default:
            return "authorize"
        }
    }

    // TODO: Make internal and move into enum once rest of PayPal module is in Swift
    public var userActionAsString: String {
        switch userAction {
        case .payNow:
            return "commit"
        default:
            return ""
        }
    }

    // TODO: Make internal once rest of PayPal module is in Swift
    public let hermesPath: String = "v1/paypal_hermes/create_payment_resource"
    public let paymentType: BTPayPalPaymentType = .checkout

    // MARK: - Initializer

    /// Initializes a PayPal Native Checkout request
    /// - Parameters:
    ///   - amount: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.'
    ///   - intent: Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    ///   and is limited to 7 digits before the decimal point.
    ///   - offerPayLater: Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    ///   - currencyCode: Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    ///   - requestBillingAgreement: Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement
    ///   during checkout. Defaults to `false`.
    public init(
        amount: String,
        intent: BTPayPalRequestIntent? = .authorize,
        userAction: BTPayPalRequestUserAction = .none,
        offerPayLater: Bool = false,
        currencyCode: String? = nil,
        requestBillingAgreement: Bool = false
    ) {
        self.amount = amount
        self.intent = intent
        self.userAction = userAction
        self.offerPayLater = offerPayLater
        self.currencyCode = currencyCode
        self.requestBillingAgreement = requestBillingAgreement
    }

    // MARK: - Internal methods

    // TODO: Make internal once rest of PayPal module is in Swift
    public func parameters(with configuration: BTConfiguration) -> [String: Any] {
        let baseParameters: [String: Any] = baseParameters(with: configuration)
        var checkoutParameters: [String: Any] = [
            "intent": intentAsString,
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
