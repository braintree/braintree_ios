import XCTest

class BTCardNonce_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testCardWithJSON_createsCardWithExpectedValues() {
        let cardNonce = BTCardNonce(json: BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "Visa",
                "lastTwo": "11",
            ],
            "binData": [
                "prepaid": "Yes",
                "healthcare": "Yes",
                "debit": "No",
                "durbinRegulated": "No",
                "commercial": "Yes",
                "payroll": "No",
                "issuingBank": "US",
                "countryOfIssuance": "Something",
                "productId": "123"
            ],
            "nonce": "fake-nonce",
            ]))

        XCTAssertEqual(cardNonce.localizedDescription, "Visa ending in 11")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.visa)
        XCTAssertEqual(cardNonce.lastTwo, "11")
        XCTAssertEqual(cardNonce.nonce, "fake-nonce")
        XCTAssertEqual(cardNonce.type, "Visa")
        XCTAssertEqual(cardNonce.binData.prepaid, "Yes")
        XCTAssertEqual(cardNonce.binData.healthcare, "Yes")
        XCTAssertEqual(cardNonce.binData.debit, "No")
        XCTAssertEqual(cardNonce.binData.durbinRegulated, "No")
        XCTAssertEqual(cardNonce.binData.commercial, "Yes")
        XCTAssertEqual(cardNonce.binData.payroll, "No")
        XCTAssertEqual(cardNonce.binData.issuingBank, "US")
        XCTAssertEqual(cardNonce.binData.countryOfIssuance, "Something")
        XCTAssertEqual(cardNonce.binData.productId, "123")
    }

    func testCardWithJSON_ignoresCaseWhenParsingCardType() {
        let cardNonce = BTCardNonce(json: BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "vIsA",
                "lastTwo": "11",
            ],
            "nonce": "fake-nonce",
            ]))

        XCTAssertEqual(cardNonce.localizedDescription, "Visa ending in 11")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.visa)
        XCTAssertEqual(cardNonce.lastTwo, "11")
        XCTAssertEqual(cardNonce.nonce, "fake-nonce")
        XCTAssertEqual(cardNonce.type, "Visa")
    }

    func testCardWithJSON_parsesAllCardTypesCorrectly() {
        let cardNetworks = [
            BTCardNetwork.unknown,
            BTCardNetwork.AMEX,
            BTCardNetwork.dinersClub,
            BTCardNetwork.discover,
            BTCardNetwork.maestro,
            BTCardNetwork.masterCard,
            BTCardNetwork.JCB,
            BTCardNetwork.laser,
            BTCardNetwork.solo,
            BTCardNetwork.switch,
            BTCardNetwork.unionPay,
            BTCardNetwork.ukMaestro,
            BTCardNetwork.visa,
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
            ] as [String : Any]
            let cardNonce = BTCardNonce(json: BTJSON(value: jsonValue))

            XCTAssertEqual(cardNonce.cardNetwork, cardNetworks[i])
            XCTAssertEqual(cardNonce.type, cardTypes[i])
        }
    }
}
