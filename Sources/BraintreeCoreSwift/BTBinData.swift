import Foundation

/// Contains the bin data associated with a payment method
@objcMembers public class BTBinData: NSObject {

    /// Whether the card is a prepaid card. Possible values: Yes/No/Unknown
    public let prepaid: String

    /// Whether the card is a healthcare card. Possible values: Yes/No/Unknown
    public let healthcare: String

    /// Whether the card is a debit card. Possible values: Yes/No/Unknown
    public let debit: String

    ///  A value indicating whether the issuing bank's card range is regulated by the Durbin Amendment due to the bank's assets. Possible values: Yes/No/Unknown
    public let durbinRegulated: String

    ///  Whether the card type is a commercial card and is capable of processing Level 2 transactions. Possible values: Yes/No/Unknown
    public let commercial: String

    /// Whether the card is a payroll card. Possible values: Yes/No/Unknown
    public let payroll: String

    /// The bank that issued the credit card, if available.
    public let issuingBank: String

    /// The country that issued the credit card, if available.
    public let countryOfIssuance: String

    /// The code for the product type of the card (e.g. `D` (Visa Signature Preferred), `G` (Visa Business)), if available.
    public let productID: String

    /// Create a `BTBinData` object from JSON.
    @objc(initWithJSON:)
    public init(json: BTJSON?) {
        self.prepaid = json?["prepaid"].asString() ?? "Unknown"
        self.healthcare = json?["healthcare"].asString() ?? "Unknown"
        self.debit = json?["debit"].asString() ?? "Unknown"
        self.durbinRegulated = json?["durbinRegulated"].asString() ?? "Unknown"
        self.commercial = json?["commercial"].asString() ?? "Unknown"
        self.payroll = json?["payroll"].asString() ?? "Unknown"
        self.issuingBank = json?["issuingBank"].asString() ?? ""
        self.countryOfIssuance = json?["countryOfIssuance"].asString() ?? ""
        self.productID = json?["productId"].asString() ?? ""
    }
}
