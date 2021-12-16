import Foundation


/// BTConfiguration category for DataCollector
// TODO: Shuld this class be public?
@objcMembers public class BTDataCollectorConfiguration: BTConfiguration {

    /// Indicates whether Kount is enabled for the merchant account.
    public var isKountEnabled2: Bool? {
        // TODO: Should this be optional?
        self.json["kount"]["kountMerchantId"].isString
    }
    
    /// Returns the Kount merchant id set in the Gateway
    public var kountMerchantID2: String? {
        self.json["kount"]["kountMerchantId"].asString()
    }
}
