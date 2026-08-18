import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Defines the structure and requirements for PayPal Checkout and PayPal Vault flows.
protocol BTPayPalRequest {
    var hermesPath: String { get }
    var paymentType: BTPayPalPaymentType { get }
    var billingAgreementDescription: String? { get }
    var displayName: String? { get }
    var enablePayPalAppSwitch: Bool { get }
    var isShippingAddressEditable: Bool { get }
    var isShippingAddressRequired: Bool { get }
    var landingPageType: BTPayPalRequestLandingPageType? { get }
    var lineItems: [BTPayPalLineItem]? { get }
    var localeCode: BTPayPalLocaleCode? { get }
    var merchantAccountID: String? { get }
    var recurringBillingDetails: BTPayPalRecurringBillingDetails? { get }
    var recurringBillingPlanType: BTPayPalRecurringBillingPlanType? { get }
    var riskCorrelationID: String? { get }
    var shippingAddressOverride: BTPostalAddress? { get }
    var shopperSessionID: String? { get }
    var userAction: BTPayPalRequestUserAction { get }
    var userAuthenticationEmail: String? { get }
    var userPhoneNumber: BTPayPalPhoneNumber? { get }
    
    func encodedPostBodyWith(
        configuration: BTConfiguration,
        isPayPalAppInstalled: Bool,
        universalLink: URL?,
        fallbackURLScheme: String?
    ) -> Encodable
}

enum PayPalRequestConstants {
    static let callbackURLHostAndPath = "onetouch/v1/"
}
