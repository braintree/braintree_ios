import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeCard)
import BraintreeCard
#endif

@objc public class BTVisaCheckoutNonce: BTPaymentMethodNonce {

    @objc public let lastTwo: String
    @objc public let cardType: String
    @objc public let billingAddress: BTVisaCheckoutAddress
    @objc public let shippingAddress: BTVisaCheckoutAddress
    @objc public let userData: BTVisaCheckoutUserData
    @objc public let callId: String
    @objc public let binData: BTBinData

    @objc public init(
        nonce: String,
        type: String,
        lastTwo: String,
        cardType: String,
        billingAddress: BTVisaCheckoutAddress,
        shippingAddress: BTVisaCheckoutAddress,
        userData: BTVisaCheckoutUserData,
        callId: String,
        binData: BTBinData,
        isDefault: Bool
    ) {
        self.lastTwo = lastTwo
        self.cardType = cardType
        self.billingAddress = billingAddress
        self.shippingAddress = shippingAddress
        self.userData = userData
        self.callId = callId
        self.binData = binData
        
        super.init(nonce: nonce, type: type, isDefault: isDefault)
    }
}
