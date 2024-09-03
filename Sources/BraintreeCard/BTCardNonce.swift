import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains information about a tokenized card.
@objcMembers public class BTCardNonce: BTPaymentMethodNonce {

    // MARK: - Public Properties

    /// The card network.
    public var cardNetwork: BTCardNetwork = .unknown

    /// The expiration month of the card, if available.
    public var expirationMonth: String?

    /// The expiration year of the card, if available.
    public var expirationYear: String?

    /// The name of the cardholder, if available.
    public var cardholderName: String?

    /// The last two digits of the card, if available.
    public var lastTwo: String?

    /// The last four digits of the card, if available.
    public var lastFour: String?

    /// The BIN number of the card, if available.
    public var bin: String?

    /// The BIN data for the card number associated with this nonce.
    public var binData: BTBinData

    /// The 3D Secure info for the card number associated with this nonce.
    public var threeDSecureInfo: BTThreeDSecureInfo

    /// Details about the regulatory environment and applicable customer authentication regulation for a potential transaction.
    /// This can be used to make an informed decision whether to perform 3D Secure authentication.
    public var authenticationInsight: BTAuthenticationInsight?

    // MARK: - Initializers

    init(
        withNonce nonce: String,
        cardNetwork: BTCardNetwork = .unknown,
        expirationMonth: String? = nil,
        expirationYear: String? = nil,
        cardholderName: String? = nil,
        lastTwo: String? = nil,
        lastFour: String? = nil,
        isDefault: Bool = false,
        cardJSON: BTJSON? = nil,
        authenticationInsightJSON: BTJSON? = nil
    ) {
        let type = Self.typeString(from: cardNetwork)

        self.threeDSecureInfo = BTThreeDSecureInfo(json: cardJSON?["threeDSecureInfo"])
        self.binData = BTBinData(json: cardJSON?["binData"])

        super.init(nonce: nonce, type: type, isDefault: isDefault)

        self.nonce = nonce
        self.cardNetwork = cardNetwork
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.cardholderName = cardholderName
        self.lastTwo = lastTwo
        self.lastFour = lastFour
        self.bin = cardJSON?["details"]["bin"].asString() ?? cardJSON?["bin"].asString()

        if let authenticationInsightJSON {
            self.authenticationInsight = BTAuthenticationInsight(json: authenticationInsightJSON)
        }
    }

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Create a `BTCardNonce` object from JSON.
    @_documentation(visibility: private)
    @objc(initWithJSON:)
    public convenience init(json cardJSON: BTJSON?) {
        var authenticationInsightJSON: BTJSON?

        if cardJSON?["authenticationInsight"].asDictionary() != nil {
            authenticationInsightJSON = cardJSON?["authenticationInsight"]
        }

        let cardTypeJSON = cardJSON?["details"]["cardType"].asString()
        let cardNetwork = Self.cardNetworkFromGatewayCardType(cardTypeJSON ?? "unknown")

        self.init(
            withNonce: cardJSON?["nonce"].asString() ?? "",
            cardNetwork: cardNetwork ?? BTCardNetwork.unknown,
            expirationMonth: cardJSON?["details"]["expirationMonth"].asString(),
            expirationYear: cardJSON?["details"]["expirationYear"].asString(),
            cardholderName: cardJSON?["details"]["cardholderName"].asString(),
            lastTwo: cardJSON?["details"]["lastTwo"].asString(),
            lastFour: cardJSON?["details"]["lastFour"].asString(),
            isDefault: cardJSON?["default"].isTrue ?? false,
            cardJSON: cardJSON,
            authenticationInsightJSON: authenticationInsightJSON
        )
    }

    /// Create a `BTCardNonce` object from GraphQL JSON.
    convenience init(graphQLJSON json: BTJSON?) {
        var lastFour: String = ""

        if let lastFourString = json?["creditCard"]["last4"].asString() {
            lastFour = lastFourString
        }

        let lastTwo = String(lastFour.count == 4 ? lastFour.suffix(2) : "")

        var authenticationInsightJSON: BTJSON?

        if json?["authenticationInsight"].asDictionary() != nil {
            authenticationInsightJSON = json?["authenticationInsight"]
        }

        let cardBrandJSON = json?["creditCard"]["brand"].asString()
        let cardNetwork = Self.cardNetworkFromGatewayCardType(cardBrandJSON ?? "unknown")

        self.init(
            withNonce: json?["token"].asString() ?? "",
            cardNetwork: cardNetwork ?? BTCardNetwork.unknown,
            expirationMonth: json?["creditCard"]["expirationMonth"].asString(),
            expirationYear: json?["creditCard"]["expirationYear"].asString(),
            cardholderName: json?["creditCard"]["cardholderName"].asString(),
            lastTwo: lastTwo,
            lastFour: lastFour,
            isDefault: false,
            cardJSON: json?["creditCard"],
            authenticationInsightJSON: authenticationInsightJSON
        )
    }

    // MARK: - Private Methods

    private static func cardNetworkFromGatewayCardType(_ cardTypeString: String) -> BTCardNetwork? {
        // Normalize the card network string in cardJSON to be lowercase so that our enum mapping is case insensitive
        let cardType = BTJSON(value: cardTypeString.lowercased())
        let integerValue = cardType.asEnum(
            [
                "american express": BTCardNetwork.AMEX.rawValue,
                "diners club": BTCardNetwork.dinersClub.rawValue,
                "unionpay": BTCardNetwork.unionPay.rawValue,
                "discover": BTCardNetwork.discover.rawValue,
                "maestro": BTCardNetwork.maestro.rawValue,
                "mastercard": BTCardNetwork.masterCard.rawValue,
                "jcb": BTCardNetwork.JCB.rawValue,
                "hiper": BTCardNetwork.hiper.rawValue,
                "hipercard": BTCardNetwork.hipercard.rawValue,
                "laser": BTCardNetwork.laser.rawValue,
                "solo": BTCardNetwork.solo.rawValue,
                "switch": BTCardNetwork.switch.rawValue,
                "uk maestro": BTCardNetwork.ukMaestro.rawValue,
                "visa": BTCardNetwork.visa.rawValue
            ],
            orDefault: BTCardNetwork.unknown.rawValue
        )

        return BTCardNetwork(rawValue: integerValue)
    }

    private static func typeString(from cardNetwork: BTCardNetwork) -> String {
        switch cardNetwork {
        case .AMEX:
            return "AMEX"
        case .dinersClub:
            return "DinersClub"
        case .discover:
            return "Discover"
        case .masterCard:
            return "MasterCard"
        case .visa:
            return "Visa"
        case .JCB:
            return "JCB"
        case .laser:
            return "Laser"
        case .maestro:
            return "Maestro"
        case .unionPay:
            return "UnionPay"
        case .hiper:
            return "Hiper"
        case .hipercard:
            return "Hipercard"
        case .solo:
            return "Solo"
        case .switch:
            return "Switch"
        case .ukMaestro:
            return "UKMaestro"
        default:
            return "Unknown"
        }
    }
}
