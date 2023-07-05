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
                        "phoneNumber": "venmo-phone-number",
                        "billingAddress": [
                            "fullName": "Bar Foo",
                            "addressLine1": "1 Foo Ct",
                            "addressLine2": "Apt Foo",
                            "adminArea2": "Barfoo",
                            "adminArea1": "BF",
                            "postalCode": "20",
                            "countryCode": "AU"
                        ],
                        "shippingAddress": [
                            "fullName": "Some Dude",
                            "addressLine1": "2 Foo Ct",
                            "addressLine2": "Apt 5",
                            "adminArea2": "Dudeville",
                            "adminArea1": "CA",
                            "postalCode": "30",
                            "countryCode": "US"
                        ]
                    ]
                ] as [String: Any]
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
        
        let billingAddress = venmoAccountNonce.billingAddress
        XCTAssertNotNil(billingAddress)
        XCTAssertEqual(billingAddress?.recipientName, "Bar Foo")
        XCTAssertEqual(billingAddress?.streetAddress, "1 Foo Ct")
        XCTAssertEqual(billingAddress?.extendedAddress, "Apt Foo")
        XCTAssertEqual(billingAddress?.locality, "Barfoo")
        XCTAssertEqual(billingAddress?.region, "BF")
        XCTAssertEqual(billingAddress?.postalCode, "20")
        XCTAssertEqual(billingAddress?.countryCodeAlpha2, "AU")
        
        let shippingAddress = venmoAccountNonce.shippingAddress
        XCTAssertNotNil(shippingAddress)
        XCTAssertEqual(shippingAddress?.recipientName, "Some Dude")
        XCTAssertEqual(shippingAddress?.streetAddress, "2 Foo Ct")
        XCTAssertEqual(shippingAddress?.extendedAddress, "Apt 5")
        XCTAssertEqual(shippingAddress?.locality, "Dudeville")
        XCTAssertEqual(shippingAddress?.region, "CA")
        XCTAssertEqual(shippingAddress?.postalCode, "30")
        XCTAssertEqual(shippingAddress?.countryCodeAlpha2, "US")
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
                    "securityQuestions": [] as [Any?],
                    "type": "VenmoAccount",
                    "default": true
                ] as [String: Any]
            )
        )

        XCTAssertEqual(venmoAccountNonce.nonce, "a-nonce")
        XCTAssertEqual(venmoAccountNonce.type, "Venmo")
        XCTAssertEqual(venmoAccountNonce.username, "jane.doe.username@example.com")
        XCTAssertTrue(venmoAccountNonce.isDefault)
    }
}
