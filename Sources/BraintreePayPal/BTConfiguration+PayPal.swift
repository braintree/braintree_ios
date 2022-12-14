import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

public extension BTConfiguration {

    /// Indicates whether PayPal is enabled for the merchant account.
    var isPayPalEnabled: Bool {
        json?["paypalEnabled"].isTrue ?? false
    }

    /// Indicates whether PayPal billing agreements are enabled for the merchant account.
    var isBillingAgreementsEnabled: Bool {
        json?["paypal"]["billingAgreementsEnabled"].isTrue ?? false
    }
}
