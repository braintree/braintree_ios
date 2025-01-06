import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for v1/paypal_hermes/create_payment_resource
struct PayPalCheckoutPOSTBody: Encodable {
    
    // MARK: - Private Properties
    
    private let amount: String
    private let intent: String
    private let offerPayLater: Bool
    private let userPhoneNumber: BTPayPalPhoneNumber?
    private let returnURL: String
    private let cancelURL: String
    private let experienceProfile: ExperienceProfile
    
    private var billingAgreementDescription: BillingAgreemeentDescription?
    private var currencyCode: String?
    private var lineItems: [BTPayPalLineItem]?
    private var merchantAccountID: String?
    private var requestBillingAgreement: Bool?
    private var riskCorrelationID: String?
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
    
    init(payPalRequest: BTPayPalCheckoutRequest, configuration: BTConfiguration) {
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
        
        self.userPhoneNumber = payPalRequest.userPhoneNumber
        self.returnURL = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)success"
        self.cancelURL = BTCoreConstants.callbackURLScheme + "://\(BTPayPalRequest.callbackURLHostAndPath)cancel"
        self.experienceProfile = ExperienceProfile(payPalRequest: payPalRequest, configuration: configuration)
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
        case requestBillingAgreement = "request_billing_agreement"
        case returnURL = "return_url"
        case riskCorrelationID = "correlation_id"
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
    
    struct ExperienceProfile: Encodable {
        
        // MARK: - Private Properties
        
        private let displayName: String?
        private let isShippingAddressRequired: Bool
        private let shippingAddressOverride: Bool
        
        private var landingPageType: String?
        private var localeCode: String?
        private var userAction: String?
        
        // MARK: - Initializer
        
        init(payPalRequest: BTPayPalCheckoutRequest, configuration: BTConfiguration) {
            self.displayName = payPalRequest.displayName != nil ? payPalRequest.displayName : configuration.displayName
            self.isShippingAddressRequired = !payPalRequest.isShippingAddressRequired
            
            if let landingPageType = payPalRequest.landingPageType?.stringValue {
                self.landingPageType = landingPageType
            }
            
            if let localeCode = payPalRequest.localeCode?.stringValue {
                self.localeCode = localeCode
            }
            
            self.shippingAddressOverride = payPalRequest.shippingAddressOverride != nil ? !payPalRequest.isShippingAddressEditable : false
            
            if payPalRequest.userAction != .none {
                self.userAction = payPalRequest.userAction.stringValue
            }
        }
        
        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case isShippingAddressRequired = "no_shipping"
            case displayName = "brand_name"
            case landingPageType = "landing_page_type"
            case localeCode = "locale_code"
            case shippingAddressOverride = "address_override"
            case userAction = "user_action"
        }
    }
}
