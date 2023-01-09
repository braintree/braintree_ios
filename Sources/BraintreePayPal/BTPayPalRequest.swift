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
@objc public protocol BTPayPalRequest where Self: NSObject {
    
    // MARK: - Public Properties
    
    /// Defaults to false. When set to true, the shipping address selector will be displayed.
    var isShippingAddressRequired: Bool { get set }
    
    /// Defaults to false. Set to true to enable user editing of the shipping address.
    /// - Note: Only applies when `shippingAddressOverride` is set.
    var isShippingAddressEditable: Bool { get set }
    
    ///  Optional: A locale code to use for the transaction.
    var localeCode: BTPayPalLocaleCode { get set }
    
    /// Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
    var shippingAddressOverride: BTPostalAddress? { get set }
    
    /// Optional: Landing page type. Defaults to `.none`.
    /// - Note: Setting the BTPayPalRequest's landingPageType changes the PayPal page to display when a user lands on the PayPal site to complete the payment.
    ///  `.login` specifies a PayPal account login page is used.
    ///  `.billing` specifies a non-PayPal account landing page is used.
    var landingPageType: BTPayPalRequestLandingPageType { get set }
    
    /// Optional: The merchant name displayed inside of the PayPal flow; defaults to the company name on your Braintree account
    var displayName: String? { get set }
    
    /// Optional: A non-default merchant account to use for tokenization.
    var merchantAccountID: String? { get set }
    
    /// Optional: The line items for this transaction. It can include up to 249 line items.
    var lineItems: [BTPayPalLineItem]? { get set }
    
    /// Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set
    ///  `requestBillingAgreement` to `true` on your `BTPayPalCheckoutRequest`.
    var billingAgreementDescription: String? { get set }
    
    /// Optional: The window used to present the ASWebAuthenticationSession.
    /// - Note: If your app supports multitasking, you must set this property to ensure that the ASWebAuthenticationSession is presented on the correct window.
    var activeWindow: UIWindow? { get set }
    
    /// Optional: A risk correlation ID created with Set Transaction Context on your server.
    var riskCorrelationId: String? { get set }
    
    var hermesPath: String { get }
    
    var paymentType: BTPayPalPaymentType { get }
    
    // MARK: - Internal Methods
    
    func parameters(with configuration: BTConfiguration) -> [String: Any]
}

extension BTPayPalRequest {
    
    // TODO: these can't be used by invoking BTPayPalRequest.callbackURLScheme
    static var callbackURLHostAndPath: String { "onetouch/v1/" }
    static var callbackURLScheme: String { "sdk.ios.braintree" }
    
    // MARK: Internal Methods

    func baseParameters(with configuration: BTConfiguration) -> [String: Any] {
        var experienceProfile: [String: Any] = [:]

        experienceProfile["no_shipping"] = !isShippingAddressRequired
        experienceProfile["brand_name"] = displayName != nil ? displayName : configuration.json?["paypal"]["displayName"].asString()

        if landingPageType.stringValue != nil {
            experienceProfile["landing_page_type"] = landingPageType.stringValue
        }

        if localeCode.stringValue != nil {
            experienceProfile["locale_code"] = localeCode.stringValue
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

        parameters["return_url"] = Self.callbackURLScheme + "://\(Self.callbackURLHostAndPath)success"
        parameters["cancel_url"] = Self.callbackURLScheme + "://\(Self.callbackURLHostAndPath)cancel"
        parameters["experience_profile"] = experienceProfile

        return parameters
    }
}
