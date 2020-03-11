import XCTest

class BTCardNonce_Tests: XCTestCase {

    func testCardNonceWithJSON_createsCardWithExpectedValues() {
        let cardNonce = BTCardNonce(json: BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "Visa",
                "lastTwo": "11",
                "lastFour": "1111"
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
            "threeDSecureInfo": [
                "liabilityShifted": true,
                "liabilityShiftPossible": true
            ],
            "authenticationInsight": [
                "regulationEnvironment": "UNREGULATED"
            ]
            ]))

        XCTAssertNotNil(cardNonce.threeDSecureInfo)
        XCTAssertTrue(cardNonce.threeDSecureInfo.liabilityShiftPossible)
        XCTAssertTrue(cardNonce.threeDSecureInfo.liabilityShifted)
        XCTAssertTrue(cardNonce.threeDSecureInfo.wasVerified)
        XCTAssertEqual(cardNonce.localizedDescription, "Visa ending in 11")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.visa)
        XCTAssertEqual(cardNonce.lastTwo, "11")
        XCTAssertEqual(cardNonce.lastFour, "1111")
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
        XCTAssertEqual(cardNonce.authenticationInsight?.regulationEnvironment, "unregulated")
    }
    
    func testCardWithJSON_whenAuthenticationInsightIsNotPresent_setsAuthenticationInsightToNil() {
        let cardNonce = BTCardNonce(json: BTJSON(value: [
            "nonce": "fake-nonce"
            ]))
        XCTAssertNil(cardNonce.authenticationInsight)
    }
    
    func testCardWithJSON_createsCard_withoutThreeDSecureInfo() {
        let cardNonce = BTCardNonce(json: BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "Visa",
                "lastTwo": "11",
                "lastFour": "1111"
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

        XCTAssertNotNil(cardNonce.threeDSecureInfo)
        XCTAssertFalse(cardNonce.threeDSecureInfo.liabilityShiftPossible)
        XCTAssertFalse(cardNonce.threeDSecureInfo.liabilityShifted)
        XCTAssertFalse(cardNonce.threeDSecureInfo.wasVerified)
        XCTAssertEqual(cardNonce.localizedDescription, "Visa ending in 11")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.visa)
        XCTAssertEqual(cardNonce.lastTwo, "11")
        XCTAssertEqual(cardNonce.lastFour, "1111")
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

    func testCardNonceWithJSON_ignoresCaseWhenParsingCardType() {
        let cardNonce = BTCardNonce(json: BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "vIsA",
                "lastTwo": "11",
                "lastFour": "1111"
            ],
            "nonce": "fake-nonce",
            ]))

        XCTAssertEqual(cardNonce.localizedDescription, "Visa ending in 11")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.visa)
        XCTAssertEqual(cardNonce.lastTwo, "11")
        XCTAssertEqual(cardNonce.lastFour, "1111")
        XCTAssertEqual(cardNonce.nonce, "fake-nonce")
        XCTAssertEqual(cardNonce.type, "Visa")
    }

    func testCardNonceWithJSON_parsesAllCardTypesCorrectly() {
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
            BTCardNetwork.hiper,
            BTCardNetwork.hipercard,
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
            "hiper",
            "hipercard",
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
            "Hiper",
            "Hipercard",
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
            XCTAssertFalse(cardNonce.threeDSecureInfo.wasVerified)
        }
    }
    
    func testCardNonceWithGraphQLJSON_createsCardWithExpectedValues() {
        let cardNonce = BTCardNonce(graphQLJSON: BTJSON(value: [
            "token": "fake-nonce",
            "creditCard": [
                "brand": "Visa",
                "last4": "1111",
                "binData": [
                    "prepaid": "Yes",
                    "healthcare": "Yes",
                    "debit": "No",
                    "durbinRegulated": "No",
                    "commercial": "Yes",
                    "payroll": "No",
                    "issuingBank": "US",
                    "countryOfIssuance": "USA",
                    "productId": "123"
                ]
            ],
            "authenticationInsight": [
                "customerAuthenticationRegulationEnvironment": "UNREGULATED"
            ]
            ]))

        XCTAssertEqual(cardNonce.localizedDescription, "ending in 11")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.visa)
        XCTAssertEqual(cardNonce.lastTwo, "11")
        XCTAssertEqual(cardNonce.lastFour, "1111")
        XCTAssertEqual(cardNonce.nonce, "fake-nonce")
        XCTAssertEqual(cardNonce.type, "Visa")
        XCTAssertEqual(cardNonce.binData.prepaid, "Yes")
        XCTAssertEqual(cardNonce.binData.healthcare, "Yes")
        XCTAssertEqual(cardNonce.binData.debit, "No")
        XCTAssertEqual(cardNonce.binData.durbinRegulated, "No")
        XCTAssertEqual(cardNonce.binData.commercial, "Yes")
        XCTAssertEqual(cardNonce.binData.payroll, "No")
        XCTAssertEqual(cardNonce.binData.issuingBank, "US")
        XCTAssertEqual(cardNonce.binData.countryOfIssuance, "USA")
        XCTAssertEqual(cardNonce.binData.productId, "123")
        XCTAssertEqual(cardNonce.authenticationInsight?.regulationEnvironment, "unregulated")
    }
    
    func testCardNonceWithGraphQLJSON_whenAuthenticationInsightIsNotPresent_setsAuthenticationInsightToNil() {
        let cardNonce = BTCardNonce(graphQLJSON: BTJSON(value: [
            "token": "fake-nonce"
            ]))
        
        XCTAssertNil(cardNonce.authenticationInsight)
    }

    func testCardNonceWithGraphQLJSON_ignoresCaseWhenParsingCardType() {
        let cardNonce = BTCardNonce(graphQLJSON: BTJSON(value: [
            "token": "fake-nonce",
            "creditCard": [
                "token": "fake-nonce",
                "brand": "vIsA",
                "last4": "1111"
            ]
            ]))

        XCTAssertEqual(cardNonce.localizedDescription, "ending in 11")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.visa)
        XCTAssertEqual(cardNonce.lastTwo, "11")
        XCTAssertEqual(cardNonce.lastFour, "1111")
        XCTAssertEqual(cardNonce.nonce, "fake-nonce")
        XCTAssertEqual(cardNonce.type, "Visa")
    }

    func testCardNonceWithGraphQLJSON_parsesAllCardTypesCorrectly() {
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
            BTCardNetwork.hiper,
            BTCardNetwork.hipercard,
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
            "hiper",
            "hipercard",
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
            "Hiper",
            "Hipercard",
            "UKMaestro",
            "Visa",
            ]
        for i in 0..<cardNetworks.count {
            let jsonValue = [
                "token": "fake-nonce",
                "creditCard": [
                    "brand": cardTypeJSONValues[i],
                    "last4": "1111"
                ]
            ] as [String : Any]
            let cardNonce = BTCardNonce(graphQLJSON: BTJSON(value: jsonValue))

            XCTAssertEqual(cardNonce.cardNetwork, cardNetworks[i])
            XCTAssertEqual(cardNonce.type, cardTypes[i])
        }
    }

    func testCardNonceWithGraphQLJSON_withCVVOnlyTokenization_createsNonceWithExpectedValues() {
        let cardNonce = BTCardNonce(graphQLJSON: BTJSON(value: [
            "token": "fake-nonce",
            "creditCard": [
                "brand": nil,
                "last4": nil,
                "binData": nil
            ]
            ]))

        XCTAssertEqual(cardNonce.localizedDescription, "")
        XCTAssertEqual(cardNonce.cardNetwork, BTCardNetwork.unknown)
        XCTAssertEqual(cardNonce.lastTwo, "")
        XCTAssertEqual(cardNonce.lastFour, "")
        XCTAssertEqual(cardNonce.nonce, "fake-nonce")
        XCTAssertEqual(cardNonce.type, "Unknown")
        XCTAssertEqual(cardNonce.binData.prepaid, "Unknown")
        XCTAssertEqual(cardNonce.binData.healthcare, "Unknown")
        XCTAssertEqual(cardNonce.binData.debit, "Unknown")
        XCTAssertEqual(cardNonce.binData.durbinRegulated, "Unknown")
        XCTAssertEqual(cardNonce.binData.commercial, "Unknown")
        XCTAssertEqual(cardNonce.binData.payroll, "Unknown")
        XCTAssertEqual(cardNonce.binData.issuingBank, "")
        XCTAssertEqual(cardNonce.binData.countryOfIssuance, "")
        XCTAssertEqual(cardNonce.binData.productId, "")
    }
}
