import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeCard)
import BraintreeCard
#endif

public class BTVisaCheckoutCardNonce {

    public let lastTwo: String
    public let cardNetwork: BTCardNetwork
    public let shippingAddress: BTVisaCheckoutAddress?
    public let billingAddress: BTVisaCheckoutAddress?
    public let userData: BTVisaCheckoutUserData?
    public let nonce: BTCardNonce?

    @objc public init(
        nonce: String,
        type: String,
        lastTwo: String,
        cardNetwork: BTCardNetwork,
        isDefault: Bool,
        shippingAddress: BTVisaCheckoutAddress?,
        billingAddress: BTVisaCheckoutAddress?,
        userData: BTVisaCheckoutUserData?
    ) {
        self.lastTwo = lastTwo
        self.cardNetwork = cardNetwork
        self.shippingAddress = shippingAddress
        self.billingAddress = billingAddress
        self.userData = userData
    }

    public static func cardNetwork(from json: BTJSON) -> BTCardNetwork {
        let map: [String: Int] = [
            "american express": BTCardNetwork.AMEX.rawValue,
            "diners club": BTCardNetwork.dinersClub.rawValue,
            "unionpay": BTCardNetwork.unionPay.rawValue,
            "discover": BTCardNetwork.discover.rawValue,
            "maestro": BTCardNetwork.maestro.rawValue,
            "mastercard": BTCardNetwork.masterCard.rawValue,
            "jcb": BTCardNetwork.JCB.rawValue,
            "laser": BTCardNetwork.laser.rawValue,
            "solo": BTCardNetwork.solo.rawValue,
            "switch": BTCardNetwork.switch.rawValue,
            "uk maestro": BTCardNetwork.ukMaestro.rawValue,
            "visa": BTCardNetwork.visa.rawValue
        ]
        
        let value = json.asString()?.lowercased() ?? ""
        let rawValue = map[value] ?? BTCardNetwork.unknown.rawValue
        return BTCardNetwork(rawValue: rawValue) ?? .unknown
    }

    public static func visaCheckoutCardNonce(with json: BTJSON) -> BTVisaCheckoutCardNonce? {
        guard
            let nonce = json["nonce"].asString(),
            let type = json["type"].asString(),
            let details = json["details"].asDictionary(),
            let lastTwo = details["lastTwo"] as? String
        else {
            return nil
        }

        let cardTypeString = json["details"]["cardType"].asString()?.lowercased() ?? ""
        let cardTypeJSON = BTJSON(value: cardTypeString)
        let cardNetwork = cardNetwork(from: cardTypeJSON)

        let shippingAddress = BTVisaCheckoutAddress.address(with: json["shippingAddress"])
        let billingAddress = BTVisaCheckoutAddress.address(with: json["billingAddress"])
        let userData = BTVisaCheckoutUserData.userData(with: json["userData"])
        let isDefault = json["default"].isTrue

        return BTVisaCheckoutCardNonce(
            nonce: nonce,
            type: type,
            lastTwo: lastTwo,
            cardNetwork: cardNetwork,
            isDefault: isDefault,
            shippingAddress: shippingAddress,
            billingAddress: billingAddress,
            userData: userData
        )
    }
}

