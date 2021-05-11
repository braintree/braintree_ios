import BraintreeCore

/**
 Base options for PayPal flows.

 - Note: Do not instantiate this class directly. Instead, use `BTPayPalNativeCheckoutRequest` or `BTPayPalNativeVaultRequest`.
 */
@objc public class BTPayPalNativeRequest: NSObject {

    // MARK: - Public

    /**
     Use this option to specify the PayPal page to display when a user lands on the PayPal site to complete the payment.
     */
    @objc public enum LandingPageType: Int {
        /// Default
        case `default` // Obj-C enums cannot be nil; this default option is used to make `landingPageType` optional for merchants
        /// Login
        case login
        /// Billing
        case billing
    }

    /**
     Defaults to false. When set to true, the shipping address selector will be displayed.
     */
    @objc public var isShippingAddressRequired: Bool = false

    /**
     Defaults to false. Set to true to enable user editing of the shipping address.

     - Note: Only applies when `shippingAddressOverride` is set.
     */
    @objc public var isShippingAddressEditable: Bool = false

    /**
     A locale code to use for the transaction.

     - Note:  Supported locales are:

     `da_DK`,
     `de_DE`,
     `en_AU`,
     `en_GB`,
     `en_US`,
     `es_ES`,
     `es_XC`,
     `fr_CA`,
     `fr_FR`,
     `fr_XC`,
     `id_ID`,
     `it_IT`,
     `ja_JP`,
     `ko_KR`,
     `nl_NL`,
     `no_NO`,
     `pl_PL`,
     `pt_BR`,
     `pt_PT`,
     `ru_RU`,
     `sv_SE`,
     `th_TH`,
     `tr_TR`,
     `zh_CN`,
     `zh_HK`,
     `zh_TW`,
     `zh_XC`.
     */
    @objc public var localeCode: String?

    /**
     A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
     */
    @objc public var shippingAddressOverride: BTPostalAddress?

    /**
     Landing page type. Defaults to `.default`.

     - Note: Setting the BTPayPalRequest's landingPageType changes the PayPal page to display when a user lands on the PayPal site to complete the payment. BTPayPalRequestLandingPageTypeLogin specifies a PayPal account login page is used. BTPayPalRequestLandingPageTypeBilling specifies a non-PayPal account landing page is used.
     */
    @objc public var landingPageType: LandingPageType = .default

    /**
     The merchant name displayed inside of the PayPal flow; defaults to the company name on your merchant account.
     */
    @objc public var displayName: String?

    /**
     A non-default merchant account to use for tokenization.
     */
    @objc public var merchantAccountID: String?

    /**
     The line items for this transaction. Can include up to 249 line items.
     */
    @objc public var lineItems: [BTPayPalNativeLineItem]?

    /**
     Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set requestBillingAgreement to true on your BTPayPalCheckoutRequest.
     */
    @objc public var billingAgreementDescription: String?

    // MARK: - Internal

    private static let callbackURLHostAndPath = "onetouch/v1/"
    private static let callbackURLScheme = "sdk.ios.braintree"

    enum PaymentType {
        case checkout
        case vault
    }

    var landingPageTypeAsString: String? {
        switch(landingPageType) {
        case .login:
            return "login"
        case .billing:
            return "billing"
        default:
            return nil
        }
    }

    func parameters(with configuration: BTConfiguration) -> [String : Any] {
        var parameters: [String : Any] = [:]
        var experienceProfile: [String : Any] = [:]

        experienceProfile["no_shipping"] = !isShippingAddressRequired

        experienceProfile["brand_name"] = self.displayName ?? configuration.json["paypal"]["displayName"].asString()

        if let landingPage = landingPageTypeAsString {
            experienceProfile["landing_page_type"] = landingPage
        }

        if let locale = localeCode {
            experienceProfile["locale_code"] = locale
        }

        if let id = merchantAccountID {
            parameters["merchant_account_id"] = id
        }

        if shippingAddressOverride != nil {
            experienceProfile["address_override"] = !isShippingAddressEditable
        } else {
            experienceProfile["address_override"] = false
        }

        if let items = lineItems {
            parameters["line_items"] = items.map { $0.requestParameters }
        }

        parameters["return_url"] = "\(BTPayPalNativeRequest.callbackURLScheme)://\(BTPayPalNativeRequest.callbackURLHostAndPath)success"
        parameters["cancel_url"] = "\(BTPayPalNativeRequest.callbackURLScheme)://\(BTPayPalNativeRequest.callbackURLHostAndPath)cancel"
        parameters["experience_profile"] = experienceProfile

        return parameters
    }
}
