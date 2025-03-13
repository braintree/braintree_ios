import XCTest
@testable import BraintreeCore
@testable import BraintreeApplePay

class BTApplePayCardNonce_Tests: XCTestCase {

    func testInitWithJSON_populatesAllProperties() {
        let applePayCard = BTJSON(
            value: [
                "consumed": false,
                "binData": [
                    "commercial": "yes"
                ],
                "details": [
                    "cardType": "fake-card-type"
                ],
                "nonce": "a-nonce"
            ] as [String: Any]
        )

        let applePayNonce = BTApplePayCardNonce(json: applePayCard)
        XCTAssertEqual(applePayNonce?.nonce, "a-nonce")
        XCTAssertEqual(applePayNonce?.binData.commercial, "yes")
        XCTAssertEqual(applePayNonce?.type, "fake-card-type")
    }

    func testInitWithJSON_whenApplePayTokenIsMPAN() {
        let applePayCard = BTJSON(
            value: [
                "consumed": false,
                "binData": [
                    "commercial": "yes"
                ],
                "details": [
                    "cardType": "fake-card-type",
                    "isDeviceToken": false
                ],
                "nonce": "a-nonce"
            ] as [String: Any]
        )

        let applePayNonce = BTApplePayCardNonce(json: applePayCard)
        XCTAssertEqual(applePayNonce?.isDeviceToken, false)
    }

    func testInitWithJSON_whenApplePayTokenIsDPAN() {
        let applePayCard = BTJSON(
            value: [
                "consumed": false,
                "binData": [
                    "commercial": "yes"
                ],
                "details": [
                    "cardType": "fake-card-type",
                    "isDeviceToken": true
                ],
                "nonce": "a-nonce"
            ] as [String: Any]
        )

        let applePayNonce = BTApplePayCardNonce(json: applePayCard)
        XCTAssertEqual(applePayNonce?.isDeviceToken, true)
    }

    func testInitWithJSON_setsDefaultProperties() {
        let applePayCard = BTJSON(
            value: [
                "consumed": false,
                "binData": [
                    "commercial": "yes"
                ],
                "nonce": "a-nonce"
            ] as [String: Any]
        )

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
                    "securityQuestions": [] as [Any],
                    "type": "ApplePayCard",
                ] as [String: Any]
            )
        )

        XCTAssertEqual(applePayCardNonce?.nonce, "a-nonce")
        XCTAssertEqual(applePayCardNonce?.type, "American Express")
    }
}
