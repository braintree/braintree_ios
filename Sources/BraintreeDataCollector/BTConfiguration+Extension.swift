import Foundation
#if canImport(BraintreeCore)
import BraintreeCore
#endif

extension BTConfiguration {

    /// Indicates whether Kount is enabled for the merchant account.
    var isKountEnabled: Bool {
        json["kount"]["kountMerchantId"].isString
    }

    /// Returns the Kount merchant id set in the Gateway.
    var kountMerchantID: String? {
        json["kount"]["kountMerchantId"].asString()
    }
}
