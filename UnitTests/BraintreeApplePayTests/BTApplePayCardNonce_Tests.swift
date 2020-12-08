import XCTest

class BTApplePayCardNonce_Tests: XCTestCase {

    func testInitWithNonce_populatesAllProperties() {
        let applePayCard = BTJSON(value: [
            "consumed": false,
            "binData": [
                "commercial": "yes"
            ],
            "details": [
                "cardType": "fake-card-type",
                "dpanLastTwo": "11"
            ],
            "nonce": "a-nonce"
        ])

        let applePayNonce = BTApplePayCardNonce(json: applePayCard)
        XCTAssertEqual(applePayNonce?.nonce, "a-nonce")
        XCTAssertEqual(applePayNonce?.dpanLastTwo, "11")
        XCTAssertEqual(applePayNonce?.binData.commercial, "yes")
        XCTAssertEqual(applePayNonce?.type, "fake-card-type")
    }

    func testInitWithNonce_handlesMissingProperties() {
        let applePayCard = BTJSON(value: [
            "consumed": false,
            "binData": [
                "commercial": "yes"
            ],
            "nonce": "a-nonce"
        ])

        let applePayNonce = BTApplePayCardNonce(json: applePayCard)
        XCTAssertNil(applePayNonce?.dpanLastTwo)
        XCTAssertEqual(applePayNonce?.type, "ApplePayCard")
    }

}
