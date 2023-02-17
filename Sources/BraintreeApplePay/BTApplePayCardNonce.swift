import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains information about a tokenized Apple Pay card.
@objcMembers public class BTApplePayCardNonce: BTPaymentMethodNonce {

    /// The BIN data for the card number associated with this nonce.
    public let binData: BTBinData

    init?(json: BTJSON) {
        guard let nonce = json["nonce"].asString() else { return nil }

        let cardType = json["details"]["cardType"].asString() ?? "ApplePayCard"
        let isDefault = json["default"].isTrue

        binData = BTBinData(json: json["binData"])
        super.init(nonce: nonce, type: cardType, isDefault: isDefault)
    }
}
