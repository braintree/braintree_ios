import XCTest
@testable import BraintreeCore
@testable import BraintreeVenmo

class BTPaymentMethodNonceParser_Venmo_Tests: XCTestCase {
    func testSharedParser_whenTypeIsVenmo_returnsVenmoAccountNonce() {
        let sharedParser = BTPaymentMethodNonceParser.shared

        let venmoAccountJSON = BTJSON(value: [
            "consumed": false,
            "description": "VenmoAccount",
            "details": ["username": "jane.doe.username@example.com", "cardType": "Discover"],
            "isLocked": false,
            "nonce": "a-nonce",
            "securityQuestions": [] as [Any],
            "type": "VenmoAccount",
            "default": true
        ] as [String: Any])

        let venmoAccountNonce = sharedParser.parseJSON(venmoAccountJSON, withParsingBlockForType: "VenmoAccount") as! BTVenmoAccountNonce

        XCTAssertEqual(venmoAccountNonce.nonce, "a-nonce")
        XCTAssertEqual(venmoAccountNonce.type, "Venmo")
    }
}
