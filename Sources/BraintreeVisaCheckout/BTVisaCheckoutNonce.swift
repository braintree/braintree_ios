import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// A `nonce` representing a Visa Checkout card.
@objcMembers public class BTVisaCheckoutNonce: BTPaymentMethodNonce {

    /// Last two digits of the user's underlying card, intended for display purposes.
    public let lastTwo: String
    
    /// Type of this card (e.g. Visa, MasterCard, American Express)
    public let cardType: String
    
    /// The user's billing address.
    public let billingAddress: BTVisaCheckoutAddress
    
    /// The user's shipping address.
    public let shippingAddress: BTVisaCheckoutAddress
    
    /// The user's data.
    public let userData: BTVisaCheckoutUserData
    
    /// The Call ID from the VisaPaymentSummary.
    public let callID: String
    
    /// The BIN data for the card number associated with [VisaCheckoutNonce]
    public let binData: BTBinData

    init?(json: BTJSON) {
        let visaCheckoutCards = json["visaCheckoutCards"].isArray ? json["visaCheckoutCards"][0] : json

        guard let nonce = visaCheckoutCards["nonce"].asString() else {
            return nil
        }

        let lastTwo = visaCheckoutCards["details"]["lastTwo"].asString() ?? ""
        let cardType = visaCheckoutCards["details"]["cardType"].asString() ?? "Unknown"
        let callID = visaCheckoutCards["callId"].asString() ?? ""
        let isDefault = visaCheckoutCards["default"].isTrue

        self.lastTwo = lastTwo
        self.billingAddress = BTVisaCheckoutAddress(json: visaCheckoutCards["billingAddress"])
        self.shippingAddress = BTVisaCheckoutAddress(json: visaCheckoutCards["shippingAddress"])
        self.userData = BTVisaCheckoutUserData(json: visaCheckoutCards["userData"])
        self.binData = BTBinData(json: visaCheckoutCards["binData"])
        self.cardType = cardType
        self.callID = callID

        super.init(nonce: nonce, type: cardType, isDefault: isDefault)
    }
}
