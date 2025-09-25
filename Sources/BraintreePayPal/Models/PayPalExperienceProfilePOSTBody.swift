import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct PayPalExperienceProfile: Encodable {
    
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
    
    init(payPalRequest: BTPayPalVaultRequest, configuration: BTConfiguration) {
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
    
    enum CodingKeys: String, CodingKey {
        case isShippingAddressRequired = "no_shipping"
        case displayName = "brand_name"
        case landingPageType = "landing_page_type"
        case localeCode = "locale_code"
        case shippingAddressOverride = "address_override"
        case userAction = "user_action"
    }
}
