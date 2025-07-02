import XCTest
@testable import BraintreeCore
@testable import BraintreeVisaCheckout

final class BTVisaCheckoutCardNonce_Tests: XCTestCase {

    func testVisaCheckoutCardNonce_parsesValidJSON() {
        let json = BTJSON(value: [
            "nonce": "fake-nonce",
            "type": "VisaCheckout",
            "default": true,
            "details": [
                "lastTwo": "11",
                "cardType": "visa"
            ],
            "shippingAddress": [
                "firstName": "Alice"
            ],
            "billingAddress": [
                "lastName": "Smith"
            ],
            "userData": [
                "email": "alice@example.com"
            ]
        ])
        
        guard let nonce = BTVisaCheckoutNonce.visaCheckoutCardNonce(with: json) else {
            return XCTFail("Failed to parse valid VisaCheckoutCardNonce")
        }

        XCTAssertEqual(nonce.nonce, "fake-nonce")
        XCTAssertEqual(nonce.type, "VisaCheckout")
//        XCTAssertEqual(nonce.lastTwo, "11")
//        XCTAssertEqual(nonce.cardNetwork, .visa)
        XCTAssertEqual(nonce.isDefault, true)
        XCTAssertEqual(nonce.shippingAddress?.firstName, "Alice")
        XCTAssertEqual(nonce.billingAddress?.lastName, "Smith")
        XCTAssertEqual(nonce.userData?.userEmail, "alice@example.com")
    }

    func testVisaCheckoutCardNonce_returnsNilForMissingFields() {
        let json = BTJSON(value: [
            "type": "VisaCheckout"
            // Missing nonce and lastTwo
        ])

        let result = BTVisaCheckoutNonce.visaCheckoutCardNonce(with: json)
        XCTAssertNil(result, "Expected nil due to missing required fields")
    }

    func testVisaCheckoutCardNonce_defaultsToUnknownCardNetwork() {
        let json = BTJSON(value: [
            "nonce": "123",
            "type": "VisaCheckout",
            "default": false,
            "details": [
                "lastTwo": "99",
                "cardType": "unsupported-card"
            ]
        ])

//        let result = BTVisaCheckoutNonce.visaCheckoutCardNonce(with: json)
//        XCTAssertEqual(result?.cardNetwork, .unknown)
    }
}
