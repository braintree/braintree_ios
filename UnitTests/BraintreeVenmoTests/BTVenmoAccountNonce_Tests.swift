import XCTest
@testable import BraintreeVenmo
@testable import BraintreeCore

class BTVenmoAccountNonce_Tests: XCTestCase {

    func testVenmoAccountWithPaymentContext() {
        let paymentContextJSON = BTJSON(value: [
            "data": [
                "node": [
                    "paymentMethodId": "some-nonce",
                    "userName": "some-venmo-username"
                ]
            ]
        ])

        let venmoAccountNonce = BTVenmoAccountNonce(with: paymentContextJSON)

        XCTAssertEqual(venmoAccountNonce.nonce, "some-nonce")
        XCTAssertEqual(venmoAccountNonce.username, "some-venmo-username")
    }

    func testVenmoAccountWithPaymentContext_withPayerInfo() {
        let paymentContextJSON = BTJSON(value: [
            "data": [
                "node": [
                    "paymentMethodId": "some-nonce",
                    "userName": "some-venmo-username",
                    "payerInfo": [
                        "email": "venmo-email",
                        "externalId": "venmo-external-id",
                        "firstName": "venmo-first-name",
                        "lastName": "venmo-last-name",
                        "phoneNumber": "venmo-phone-number"
                    ]
                ]
            ]
        ])

        let venmoAccountNonce = BTVenmoAccountNonce(with: paymentContextJSON)

        XCTAssertEqual(venmoAccountNonce.nonce, "some-nonce")
        XCTAssertEqual(venmoAccountNonce.username, "some-venmo-username")
        XCTAssertEqual(venmoAccountNonce.email, "venmo-email")
        XCTAssertEqual(venmoAccountNonce.externalID, "venmo-external-id")
        XCTAssertEqual(venmoAccountNonce.firstName, "venmo-first-name")
        XCTAssertEqual(venmoAccountNonce.lastName, "venmo-last-name")
        XCTAssertEqual(venmoAccountNonce.phoneNumber, "venmo-phone-number")
    }

    func testBTVenmoAccountNonceWithJSON_createsBTVenmoAccountNonceWithExpectedValues() {
        let venmoAccountNonce = BTVenmoAccountNonce.venmoAccount(
            with: BTJSON(
                value: [
                    "consumed": false,
                    "description": "VenmoAccount",
                    "details": ["username": "jane.doe.username@example.com", "cardType": "Discover"],
                    "isLocked": false,
                    "nonce": "a-nonce",
                    "securityQuestions": [],
                    "type": "VenmoAccount",
                    "default": true
                ]
            )
        )

        XCTAssertEqual(venmoAccountNonce.nonce, "a-nonce")
        XCTAssertEqual(venmoAccountNonce.type, "Venmo")
        XCTAssertEqual(venmoAccountNonce.username, "jane.doe.username@example.com")
        XCTAssertTrue(venmoAccountNonce.isDefault)
    }
}
