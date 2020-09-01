import XCTest

class BTPaymentMethodNonceParser_ApplePay_Tests: XCTestCase {
    func testSharedParser_whenTypeIsApplePayCard_returnsApplePayCardNonce() {
        let sharedParser = BTPaymentMethodNonceParser.shared()
        let applePayCard = BTJSON(value: [
            "consumed": false,
            "description": "Apple Pay Card ending in 11",
            "details": [
                "cardType": "American Express"
            ],
            "isLocked": false,
            "nonce": "a-nonce",
            "securityQuestions": [],
            "type": "ApplePayCard",
        ])

        let applePayCardNonce = sharedParser.parseJSON(applePayCard, withParsingBlockForType: "ApplePayCard") as? BTApplePayCardNonce

        XCTAssertEqual(applePayCardNonce?.nonce, "a-nonce")
        XCTAssertEqual(applePayCardNonce?.type, "American Express")
        XCTAssertEqual(applePayCardNonce?.localizedDescription, "Apple Pay Card ending in 11")
    }
}
