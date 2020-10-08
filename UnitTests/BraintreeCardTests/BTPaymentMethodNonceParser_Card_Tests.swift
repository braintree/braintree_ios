import XCTest

class BTPaymentMethodNonceParser_Card_Tests: XCTestCase {
    func testSharedParser_whenTypeIsCreditCard_returnsCorrectCardNonce() {
        let sharedParser = BTPaymentMethodNonceParser.shared()
        
        let creditCardJSON = BTJSON(value: [
            "consumed": false,
            "description": "ending in 31",
            "details": [
                "cardType": "American Express",
                "lastTwo": "31",
            ],
            "isLocked": false,
            "nonce": "0099b1d0-7a1c-44c3-b1e4-297082290bb9",
            "securityQuestions": ["cvv"],
            "threeDSecureInfo": NSNull(),
            "type": "CreditCard",
            "default": true
        ])
        
        let cardNonce = sharedParser.parseJSON(creditCardJSON, withParsingBlockForType:"CreditCard")!
        
        XCTAssertEqual(cardNonce.nonce, "0099b1d0-7a1c-44c3-b1e4-297082290bb9")
        XCTAssertEqual(cardNonce.type, "AMEX")
        XCTAssertTrue(cardNonce.isDefault)
    }
}
