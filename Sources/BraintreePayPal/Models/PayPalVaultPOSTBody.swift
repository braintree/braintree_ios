import Foundation
import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for v1/paypal_hermes/setup_billing_agreement
struct PayPalVaultPOSTBody: Encodable {
    
    // MARK: - Private Properties
    
    private let returnURL: String
    private let cancelURL: String
    private let experienceProfile: PayPalExperienceProfile
    private let userPhoneNumber: BTPayPalPhoneNumber?
    
    private var billingAgreementDescription: String?
    private var enablePayPalAppSwitch: Bool?
    private var lineItems: [BTPayPalLineItem]?
    private var merchantAccountID: String?
    private var offerCredit = false
    private var osType: String?
    private var osVersion: String?
    private var recurringBillingPlanType: BTPayPalRecurringBillingPlanType?
    private var recurringBillingDetails: BTPayPalRecurringBillingDetails?
    private var riskCorrelationID: String?
    private var shippingAddressOverride: BTPostalAddress?
    private var universalLink: String?
    private var userAuthenticationEmail: String?
    
    // MARK: - Initializer
    
    init(
        payPalRequest: BTPayPalVaultRequest,
        configuration: BTConfiguration,
        isPayPalAppInstalled: Bool,
        universalLink: URL?
    ) {
        if let merchantAccountID = payPalRequest.merchantAccountID {
            self.merchantAccountID = merchantAccountID
        }
        
        if let riskCorrelationID = payPalRequest.riskCorrelationID {
            self.riskCorrelationID = riskCorrelationID
        }
        
        if let lineItems = payPalRequest.lineItems, !lineItems.isEmpty {
            self.lineItems = lineItems
        }
        
        if let userAuthenticationEmail = payPalRequest.userAuthenticationEmail, !userAuthenticationEmail.isEmpty {
            self.userAuthenticationEmail = userAuthenticationEmail
        }
        
        self.userPhoneNumber = payPalRequest.userPhoneNumber
        self.returnURL = BTCoreConstants.callbackURLScheme + "://\(PayPalRequestConstants.callbackURLHostAndPath)success"
        self.cancelURL = BTCoreConstants.callbackURLScheme + "://\(PayPalRequestConstants.callbackURLHostAndPath)cancel"
        self.experienceProfile = PayPalExperienceProfile(payPalRequest: payPalRequest, configuration: configuration)
        
        if let universalLink, payPalRequest.enablePayPalAppSwitch, isPayPalAppInstalled {
            self.enablePayPalAppSwitch = payPalRequest.enablePayPalAppSwitch
            self.osType = UIDevice.current.systemName
            self.osVersion = UIDevice.current.systemVersion
            self.universalLink = universalLink.absoluteString
            return
        }
        
        if let recurringBillingPlanType = payPalRequest.recurringBillingPlanType {
            self.recurringBillingPlanType = recurringBillingPlanType
        }

        if let recurringBillingDetails = payPalRequest.recurringBillingDetails {
            self.recurringBillingDetails = recurringBillingDetails
        }
        
        self.offerCredit = payPalRequest.offerCredit
        
        if let billingAgreementDescription = payPalRequest.billingAgreementDescription {
            self.billingAgreementDescription = billingAgreementDescription
        }
        
        if let shippingAddressOverride = payPalRequest.shippingAddressOverride {
            self.shippingAddressOverride = shippingAddressOverride
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case billingAgreementDescription = "description"
        case cancelURL = "cancel_url"
        case enablePayPalAppSwitch = "launch_paypal_app"
        case experienceProfile = "experience_profile"
        case lineItems = "line_items"
        case merchantAccountID = "merchant_account_id"
        case offerCredit = "offer_paypal_credit"
        case osType = "os_type"
        case osVersion = "os_version"
        case recurringBillingDetails = "plan_metadata"
        case recurringBillingPlanType = "plan_type"
        case returnURL = "return_url"
        case riskCorrelationID = "correlation_id"
        case shippingAddressOverride = "shipping_address"
        case universalLink = "merchant_app_return_url"
        case userAuthenticationEmail = "payer_email"
        case userPhoneNumber = "phone_number"
    }
}
