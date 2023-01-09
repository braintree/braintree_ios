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
@objcMembers public class BTPayPalRequest: NSObject {

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

    /// Optional: The window used to present the ASWebAuthenticationSession.
    /// - Note: If your app supports multitasking, you must set this property to ensure that the ASWebAuthenticationSession is presented on the correct window.
    public var activeWindow: UIWindow?

    /// Optional: A risk correlation ID created with Set Transaction Context on your server.
    public var riskCorrelationId: String?

    // MARK: - Internal Properties

    var hermesPath: String
    var paymentType: BTPayPalPaymentType

    // MARK: - Static Properties
    
    static let callbackURLHostAndPath: String = "onetouch/v1/"
    static let callbackURLScheme: String = "sdk.ios.braintree"

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
        activeWindow: UIWindow? = nil,
        riskCorrelationId: String? = nil
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
        self.activeWindow = activeWindow
        self.riskCorrelationId = riskCorrelationId
    }

    // MARK: Internal Methods

    func parameters(with configuration: BTConfiguration) -> [String: Any] {
        let baseParameters: [String: Any] = baseParameters(with: configuration)

        switch paymentType {
        case .checkout:
            // We downcast self to avoid an empty implementation in the parent class
            // which would require us to override this function
            guard let request = self as? BTPayPalCheckoutRequest else { return [:] }
            var checkoutParameters: [String: Any] = [
                "intent": request.intent.stringValue,
                "amount": request.amount,
                "offer_pay_later": request.offerPayLater
            ]

            let currencyCode = request.currencyCode != nil ? request.currencyCode : configuration.json?["paypal"]["currencyIsoCode"].asString()

            if currencyCode != nil {
                checkoutParameters["currency_iso_code"] = currencyCode
            }

            if request.requestBillingAgreement != false {
                checkoutParameters["request_billing_agreement"] = request.requestBillingAgreement

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

        case .vault:
            // We downcast self to avoid an empty implementation in the parent class
            // which would require us to override this function
            guard let request = self as? BTPayPalVaultRequest else { return [:] }
            var vaultParameters: [String: Any] = ["offer_paypal_credit": request.offerCredit]

            if billingAgreementDescription != nil {
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

        parameters["return_url"] = BTPayPalRequest.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)success"
        parameters["cancel_url"] = BTPayPalRequest.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)cancel"
        parameters["experience_profile"] = experienceProfile

        return parameters
    }
}
