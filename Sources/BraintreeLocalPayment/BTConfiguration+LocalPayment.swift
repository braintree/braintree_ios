import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

extension BTConfiguration {

    /// Indicates whether Local Payments are enabled for the merchant account.
    var isLocalPaymentEnabled: Bool {
        // Local Payments are enabled when PayPal is enabled
        json?["paypalEnabled"].isTrue ?? false
    }
}
