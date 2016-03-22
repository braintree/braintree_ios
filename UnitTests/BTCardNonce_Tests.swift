import XCTest

class BTCardNonce_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testCardWithJSON_createsCardWithExpectedValues() {
        let cardNonce = BTCardNonce(JSON: BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "Visa",
                "lastTwo": "11",
            ],
            "nonce": "fake-nonce",
            ]))

        XCTAssertEqual(cardNonce.localizedDescription, "Visa ending in 11")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.Visa)
        XCTAssertEqual(cardNonce.lastTwo, "11")
        XCTAssertEqual(cardNonce.nonce, "fake-nonce")
        XCTAssertEqual(cardNonce.type, "Visa")
    }

    func testCardWithJSON_ignoresCaseWhenParsingCardType() {
        let cardNonce = BTCardNonce(JSON: BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "vIsA",
                "lastTwo": "11",
            ],
            "nonce": "fake-nonce",
            ]))

        XCTAssertEqual(cardNonce.localizedDescription, "Visa ending in 11")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.Visa)
        XCTAssertEqual(cardNonce.lastTwo, "11")
        XCTAssertEqual(cardNonce.nonce, "fake-nonce")
        XCTAssertEqual(cardNonce.type, "Visa")
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
            "unionpay",
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
            let cardNonce = BTCardNonce(JSON: BTJSON(value: jsonValue))

            XCTAssertEqual(cardNonce.cardNetwork, cardNetworks[i])
            XCTAssertEqual(cardNonce.type, cardTypes[i])
        }
    }
}
