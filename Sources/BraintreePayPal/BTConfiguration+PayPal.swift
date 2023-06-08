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
}
