import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// TODO: Make internal once rest of PayPal module is in Swift
@objc public protocol BTPayPalRequestable: AnyObject {
    @objc optional var hermesPath: String { get }
    @objc optional var paymentType: BTPayPalPaymentType { get }

    @objc(parametersWithConfiguration:)
    optional func parameters(with configuration: BTConfiguration) -> [String: Any]
}

@objc public enum BTPayPalPaymentType: Int {
    /// Checkout
    case checkout

    /// Vault
    case vault
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
@objcMembers public class BTPayPalRequest: NSObject, BTPayPalRequestable {

    // MARK: - Public Properties

    /// Defaults to false. When set to true, the shipping address selector will be displayed.
    public var isShippingAddressRequired: Bool

    /// Defaults to false. Set to true to enable user editing of the shipping address.
    /// - Note: Only applies when `shippingAddressOverride` is set.
    public var isShippingAddressEditable: Bool

    ///  Optional: A locale code to use for the transaction.
    ///  - Note: Supported locales are:
    ///
    /// `da_DK`,
    /// `de_DE`,
    /// `en_AU`,
    /// `en_GB`,
    /// `en_US`,
    /// `es_ES`,
    /// `es_XC`,
    /// `fr_CA`,
    /// `fr_FR`,
    /// `fr_XC`,
    /// `id_ID`,
    /// `it_IT`,
    /// `ja_JP`,
    /// `ko_KR`,
    /// `nl_NL`,
    /// `no_NO`,
    /// `pl_PL`,
    /// `pt_BR`,
    /// `pt_PT`,
    /// `ru_RU`,
    /// `sv_SE`,
    /// `th_TH`,
    /// `tr_TR`,
    /// `zh_CN`,
    /// `zh_HK`,
    /// `zh_TW`,
    /// `zh_XC`.
    public var localeCode: String?

    /// Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
    public var shippingAddressOverride: BTPostalAddress?

    /// Optional: Landing page type. Defaults to `.none`.
    /// - Note: Setting the BTPayPalRequest's landingPageType changes the PayPal page to display when a user lands on the PayPal site to complete the payment.
    ///  `.login` specifies a PayPal account login page is used.
    ///  `.billing` specifies a non-PayPal account landing page is used.
    public var landingPageType: BTPayPalRequestLandingPageType

    /// Optional: The merchant name displayed inside of the PayPal flow; defaults to the company name on your Braintree account
    public var displayName: String?

    /// Optional: A non-default merchant account to use for tokenization.
    public var merchantAccountID: String?

    /// Optional: The line items for this transaction. It can include up to 249 line items.
    public var lineItems: [BTPayPalLineItem]?

    /// Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set
    ///  `requestBillingAgreement` to `true` on your `BTPayPalCheckoutRequest`.
    public var billingAgreementDescription: String?

    /// Optional: The window used to present the ASWebAuthenticationSession.
    /// - Note: If your app supports multitasking, you must set this property to ensure that the ASWebAuthenticationSession is presented on the correct window.
    public var activeWindow: UIWindow?

    /// Optional: A risk correlation ID created with Set Transaction Context on your server.
    public var riskCorrelationId: String?

    // MARK: - Internal Properties

    // TODO: Make internal once rest of PayPal module is in Swift
    public static let callbackURLHostAndPath: String = "onetouch/v1/"
    public static let callbackURLScheme: String = "sdk.ios.braintree"

    // MARK: - Initializer

    init(
        isShippingAddressRequired: Bool = false,
        isShippingAddressEditable: Bool = false,
        localeCode: String? = nil,
        shippingAddressOverride: BTPostalAddress? = nil,
        landingPageType: BTPayPalRequestLandingPageType = .none,
        displayName: String? = nil,
        merchantAccountID: String? = nil,
        lineItems: [BTPayPalLineItem]? = nil,
        billingAgreementDescription: String? = nil,
        activeWindow: UIWindow? = nil,
        riskCorrelationId: String? = nil
    ) {
        self.isShippingAddressRequired = isShippingAddressRequired
        self.isShippingAddressEditable = isShippingAddressEditable
        self.localeCode = localeCode
        self.shippingAddressOverride = shippingAddressOverride
        self.landingPageType = landingPageType
        self.displayName = displayName
        self.merchantAccountID = merchantAccountID
        self.lineItems = lineItems
        self.billingAgreementDescription = billingAgreementDescription
        self.activeWindow = activeWindow
        self.riskCorrelationId = riskCorrelationId
    }

    // MARK: Internal Methods

    func baseParameters(with configuration: BTConfiguration) -> [String: Any] {
        var experienceProfile: [String: Any] = [:]

        experienceProfile["no_shipping"] = !isShippingAddressRequired
        experienceProfile["brand_name"] = displayName != nil ? displayName : configuration.json?["paypal"]["displayName"].asString()

        if landingPageType.stringValue != nil {
            experienceProfile["landing_page_type"] = landingPageType.stringValue
        }

        if localeCode != nil {
            experienceProfile["locale_code"] = localeCode
        }

        experienceProfile["address_override"] = shippingAddressOverride != nil ? !isShippingAddressEditable : false

        var parameters: [String: Any] = [:]

        if merchantAccountID != nil {
            parameters["merchant_account_id"] = merchantAccountID
        }

        if riskCorrelationId != nil {
            parameters["correlation_id"] = riskCorrelationId
        }

        if let lineItems, lineItems.count > 0 {
            let lineItemsArray = lineItems.compactMap { $0.requestParameters() }
            parameters["line_items"] = lineItemsArray
        }

        parameters["return_url"] = BTPayPalRequest.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)success"
        parameters["cancel_url"] = BTPayPalRequest.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)cancel"
        parameters["experience_profile"] = experienceProfile

        return parameters
    }
}
