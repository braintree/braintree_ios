import XCTest
import BraintreeCore
@testable import BraintreePayPalNativeCheckout

final class BTPayPalNativeCheckoutAccountNonce_Tests: XCTestCase {

    func testInit_withAllJSON_createsPayPalNativeCheckoutNonceWithAllValues() {
        let nativeCheckoutJSON = BTJSON(
            value: [
                "paypalAccounts": [
                    [
                        "nonce": "a-nonce",
                        "description": "A description",
                        "default": "true",
                        "details": [
                            "correlationId": "a-fake-clientMetadataID",
                            "email": "hello@world.com",
                            "payerInfo": [
                                "firstName": "Some",
                                "lastName": "Dude",
                                "phone": "867-5309",
                                "payerId": "FAKE-PAYER-ID",
                                "accountAddress": [
                                    "street1": "1 Foo Ct",
                                    "street2": "Apt Bar",
                                    "city": "Fubar",
                                    "state": "FU",
                                    "postalCode": "42",
                                    "country": "USA"
                                ],
                                "billingAddress": [
                                    "recipientName": "Bar Foo",
                                    "line1": "2 Foo Ct",
                                    "line2": "Apt Foo",
                                    "city": "Barfoo",
                                    "state": "BF",
                                    "postalCode": "24",
                                    "countryCode": "ASU"
                                ],
                                "shippingAddress": [
                                    "recipientName": "Some Dude",
                                    "line1": "3 Foo Ct",
                                    "line2": "Apt 5",
                                    "city": "Dudeville",
                                    "state": "CA",
                                    "postalCode": "24",
                                    "countryCode": "US"
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        )

        let payPalNativeCheckoutNonce = BTPayPalNativeCheckoutAccountNonce(json: nativeCheckoutJSON)
        XCTAssertNotNil(payPalNativeCheckoutNonce)
        XCTAssertEqual(payPalNativeCheckoutNonce?.nonce, "a-nonce")
        XCTAssertEqual(payPalNativeCheckoutNonce?.isDefault, false)
        XCTAssertEqual(payPalNativeCheckoutNonce?.clientMetadataID, "a-fake-clientMetadataID")
        XCTAssertEqual(payPalNativeCheckoutNonce?.email, "hello@world.com")
        XCTAssertEqual(payPalNativeCheckoutNonce?.firstName, "Some")
        XCTAssertEqual(payPalNativeCheckoutNonce?.lastName, "Dude")
        XCTAssertEqual(payPalNativeCheckoutNonce?.phone, "867-5309")
        XCTAssertEqual(payPalNativeCheckoutNonce?.payerID, "FAKE-PAYER-ID")

        let billingAddress = payPalNativeCheckoutNonce?.billingAddress
        XCTAssertNotNil(billingAddress)
        XCTAssertEqual(billingAddress?.recipientName, "Bar Foo")
        XCTAssertEqual(billingAddress?.streetAddress, "2 Foo Ct")
        XCTAssertEqual(billingAddress?.extendedAddress, "Apt Foo")
        XCTAssertEqual(billingAddress?.locality, "Barfoo")
        XCTAssertEqual(billingAddress?.region, "BF")
        XCTAssertEqual(billingAddress?.postalCode, "24")
        XCTAssertEqual(billingAddress?.countryCodeAlpha2, "ASU")

        let shippingAddress = payPalNativeCheckoutNonce?.shippingAddress!
        XCTAssertNotNil(shippingAddress)
        XCTAssertEqual(shippingAddress?.recipientName, "Some Dude")
        XCTAssertEqual(shippingAddress?.streetAddress, "3 Foo Ct")
        XCTAssertEqual(shippingAddress?.extendedAddress, "Apt 5")
        XCTAssertEqual(shippingAddress?.locality, "Dudeville")
        XCTAssertEqual(shippingAddress?.region, "CA")
        XCTAssertEqual(shippingAddress?.postalCode, "24")
        XCTAssertEqual(shippingAddress?.countryCodeAlpha2, "US")
    }
}
