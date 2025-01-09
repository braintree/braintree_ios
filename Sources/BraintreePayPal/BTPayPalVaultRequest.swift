import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: NSObject, PayPalRequest {

    // MARK: - Internal Properties
    
    let hermesPath: String
    let paymentType: BTPayPalPaymentType
    
    var offerCredit: Bool
    var enablePayPalAppSwitch: Bool = false
    var billingAgreementDescription: String?
    var displayName: String?
    var isShippingAddressEditable: Bool = false
    var isShippingAddressRequired: Bool = false
    var landingPageType: BTPayPalRequestLandingPageType?
    var lineItems: [BTPayPalLineItem]?
    var localeCode: BTPayPalLocaleCode?
    var merchantAccountID: String?
    var recurringBillingDetails: BTPayPalRecurringBillingDetails?
    var recurringBillingPlanType: BTPayPalRecurringBillingPlanType?
    var riskCorrelationID: String?
    var shippingAddressOverride: BTPostalAddress?
    var userAuthenticationEmail: String?
    var userPhoneNumber: BTPayPalPhoneNumber?
    
    // MARK: - Initializers

    /// Initializes a PayPal Vault request for the PayPal App Switch flow
    /// - Parameters:
    ///   - userAuthenticationEmail: Required: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - enablePayPalAppSwitch: Required: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`. This property is currently in beta and may change or be removed in future releases.
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    /// - Warning: This initializer should be used for merchants using the PayPal App Switch flow. This feature is currently in beta and may change or be removed in future releases.
    /// - Note: The PayPal App Switch flow currently only supports the production environment.
    public convenience init(
        userAuthenticationEmail: String,
        enablePayPalAppSwitch: Bool,
        offerCredit: Bool = false
    ) {
        self.init(offerCredit: offerCredit, userAuthenticationEmail: userAuthenticationEmail)
        self.enablePayPalAppSwitch = enablePayPalAppSwitch
    }

    /// Initializes a PayPal Vault request
    /// - Parameters:
    ///   - offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    ///   - billingAgreementDescription: Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set
    ///   - currencyCode: Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    ///   See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
    ///   - displayName: Optional: The merchant name displayed inside of the PayPal flow; defaults to the company name on your Braintree account
    ///   - isShippingAddressEditable: Defaults to false. Set to true to enable user editing of the shipping address.
    ///   - isShippingAddressRequired: Defaults to false. When set to true, the shipping address selector will be displayed.
    ///   - landingPageType: Optional: Landing page type. Defaults to `.none`.
    ///     - Note: Setting the BTPayPalRequest's landingPageType changes the PayPal page to display when a user lands on the PayPal site to complete the payment.
    ///        `.login` specifies a PayPal account login page is used.
    ///        `.billing` specifies a non-PayPal account landing page is used.
    ///   - lineItems: Optional: The line items for this transaction. It can include up to 249 line items.
    ///   - localeCode: Optional: A locale code to use for the transaction.
    ///   - merchantAccountID: Optional: A non-default merchant account to use for tokenization.
    ///   - recurringBillingDetails: Optional: Recurring billing product details.
    ///   - recurringBillingPlanType: Optional: Recurring billing plan type, or charge pattern.
    ///   - riskCorrelationID: Optional: A risk correlation ID created with Set Transaction Context on your server.
    ///   - shippingAddressOverride: Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
    ///   - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///   - userPhoneNumber: Optional: A user's phone number to initiate a quicker authentication flow in the scenario where the user has a PayPal account
    /// identified with the same phone number.
    public init(
        offerCredit: Bool = false,
        billingAgreementDescription: String? = nil,
        displayName: String? = nil,
        isShippingAddressEditable: Bool = false,
        isShippingAddressRequired: Bool = false,
        landingPageType: BTPayPalRequestLandingPageType = .none,
        lineItems: [BTPayPalLineItem]? = nil,
        localeCode: BTPayPalLocaleCode = .none,
        merchantAccountID: String? = nil,
        recurringBillingDetails: BTPayPalRecurringBillingDetails? = nil,
        recurringBillingPlanType: BTPayPalRecurringBillingPlanType? = nil,
        riskCorrelationID: String? = nil,
        shippingAddressOverride: BTPostalAddress? = nil,
        userAuthenticationEmail: String? = nil,
        userPhoneNumber: BTPayPalPhoneNumber? = nil
    ) {
        self.hermesPath = "v1/paypal_hermes/setup_billing_agreement"
        self.paymentType = .vault
        self.offerCredit = offerCredit
        self.billingAgreementDescription = billingAgreementDescription
        self.displayName = displayName
        self.isShippingAddressEditable = isShippingAddressEditable
        self.isShippingAddressRequired = isShippingAddressRequired
        self.landingPageType = landingPageType
        self.lineItems = lineItems
        self.localeCode = localeCode
        self.merchantAccountID = merchantAccountID
        self.recurringBillingDetails = recurringBillingDetails
        self.recurringBillingPlanType = recurringBillingPlanType
        self.riskCorrelationID = riskCorrelationID
        self.shippingAddressOverride = shippingAddressOverride
        self.userAuthenticationEmail = userAuthenticationEmail
        self.userPhoneNumber = userPhoneNumber
    }

    func parameters(
        with configuration: BTConfiguration,
        universalLink: URL? = nil,
        isPayPalAppInstalled: Bool = false
    ) -> [String: Any] {
        var experienceProfile: [String: Any] = [:]

        experienceProfile["no_shipping"] = !isShippingAddressRequired
        experienceProfile["brand_name"] = displayName != nil ? displayName : configuration.json?["paypal"]["displayName"].asString()

        if landingPageType?.stringValue != nil {
            experienceProfile["landing_page_type"] = landingPageType?.stringValue
        }

        if localeCode?.stringValue != nil {
            experienceProfile["locale_code"] = localeCode?.stringValue
        }

        experienceProfile["address_override"] = shippingAddressOverride != nil ? !isShippingAddressEditable : false

        var baseParameters: [String: Any] = [:]

        if merchantAccountID != nil {
            baseParameters["merchant_account_id"] = merchantAccountID
        }

        if riskCorrelationID != nil {
            baseParameters["correlation_id"] = riskCorrelationID
        }
        
        if let lineItems, !lineItems.isEmpty {
            let lineItemsArray = lineItems.compactMap { $0.requestParameters() }
            baseParameters["line_items"] = lineItemsArray
        }
        
        if let userAuthenticationEmail, !userAuthenticationEmail.isEmpty {
            baseParameters["payer_email"] = userAuthenticationEmail
        }
        
        if let userPhoneNumberDict = try? userPhoneNumber?.toDictionary() {
            baseParameters["phone_number"] = userPhoneNumberDict
        }

        baseParameters["return_url"] = BTCoreConstants.callbackURLScheme + "://\(Self.callbackURLHostAndPath)success"
        baseParameters["cancel_url"] = BTCoreConstants.callbackURLScheme + "://\(Self.callbackURLHostAndPath)cancel"
        baseParameters["experience_profile"] = experienceProfile

        if let universalLink, enablePayPalAppSwitch, isPayPalAppInstalled {
            let appSwitchParameters: [String: Any] = [
                "launch_paypal_app": enablePayPalAppSwitch,
                "os_version": UIDevice.current.systemVersion,
                "os_type": UIDevice.current.systemName,
                "merchant_app_return_url": universalLink.absoluteString
            ]

            return baseParameters.merging(appSwitchParameters) { $1 }
        }

        if let recurringBillingPlanType {
            baseParameters["plan_type"] = recurringBillingPlanType.rawValue
        }

        if let recurringBillingDetails {
            baseParameters["plan_metadata"] = recurringBillingDetails.parameters()
        }

        var vaultParameters: [String: Any] = ["offer_paypal_credit": offerCredit]

        if let billingAgreementDescription {
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
