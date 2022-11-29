import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains information about an American Express rewards balance.
@objcMembers public class BTAmericanExpressRewardsBalance: NSObject {

    /// Optional. An error code when there was an issue fetching the rewards balance
    public var errorCode: String?

    /// Optional. An error message when there was an issue fetching the rewards balance
    public var errorMessage: String?

    /// Optional. The conversion rate associated with the rewards balance
    public var conversionRate: String?

    /// Optional. The currency amount associated with the rewards balance
    public var currencyAmount: String?

    /// Optional. The currency ISO code associated with the rewards balance
    public var currencyIsoCode: String?

    /// Optional. The request ID used when fetching the rewards balance
    public var requestID: String?

    /// Optional. The rewards amount associated with the rewards balance
    public var rewardsAmount: String?

    /// Optional. The rewards unit associated with the rewards balance
    public var rewardsUnit: String?

    /// Initialize with JSON from Braintree
    /// - Parameter json: The JSON body response
    init(json: BTJSON) {
        self.errorCode = json["error"]["code"].asString()
        self.errorMessage = json["error"]["message"].asString()
        self.conversionRate = json["conversionRate"].asString()
        self.currencyAmount = json["currencyAmount"].asString()
        self.currencyIsoCode = json["currencyIsoCode"].asString()
        self.requestID = json["requestId"].asString()
        self.rewardsAmount = json["rewardsAmount"].asString()
        self.rewardsUnit = json["rewardsUnit"].asString()
    }
}
