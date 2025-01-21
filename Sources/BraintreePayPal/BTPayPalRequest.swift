import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Defines the structure and requirements for PayPal Checkout and PayPal Vault flows.
protocol PayPalRequest {
    var hermesPath: String { get }
    var paymentType: BTPayPalPaymentType { get }
    var billingAgreementDescription: String? { get }
    var displayName: String? { get }
    var isShippingAddressEditable: Bool { get }
    var isShippingAddressRequired: Bool { get }
    var landingPageType: BTPayPalRequestLandingPageType? { get }
    var lineItems: [BTPayPalLineItem]? { get }
    var localeCode: BTPayPalLocaleCode? { get }
    var merchantAccountID: String? { get }
    var riskCorrelationID: String? { get }
    var shippingAddressOverride: BTPostalAddress? { get }
    var userAuthenticationEmail: String? { get }
    var userPhoneNumber: BTPayPalPhoneNumber? { get }
    
    // MARK: - Static Properties
    
    static var callbackURLHostAndPath: String { get }
    
    func parameters(
        with configuration: BTConfiguration,
        universalLink: URL?,
        isPayPalAppInstalled: Bool
    ) -> [String: Any]
}

extension PayPalRequest {
    
    static var callbackURLHostAndPath: String {
        "onetouch/v1/"
    }
}

/// Base options for PayPal Checkout and PayPal Vault flows.
/// - Note: Do not instantiate this class directly. Instead, use BTPayPalCheckoutRequest or BTPayPalVaultRequest.
@objcMembers open class BTPayPalRequest: NSObject, PayPalRequest {

    // MARK: - Internal Properties
    
    var hermesPath: String
    var paymentType: BTPayPalPaymentType
    var isShippingAddressRequired: Bool
    var isShippingAddressEditable: Bool
    var localeCode: BTPayPalLocaleCode?
    var shippingAddressOverride: BTPostalAddress?
    var landingPageType: BTPayPalRequestLandingPageType?
    var displayName: String?
    var merchantAccountID: String?
    var lineItems: [BTPayPalLineItem]?
    var billingAgreementDescription: String?
    var riskCorrelationID: String?
    var userAuthenticationEmail: String?
    var userPhoneNumber: BTPayPalPhoneNumber?

    // MARK: - Initializer

    /// Initialize a new `BTPayPalRequest`
    /// - Parameters:
    ///    - hermesPath: Required :nodoc: The hermes path or endpoint URI path. This property is not covered by semantic versioning.
    ///    - paymentType: Required :nodoc: The payment type, either checkout or vault. This property is not covered by semantic versioning.
    ///    - isShippingAddressRequired: Defaults to false. When set to true, the shipping address selector will be displayed.
    ///    - isShippingAddressEditable: Defaults to false. Set to true to enable user editing of the shipping address.
    ///     - Note: Only applies when `shippingAddressOverride` is set.
    ///    - localeCode: Optional: A locale code to use for the transaction.
    ///    - shippingAddressOverride: Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
    ///    - landingPageType: Optional: Landing page type. Defaults to `.none`.
    ///     - Note: Setting the BTPayPalRequest's landingPageType changes the PayPal page to display when a user lands on the PayPal site to complete the payment.
    ///        `.login` specifies a PayPal account login page is used.
    ///        `.billing` specifies a non-PayPal account landing page is used.
    ///    - displayName: Optional: The merchant name displayed inside of the PayPal flow; defaults to the company name on your Braintree account
    ///    - merchantAccountID: Optional: A non-default merchant account to use for tokenization.
    ///    - lineItems: Optional: The line items for this transaction. It can include up to 249 line items.
    ///    - billingAgreementDescription: Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set
    ///        `requestBillingAgreement` to `true` on your `BTPayPalCheckoutRequest`.
    ///    - riskCorrelationID: Optional: A risk correlation ID created with Set Transaction Context on your server.
    ///    - userAuthenticationEmail: Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    ///    - userPhoneNumber: Optional: A user's phone number to initiate a quicker authentication flow in the scenario where the user has a PayPal account identified with the same phone number.
    init(
        hermesPath: String,
        paymentType: BTPayPalPaymentType,
        isShippingAddressRequired: Bool = false,
        isShippingAddressEditable: Bool = false,
        localeCode: BTPayPalLocaleCode = .none,
        shippingAddressOverride: BTPostalAddress? = nil,
        landingPageType: BTPayPalRequestLandingPageType = .none,
        displayName: String? = nil,
        merchantAccountID: String? = nil,
        lineItems: [BTPayPalLineItem]? = nil,
        billingAgreementDescription: String? = nil,
        riskCorrelationID: String? = nil,
        userAuthenticationEmail: String? = nil,
        userPhoneNumber: BTPayPalPhoneNumber? = nil
    ) {
        self.hermesPath = hermesPath
        self.paymentType = paymentType
        self.isShippingAddressRequired = isShippingAddressRequired
        self.isShippingAddressEditable = isShippingAddressEditable
        self.localeCode = localeCode
        self.shippingAddressOverride = shippingAddressOverride
        self.landingPageType = landingPageType
        self.displayName = displayName
        self.merchantAccountID = merchantAccountID
        self.lineItems = lineItems
        self.billingAgreementDescription = billingAgreementDescription
        self.riskCorrelationID = riskCorrelationID
        self.userAuthenticationEmail = userAuthenticationEmail
        self.userPhoneNumber = userPhoneNumber
    }

    // MARK: Internal Methods

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

        var parameters: [String: Any] = [:]

        if merchantAccountID != nil {
            parameters["merchant_account_id"] = merchantAccountID
        }

        if riskCorrelationID != nil {
            parameters["correlation_id"] = riskCorrelationID
        }
        
        if let lineItems, !lineItems.isEmpty {
            let lineItemsArray = lineItems.compactMap { $0.requestParameters() }
            parameters["line_items"] = lineItemsArray
        }
        
        if let userAuthenticationEmail, !userAuthenticationEmail.isEmpty {
            parameters["payer_email"] = userAuthenticationEmail
        }
        
        if let userPhoneNumberDict = try? userPhoneNumber?.toDictionary() {
            parameters["phone_number"] = userPhoneNumberDict
        }

        parameters["return_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)success"
        parameters["cancel_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)cancel"
        parameters["experience_profile"] = experienceProfile

        return parameters
    }
}
