import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains information about a tokenized Apple Pay card.
@objcMembers public class BTApplePayCardNonce: BTPaymentMethodNonce {

    /// The BIN data for the card number associated with this nonce.
    public let binData: BTBinData

    /// This Boolean indicates whether this tokenized card is a device-specific account number (DPAN) or merchant/cloud token (MPAN). Available on iOS 16+.
    /// If `isDeviceToken` is `false`, then token type is MPAN
    public var isDeviceToken: Bool

    init?(json: BTJSON) {
        guard let nonce = json["nonce"].asString() else { return nil }

        let cardType = json["details"]["cardType"].asString() ?? "ApplePayCard"
        let isDefault = json["default"].isTrue

        self.isDeviceToken = json["details"]["isDeviceToken"].asBool() ?? true

        binData = BTBinData(json: json["binData"])
        super.init(nonce: nonce, type: cardType, isDefault: isDefault)
    }
}
