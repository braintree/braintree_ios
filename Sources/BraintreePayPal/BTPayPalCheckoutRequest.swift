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
@objcMembers public class BTPayPalCheckoutRequest: NSObject, BTPayPalRequest {
    
    // MARK: - Internal Properties
    
    let hermesPath = "v1/paypal_hermes/create_payment_resource"
    let paymentType: BTPayPalPaymentType = .checkout
    
    var amount: String
    var intent: BTPayPalRequestIntent
    var userAction: BTPayPalRequestUserAction
    var offerPayLater: Bool
    var billingAgreementDescription: String?
    var contactInformation: BTContactInformation?
    var contactPreference: BTContactPreference = .none
    var currencyCode: String?
    var displayName: String?
    var enablePayPalAppSwitch: Bool = false
    var isShippingAddressEditable: Bool = false
    var isShippingAddressRequired: Bool = false
    var landingPageType: BTPayPalRequestLandingPageType?
    var lineItems: [BTPayPalLineItem]?
    var localeCode: BTPayPalLocaleCode?
    var merchantAccountID: String?
    var requestBillingAgreement: Bool
    var riskCorrelationID: String?
    var shippingAddressOverride: BTPostalAddress?
    var shippingCallbackURL: URL?
    var shopperSessionID: String?
    var userAuthenticationEmail: String?
    var userPhoneNumber: BTPayPalPhoneNumber?
    
    // MARK: - Initializer

