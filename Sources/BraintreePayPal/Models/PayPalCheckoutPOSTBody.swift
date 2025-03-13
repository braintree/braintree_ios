import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for `v1/paypal_hermes/create_payment_resource`
struct PayPalCheckoutPOSTBody: Encodable {
    
    // MARK: - Private Properties
    
    private let amount: String
    private let intent: String
    private let offerPayLater: Bool
    private let returnURL: String
    private let cancelURL: String
    private let experienceProfile: PayPalExperienceProfile
    private let userPhoneNumber: BTPayPalPhoneNumber?
    
    private var billingAgreementDescription: BillingAgreemeentDescription?
    private var enablePayPalAppSwitch: Bool?
    private var contactInformation: BTContactInformation?
    private var currencyCode: String?
    private var lineItems: [BTPayPalLineItem]?
    private var merchantAccountID: String?
    private var osType: String?
    private var osVersion: String?
    private var recipientPhoneNumber: BTPayPalPhoneNumber?
    private var recipientEmail: String?
    private var requestBillingAgreement: Bool?
    private var riskCorrelationID: String?
    private var shippingCallbackURL: String?
    private var shopperSessionID: String?
    private var universalLink: String?
    private var userAuthenticationEmail: String?
    
    // Address properties
    private var streetAddress: String?
    private var extendedAddress: String?
    private var locality: String?
    private var countryCodeAlpha2: String?
    private var postalCode: String?
    private var region: String?
    private var recipientName: String?
    
    // MARK: - Initializer

    // swiftlint:disable:next cyclomatic_complexity
    init(
        payPalRequest: BTPayPalCheckoutRequest,
        configuration: BTConfiguration,
        isPayPalAppInstalled: Bool,
        universalLink: URL?
    ) {
        self.amount = payPalRequest.amount
        self.intent = payPalRequest.intent.stringValue
        self.offerPayLater = payPalRequest.offerPayLater
        
        let currencyIsoCode = payPalRequest.currencyCode != nil ? payPalRequest.currencyCode : configuration.currencyIsoCode
        
        if let currencyIsoCode {
            self.currencyCode = currencyIsoCode
        }
        
        if payPalRequest.requestBillingAgreement {
            self.requestBillingAgreement = payPalRequest.requestBillingAgreement
            
            if let billingAgreementDescription = payPalRequest.billingAgreementDescription {
                self.billingAgreementDescription = BillingAgreemeentDescription(description: billingAgreementDescription)
            }
        }
        
        if let shippingAddressOverride = payPalRequest.shippingAddressOverride {
            self.streetAddress = shippingAddressOverride.streetAddress
            self.extendedAddress = shippingAddressOverride.extendedAddress
            self.locality = shippingAddressOverride.locality
            self.countryCodeAlpha2 = shippingAddressOverride.countryCodeAlpha2
            self.postalCode = shippingAddressOverride.postalCode
            self.region = shippingAddressOverride.region
            self.recipientName = shippingAddressOverride.recipientName
        }
        
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
        
        if let recipientEmail = payPalRequest.contactInformation?.recipientEmail {
            self.recipientEmail = recipientEmail
        }
        
        if let recipientPhoneNumber = payPalRequest.contactInformation?.recipientPhoneNumber {
            self.recipientPhoneNumber = recipientPhoneNumber
        }
        
        if let shippingCallbackURL = payPalRequest.shippingCallbackURL {
            self.shippingCallbackURL = shippingCallbackURL.absoluteString
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
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case amount
        case billingAgreementDescription = "billing_agreement_details"
        case cancelURL = "cancel_url"
        case currencyCode = "currency_iso_code"
        case experienceProfile = "experience_profile"
        case intent
        case lineItems = "line_items"
        case merchantAccountID = "merchant_account_id"
        case offerPayLater = "offer_pay_later"
        case recipientPhoneNumber = "international_phone"
        case recipientEmail = "recipient_email"
        case requestBillingAgreement = "request_billing_agreement"
        case returnURL = "return_url"
        case riskCorrelationID = "correlation_id"
        case shippingCallbackURL = "shipping_callback_url"
        case shopperSessionID = "shopper_session_id"
        case userAuthenticationEmail = "payer_email"
        case userPhoneNumber = "phone_number"
        
        // Address keys
        case streetAddress = "line1"
        case extendedAddress = "line2"
        case locality = "city"
        case countryCodeAlpha2 = "country_code"
        case postalCode = "postal_code"
        case region = "state"
        case recipientName = "recipient_name"
    }
}

extension PayPalCheckoutPOSTBody {
    
    struct BillingAgreemeentDescription: Encodable {
        
        // MARK: - Private Properties
        
        private let description: String
        
        // MARK: - Initializer
        
        init(description: String) {
            self.description = description
        }
    }
}
