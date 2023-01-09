import Foundation
import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Options for the PayPal Vault flow.
@objcMembers public class BTPayPalVaultRequest: NSObject, BTPayPalRequest {

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
    
    /// Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    public var offerCredit: Bool
    
    /// :nodoc:
    public let hermesPath: String = "v1/paypal_hermes/setup_billing_agreement"
    
    /// :nodoc:
    public let paymentType: BTPayPalPaymentType = .vault

    // MARK: - Initializer

    /// Initializes a PayPal Native Vault request
    /// - Parameter offerCredit: Optional: Offers PayPal Credit if the customer qualifies. Defaults to `false`.
    public init(
        offerCredit: Bool = false,
        requestBillingAgreement: Bool = false,
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
        self.offerCredit = offerCredit
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
    
    /// :nodoc:
    public func parameters(with configuration: BTConfiguration) -> [String: Any] {
        let baseParameters: [String: Any] = baseParameters(with: configuration)
        var vaultParameters: [String: Any] = ["offer_paypal_credit": offerCredit]

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
