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

    func testInitWithJSON_whenApplePayTokenIsMPAN() {
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

    func testInitWithJSON_whenApplePayTokenIsDPAN() {
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

}
