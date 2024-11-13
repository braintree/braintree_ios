import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objc public enum BTPayPalPaymentType: Int {
    
    /// Checkout
    case checkout

    /// Vault
    case vault
    
    var stringValue: String {
        switch self {
        case .vault:
            return "paypal-ba"
        case .checkout:
            return "paypal-single-payment"
        }
    }
}

/// Use this option to specify the PayPal page to display when a user lands on the PayPal site to complete the payment.
@objc public enum BTPayPalRequestLandingPageType: Int {

    /// Default
    case none // Obj-C enums cannot be nil; this default option is used to make `landingPageType` optional for merchants

    /// Login
    case login

    /// Billing
    case billing

    var stringValue: String? {
        switch self {
        case .login:
            return "login"

        case .billing:
            return "billing"

        default:
            return nil
        }
    }
}

/// Base options for PayPal Checkout and PayPal Vault flows.
/// - Note: Do not instantiate this class directly. Instead, use BTPayPalCheckoutRequest or BTPayPalVaultRequest.
@objcMembers open class BTPayPalRequest: NSObject {

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
    var billingAgreementDescription: String?
    var riskCorrelationID: String?
    
    // MARK: - Static Properties
    
    static let callbackURLHostAndPath: String = "onetouch/v1/"

    // MARK: - Initializer

    /// Initialize a new `BTPayPalRequest`
    /// - Parameters:
    ///    - hermesPath: Required :nodoc: Exposed publicly for use by PayPal Native Checkout module. This property is not covered by semantic versioning.
    ///    - paymentType: Required: The payment type, either checkout or vault :nodoc: Exposed publicly for use by PayPal Native Checkout module. This property is not covered by semantic versioning.
    ///    - isShippingAddressRequired: Defaults to false. When set to true, the shipping address selector will be displayed.
    ///    - isShippingAddressEditable: Defaults to false. Set to true to enable user editing of the shipping address. Only applies when `shippingAddressOverride` is set.
    ///    - localeCode: Optional: A locale code to use for the transaction.
    ///    - shippingAddressOverride: Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
    ///    - landingPageType: Optional: Landing page type. Defaults to `.none`.  
    ///     - Note: Setting the BTPayPalRequest's landingPageType changes the PayPal page to display when a user lands on the PayPal site to complete the payment.
    ///        `.login` specifies a PayPal account login page is used.
    ///        `.billing` specifies a non-PayPal account landing page is used.
    ///    - displayName: Optional: The merchant name displayed inside of the PayPal flow; defaults to the company name on your Braintree account
    ///    - merchantAccountID: Optional: A non-default merchant account to use for tokenization.
    ///    - billingAgreementDescription: Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set
    ///        `requestBillingAgreement` to `true` on your `BTPayPalCheckoutRequest`.
    ///    - riskCorrelationID: Optional: A risk correlation ID created with Set Transaction Context on your server.
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
        billingAgreementDescription: String? = nil,
        riskCorrelationID: String? = nil
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
        self.billingAgreementDescription = billingAgreementDescription
        self.riskCorrelationID = riskCorrelationID
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

        parameters["return_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)success"
        parameters["cancel_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)cancel"
        parameters["experience_profile"] = experienceProfile

        return parameters
    }
}
