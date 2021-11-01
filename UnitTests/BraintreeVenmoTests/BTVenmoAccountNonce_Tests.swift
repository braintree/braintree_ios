import XCTest
import BraintreeVenmo

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

        let venmoAccountNonce = BTVenmoAccountNonce(paymentContextJSON: paymentContextJSON)

        XCTAssertEqual(venmoAccountNonce?.nonce, "some-nonce")
        XCTAssertEqual(venmoAccountNonce?.username, "some-venmo-username")
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

        let venmoAccountNonce = BTVenmoAccountNonce(paymentContextJSON: paymentContextJSON)

        XCTAssertEqual(venmoAccountNonce?.nonce, "some-nonce")
        XCTAssertEqual(venmoAccountNonce?.username, "some-venmo-username")
        XCTAssertEqual(venmoAccountNonce?.email, "venmo-email")
        XCTAssertEqual(venmoAccountNonce?.externalId, "venmo-external-id")
        XCTAssertEqual(venmoAccountNonce?.firstName, "venmo-first-name")
        XCTAssertEqual(venmoAccountNonce?.lastName, "venmo-last-name")
        XCTAssertEqual(venmoAccountNonce?.phoneNumber, "venmo-phone-number")
    }
}
