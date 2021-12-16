import Foundation

/// BTConfiguration category for DataCollector
// TODO: Shuld this class be public?
@objcMembers public class BTDataCollectorConfiguration: BTConfiguration {

    /// Indicates whether Kount is enabled for the merchant account.
    public var isKountEnabledSwift: Bool? {
        // TODO: Should this be optional?
        json["kount"]["kountMerchantId"].isString
    }
    
    /// Returns the Kount merchant id set in the Gateway
    public var kountMerchantIDSwift: String? {
        json["kount"]["kountMerchantId"].asString()
    }
}
