import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeCard)
import BraintreeCard
#endif

@objcMembers public class BTVisaCheckoutNonce: BTPaymentMethodNonce {

    // Last two digits of the user's underlying card, intended for display purposes.
    public let lastTwo: String
    
    // Type of this card (e.g. Visa, MasterCard, American Express)
    public let cardType: String
    
    // The user's billing address.
    public let billingAddress: BTVisaCheckoutAddress
    
    // The user's shipping address.
    public let shippingAddress: BTVisaCheckoutAddress
    
    // The user's data.
    public let userData: BTVisaCheckoutUserData
    
    // The Call ID from the VisaPaymentSummary.
    public let callID: String
    
    // The BIN data for the card number associated with [VisaCheckoutNonce]
    public let binData: BTBinData

    init?(json: BTJSON) {

        let json = json["visaCheckoutCards"].isArray ? json["visaCheckoutCards"][0] : json
        
        guard
            let lastTwo = json["details"]["lastTwo"].asString(),
            let cardType = json["details"]["cardType"].asString(),
            let nonce = json["nonce"].asString(),
            let type = json["type"].asString(),
            let callID = json["callId"].asString()
        else {
            return nil
        }
        
        self.lastTwo = lastTwo
        self.billingAddress = BTVisaCheckoutAddress(json: json["billingAddress"])
        self.shippingAddress = BTVisaCheckoutAddress(json: json["shippingAddress"])
        self.userData = BTVisaCheckoutUserData(json: json["userData"])
        self.binData = BTBinData(json: json["binData"])
        self.cardType = cardType
        self.callID = callID
        let isDefault = json["default"].isTrue
        
        super.init(nonce: nonce, type: cardType, isDefault: isDefault)
    }
}
