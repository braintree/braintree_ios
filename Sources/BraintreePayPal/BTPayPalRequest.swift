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

    // MARK: - Public Properties

    /// Defaults to false. When set to true, the shipping address selector will be displayed.
    public var isShippingAddressRequired: Bool

    /// Defaults to false. Set to true to enable user editing of the shipping address.
    /// - Note: Only applies when `shippingAddressOverride` is set.
    public var isShippingAddressEditable: Bool

    ///  Optional: A locale code to use for the transaction.
    public var localeCode: BTPayPalLocaleCode

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

    /// Optional: A risk correlation ID created with Set Transaction Context on your server.
    public var riskCorrelationID: String?

    /// :nodoc: Exposed publicly for use by PayPal Native Checkout module. This property is not covered by semantic versioning.
    @_documentation(visibility: private)
    public var hermesPath: String

    /// :nodoc: Exposed publicly for use by PayPal Native Checkout module. This property is not covered by semantic versioning.
    @_documentation(visibility: private)
    public var paymentType: BTPayPalPaymentType

    /// Optional: A user's phone number to initiate a quicker authentication flow in the scenario where the user has a PayPal account
    /// identified with the same phone number.
    public var userPhoneNumber: BTPayPalPhoneNumber?

    /// Optional: User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    public var userAuthenticationEmail: String?

    /// Optional: The shopper session ID returned from your shopper insights server SDK integration.
    public var shopperSessionID: String?

    /// Optional: Recurring billing plan type, or charge pattern.
    public var recurringBillingPlanType: BTPayPalRecurringBillingPlanType?
    
    /// Optional: Recurring billing product details.
    public var recurringBillingDetails: BTPayPalRecurringBillingDetails?
    
    /// Optional: Changes the call-to-action in the PayPal flow. Defaults to `.none`.
    public var userAction: BTPayPalRequestUserAction

    // MARK: - Internal Properties
    
    /// Optional: Used to determine if the customer will use the PayPal app switch flow. Defaults to `false`.
    /// - Warning: This property is currently in beta and may change or be removed in future releases.
    var enablePayPalAppSwitch: Bool

    // MARK: - Static Properties
    
    static let callbackURLHostAndPath: String = "onetouch/v1/"

    // MARK: - Initializer

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
        riskCorrelationId: String? = nil,
        userPhoneNumber: BTPayPalPhoneNumber? = nil,
        userAuthenticationEmail: String? = nil,
        enablePayPalAppSwitch: Bool = false,
        shopperSessionID: String? = nil,
        recurringBillingDetails: BTPayPalRecurringBillingDetails? = nil,
        recurringBillingPlanType: BTPayPalRecurringBillingPlanType? = nil,
        userAction: BTPayPalRequestUserAction = .none
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
        self.riskCorrelationID = riskCorrelationId
        self.userPhoneNumber = userPhoneNumber
        self.userAuthenticationEmail = userAuthenticationEmail
        self.enablePayPalAppSwitch = enablePayPalAppSwitch
        self.shopperSessionID = shopperSessionID
        self.recurringBillingDetails = recurringBillingDetails
        self.recurringBillingPlanType = recurringBillingPlanType
        self.userAction = userAction
    }

    // MARK: Public Methods

    // swiftlint:disable cyclomatic_complexity
    /// :nodoc: Exposed publicly for use by PayPal Native Checkout module. This method is not covered by semantic versioning.
    @_documentation(visibility: private)
    public func parameters(
        with configuration: BTConfiguration,
        universalLink: URL? = nil,
        fallbackUrlScheme: String? = nil,
        isPayPalAppInstalled: Bool = false
    ) -> [String: Any] {
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
        
        if userAction != .none {
            experienceProfile["user_action"] = userAction.stringValue
        }

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

        if let userPhoneNumberDictionary = try? userPhoneNumber?.toDictionary(), !userPhoneNumberDictionary.isEmpty {
            parameters["payer_phone"] = userPhoneNumberDictionary
        }

        if let userAuthenticationEmail, !userAuthenticationEmail.isEmpty {
            parameters["payer_email"] = userAuthenticationEmail
        }

        if let shopperSessionID {
            parameters["shopper_session_id"] = shopperSessionID
        }

        parameters["return_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)success"
        parameters["cancel_url"] = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)cancel"
        parameters["experience_profile"] = experienceProfile
        
        if let recurringBillingPlanType {
            parameters["plan_type"] = recurringBillingPlanType.rawValue
        }

        if let recurringBillingDetails {
            parameters["plan_metadata"] = recurringBillingDetails.parameters()
        }
 
        if let universalLink, enablePayPalAppSwitch, isPayPalAppInstalled {
            var appSwitchParameters: [String: Any] = [
                "launch_paypal_app": enablePayPalAppSwitch,
                "os_version": UIDevice.current.systemVersion,
                "os_type": UIDevice.current.systemName,
                "merchant_app_return_url": universalLink.absoluteString
            ]
            if let fallbackUrlScheme {
                appSwitchParameters["fallback_url_scheme"] = fallbackUrlScheme
            }
            
            return parameters.merging(appSwitchParameters) { $1 }
        }
        
        return parameters
    }
}