    /// Initializes a PayPal Checkout request for the PayPal App Switch flow
    /// - Parameters:
    ///   - userAuthenticationEmail: Required: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Required: Used to determine if the customer will use the PayPal app switch flow.
    ///   - amount: Required: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
    ///   - intent: Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    ///   - userAction: Optional: Changes the call-to-action in the PayPal Checkout flow. Defaults to `.none`.
    ///   - offerPayLater: Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    ///   - currencyCode: Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    ///   - requestBillingAgreement: Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement
    ///   during checkout. Defaults to `false`.
    ///   - contactPreference: Optional: Preference for the contact information section within the payment flow. Defaults to `BTContactPreference.noContactInformation` if not set.
    /// - Warning: This initializer should be used for merchants using the PayPal App Switch flow. This feature is currently in beta and may change or be removed in future releases.
    /// - Note: The PayPal App Switch flow currently only supports the production environment.
    public convenience init(
        userAuthenticationEmail: String,
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
            contactPreference: contactPreference,
            currencyCode: currencyCode,
            enablePayPalAppSwitch: enablePayPalAppSwitch,
            requestBillingAgreement: requestBillingAgreement,
            userAuthenticationEmail: userAuthenticationEmail
        )
    }

    /// Initializes a PayPal Checkout request
    /// - Parameters:
    ///   - amount: Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
    ///   - intent: Optional: Payment intent. Defaults to `.authorize`. Only applies to PayPal Checkout.
    ///   - userAction: Optional: Changes the call-to-action in the PayPal Checkout flow. Defaults to `.none`.
    ///   - offerPayLater: Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to `false`. Only available with PayPal Checkout.
    ///   - billingAgreementDescription: Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set
    ///   - contactInformation: Optional: Contact information of the recipient for the order
    ///   - contactPreference: Optional: Preference for the contact information section within the payment flow. Defaults to `BTContactPreference.noContactInformation` if not set
    ///   - currencyCode: Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    ///   - displayName: Optional: The merchant name displayed inside of the PayPal flow; defaults to the company name on your Braintree account
    ///   - enablePayPalAppSwitch: Required: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`. This property is currently in beta and may change or be removed in future releases.
    ///   - isShippingAddressEditable: Defaults to false. Set to true to enable user editing of the shipping address.
    ///   - isShippingAddressRequired: Defaults to false. When set to true, the shipping address selector will be displayed.
    ///   - landingPageType: Optional: Landing page type. Defaults to `.none`.
    ///     - Note: Setting the BTPayPalRequest's landingPageType changes the PayPal page to display when a user lands on the PayPal site to complete the payment.
    ///        `.login` specifies a PayPal account login page is used.
    ///        `.billing` specifies a non-PayPal account landing page is used.
    ///   - lineItems: Optional: The line items for this transaction. It can include up to 249 line items.
    ///   - localeCode: Optional: A locale code to use for the transaction.
    ///   - merchantAccountID: Optional: A non-default merchant account to use for tokenization.
    ///   - requestBillingAgreement: Optional: If set to `true`, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement
    ///   during checkout. Defaults to `false`.
    ///   - riskCorrelationID: Optional: A risk correlation ID created with Set Transaction Context on your server.
    ///   - shippingAddressOverride: Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
    ///   - shippingCallbackURL: Optional: Server side shipping callback URL to be notified when a customer updates their shipping address or options. A callback request will be sent to the merchant server at this URL.
    ///   - shopperSessionID: Optional: The shopper session ID returned from your shopper insights server SDK integration.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - userPhoneNumber: Optional: A user's phone number to initiate a quicker authentication flow in the scenario where the user has a PayPal account
    ///   identified with the same phone number.
    public init(
        amount: String,
        intent: BTPayPalRequestIntent = .authorize,
        userAction: BTPayPalRequestUserAction = .none,
        offerPayLater: Bool = false,
        billingAgreementDescription: String? = nil,
        contactInformation: BTContactInformation? = nil,
        contactPreference: BTContactPreference = .none,
        currencyCode: String? = nil,
        displayName: String? = nil,
        enablePayPalAppSwitch: Bool = false,
        isShippingAddressEditable: Bool = false,
        isShippingAddressRequired: Bool = false,
        landingPageType: BTPayPalRequestLandingPageType = .none,
        lineItems: [BTPayPalLineItem]? = nil,
        localeCode: BTPayPalLocaleCode = .none,
        merchantAccountID: String? = nil,
        requestBillingAgreement: Bool = false,
        riskCorrelationID: String? = nil,
        shippingAddressOverride: BTPostalAddress? = nil,
        shippingCallbackURL: URL? = nil,
        shopperSessionID: String? = nil,
        userAuthenticationEmail: String? = nil,
        userPhoneNumber: BTPayPalPhoneNumber? = nil
    ) {
        self.amount = amount
        self.intent = intent
        self.userAction = userAction
        self.offerPayLater = offerPayLater
        self.billingAgreementDescription = billingAgreementDescription
        self.contactInformation = contactInformation
        self.contactPreference = contactPreference
        self.currencyCode = currencyCode
        self.displayName = displayName
        self.enablePayPalAppSwitch = enablePayPalAppSwitch
        self.isShippingAddressEditable = isShippingAddressEditable
        self.isShippingAddressRequired = isShippingAddressRequired
        self.landingPageType = landingPageType
        self.lineItems = lineItems
        self.localeCode = localeCode
        self.merchantAccountID = merchantAccountID
        self.requestBillingAgreement = requestBillingAgreement
        self.riskCorrelationID = riskCorrelationID
        self.shippingAddressOverride = shippingAddressOverride
        self.shippingCallbackURL = shippingCallbackURL
        self.shopperSessionID = shopperSessionID
        self.userAuthenticationEmail = userAuthenticationEmail
        self.userPhoneNumber = userPhoneNumber
    }
    
    // MARK: Internal Methods
    
    func encodedPostBodyWith(
        configuration: BTConfiguration,
        isPayPalAppInstalled: Bool = false,
        universalLink: URL? = nil
    ) -> Encodable {
        PayPalCheckoutPOSTBody(
            payPalRequest: self,
            configuration: configuration,
            isPayPalAppInstalled: isPayPalAppInstalled,
            universalLink: universalLink
        )
    }
}
