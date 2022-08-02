import XCTest

class BTApplePayCardNonce_Tests: XCTestCase {

    func testInitWithJSON_populatesAllProperties() {
        let applePayCard = BTJSON(value: [
            "consumed": false,
            "binData": [
                "commercial": "yes"
            ],
            "details": [
                "cardType": "fake-card-type"
            ],
            "nonce": "a-nonce"
        ])

        let applePayNonce = BTApplePayCardNonce(json: applePayCard)
        XCTAssertEqual(applePayNonce?.nonce, "a-nonce")
        XCTAssertEqual(applePayNonce?.binData.commercial, "yes")
        XCTAssertEqual(applePayNonce?.type, "fake-card-type")
    }

    func testInitWithJSON_setsDefaultProperties() {
        let applePayCard = BTJSON(value: [
            "consumed": false,
            "binData": [
                "commercial": "yes"
            ],
            "nonce": "a-nonce"
        ])

        let applePayNonce = BTApplePayCardNonce(json: applePayCard)
        XCTAssertEqual(applePayNonce?.type, "ApplePayCard")
    }

    func testBTApplePayCardNonceWithJSON_createsBTApplePayCardNonceWithExpectedValues() {
        let applePayCardNonce = BTApplePayCardNonce(
            json: BTJSON(
                value: [
                    "consumed": false,
                    "details": [
                        "cardType": "American Express"
                    ],
                    "isLocked": false,
                    "nonce": "a-nonce",
                    "securityQuestions": [],
                    "type": "ApplePayCard",
                ]
            )
        )

        XCTAssertEqual(applePayCardNonce?.nonce, "a-nonce")
        XCTAssertEqual(applePayCardNonce?.type, "American Express")
    }
}
