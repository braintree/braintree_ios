import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

extension BTConfiguration {

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Indicates whether PayPal is enabled for the merchant account.
    @_documentation(visibility: private)
    @objc public var isPayPalEnabled: Bool {
        json?["paypalEnabled"].isTrue ?? false
    }

    /// Indicates whether PayPal billing agreements are enabled for the merchant account.
    var isBillingAgreementsEnabled: Bool {
        json?["paypal"]["billingAgreementsEnabled"].isTrue ?? false
    }
    
    /// Retrieves the display name associated with the PayPal account.
    var displayName: String? {
        json?["paypal"]["displayName"].asString()
    }
    
    /// Retrieves the currencyIsoCode.
    var currencyIsoCode: String? {
        json?["paypal"]["currencyIsoCode"].asString()
    }
    
    /// The merchant account ID
    var merchantAccountID: String? {
        json?["merchantId"].asString()
    }
}
