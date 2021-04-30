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
}
