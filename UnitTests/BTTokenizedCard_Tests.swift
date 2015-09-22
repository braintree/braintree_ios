import XCTest

class BTTokenizedCard_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testCardWithJSON_createsCardWithExpectedValues() {
        let tokenizedCard = BTTokenizedCard(JSON: BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "Visa",
                "lastTwo": "11",
            ],
            "nonce": "fake-nonce",
            ]))

        XCTAssertEqual(tokenizedCard.localizedDescription, "Visa ending in 11")
        XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.Visa)
        XCTAssertEqual(tokenizedCard.lastTwo, "11")
        XCTAssertEqual(tokenizedCard.paymentMethodNonce, "fake-nonce")
        XCTAssertEqual(tokenizedCard.type, "Visa")
    }

    func testCardWithJSON_ignoresCaseWhenParsingCardType() {
        let tokenizedCard = BTTokenizedCard(JSON: BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "vIsA",
                "lastTwo": "11",
            ],
            "nonce": "fake-nonce",
            ]))

        XCTAssertEqual(tokenizedCard.localizedDescription, "Visa ending in 11")
        XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.Visa)
        XCTAssertEqual(tokenizedCard.lastTwo, "11")
        XCTAssertEqual(tokenizedCard.paymentMethodNonce, "fake-nonce")
        XCTAssertEqual(tokenizedCard.type, "Visa")
    }

    func testCardWithJSON_parsesAllCardTypesCorrectly() {
        let cardNetworks = [
            BTCardNetwork.Unknown,
            BTCardNetwork.AMEX,
            BTCardNetwork.DinersClub,
            BTCardNetwork.Discover,
            BTCardNetwork.Maestro,
            BTCardNetwork.MasterCard,
            BTCardNetwork.JCB,
            BTCardNetwork.Laser,
            BTCardNetwork.Solo,
            BTCardNetwork.Switch,
            BTCardNetwork.UnionPay,
            BTCardNetwork.UKMaestro,
            BTCardNetwork.Visa,
        ]
        let cardTypeJSONValues = [
            "some unrecognized type",
            "american express",
            "diners club",
            "discover",
            "maestro",
            "mastercard",
            "jcb",
            "laser",
            "solo",
            "switch",
            "china unionpay",
            "uk maestro",
            "visa",
        ]
        let cardTypes = [
            "Unknown",
            "AMEX",
            "DinersClub",
            "Discover",
            "Maestro",
            "MasterCard",
            "JCB",
            "Laser",
            "Solo",
            "Switch",
            "UnionPay",
            "UKMaestro",
            "Visa",
        ]
        for i in 0..<cardNetworks.count {
            let jsonValue = [
                "description": "\(cardTypes[i]) ending in 11",
                "details": [
                    "cardType": cardTypeJSONValues[i],
                    "lastTwo": "11",
                ],
                "nonce": "fake-nonce",
            ]
            let tokenizedCard = BTTokenizedCard(JSON: BTJSON(value: jsonValue))

            XCTAssertEqual(tokenizedCard.cardNetwork, cardNetworks[i])
            XCTAssertEqual(tokenizedCard.type, cardTypes[i])
        }
    }
}
