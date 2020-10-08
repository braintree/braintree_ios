import XCTest

class BTPaymentMethodNonceParser_PayPal_Tests: XCTestCase {
    func testSharedParser_whenTypeIsVenmo_returnsVenmoAccountNonce() {
        let sharedParser = BTPaymentMethodNonceParser.shared()
        let venmoAccountJSON = BTJSON(value: [
            "consumed": false,
            "description": "VenmoAccount",
            "details": ["username": "jane.doe.username@example.com", "cardType": "Discover"],
            "isLocked": false,
            "nonce": "a-nonce",
            "securityQuestions": [],
            "type": "VenmoAccount",
            "default": true
        ])
        
        let venmoAccountNonce = sharedParser.parseJSON(venmoAccountJSON, withParsingBlockForType: "VenmoAccount") as! BTVenmoAccountNonce
        
        XCTAssertEqual(venmoAccountNonce.nonce, "a-nonce")
        XCTAssertEqual(venmoAccountNonce.type, "Venmo")
        XCTAssertEqual(venmoAccountNonce.username, "jane.doe.username@example.com")
        XCTAssertTrue(venmoAccountNonce.isDefault)
    }
}
