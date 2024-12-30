import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for v1/paypal_hermes/create_payment_resource
struct BTPayPalCheckoutPOSTBody: Encodable {
    
    // MARK: - Private Properties
    
    private let userPhoneNumber: BTPayPalPhoneNumber?
    private let returnURL: String
    private let cancelURL: String
    private let experienceProfile: ExperienceProfile
    
    private var merchantAccountID: String?
    private var riskCorrelationID: String?
    private var lineItems: [[String: String]]?
    private var userAuthenticationEmail: String?
    
    // MARK: - Initializer
    
    init(payPalRequest: BTPayPalRequest, configuration: BTConfiguration) {
        if let merchantAccountID = payPalRequest.merchantAccountID {
            self.merchantAccountID = merchantAccountID
        }
        
        if let riskCorrelationID = payPalRequest.riskCorrelationID {
            self.riskCorrelationID = riskCorrelationID
        }
        
        if let lineItems = payPalRequest.lineItems, !lineItems.isEmpty {
            let lineItemsArray = lineItems.compactMap { $0.requestParameters() }
            self.lineItems = lineItemsArray
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
        case merchantAccountID = "merchant_account_id"
        case riskCorrelationID = "correlation_id"
        case lineItems = "line_items"
        case userAuthenticationEmail = "payer_email"
        case userPhoneNumber = "phone_number"
        case returnURL = "return_url"
        case cancelURL = "cancel_url"
        case experienceProfile = "experience_profile"
    }
}

extension BTPayPalCheckoutPOSTBody {
    
    struct ExperienceProfile: Encodable {
        
        // MARK: - Private Properties
        
        private let displayName: String?
        private let isShippingAddressRequired: Bool
        private let shippingAddressOverride: Bool
        
        private var landingPageType: String?
        private var localeCode: String?
        
        // MARK: - Initializer
        
        init(payPalRequest: BTPayPalRequest, configuration: BTConfiguration) {
            self.displayName = payPalRequest.displayName != nil ? payPalRequest.displayName : configuration.displayName
            self.isShippingAddressRequired = !payPalRequest.isShippingAddressRequired
            
            if let landingPageType = payPalRequest.landingPageType?.stringValue {
                self.landingPageType = landingPageType
            }
            
            if let localeCode = payPalRequest.localeCode?.stringValue {
                self.localeCode = localeCode
            }
            
            self.shippingAddressOverride = payPalRequest.shippingAddressOverride != nil ? !payPalRequest.isShippingAddressEditable : false
        }
        
        enum CodingKeys: String, CodingKey {
            case isShippingAddressRequired = "no_shipping"
            case displayName = "brand_name"
            case landingPageType = "landing_page_type"
            case localeCode = "locale_code"
            case shippingAddressOverride = "address_override"
        }
    }
}
