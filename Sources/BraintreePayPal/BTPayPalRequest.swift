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
    
    func encodedPostBodyWith(configuration: BTConfiguration, isPayPalAppInstalled: Bool, universalLink: URL?) -> Encodable
}

enum PayPalRequestConstants {
    static let callbackURLHostAndPath = "onetouch/v1/"
}
