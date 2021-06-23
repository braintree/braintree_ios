import XCTest

class BTPayPalAccountNonce_Tests: XCTestCase {
    func testInit_setsAllProperties() {
        let jsonString =
        """
        {
            "paypalAccounts": [
                {
                    "nonce": "some-nonce",
                    "default": true,
                    "details": {
                        "email": "test@example.com",
                        "correlationId": "some-correlation-id",
                        "payerInfo": {
                            "firstName": "First",
                            "lastName": "Last",
                            "phone": "1112223333",
                            "payerId": "some-payer-id",
                            "shippingAddress": {
                                "recipientName": "shipping-name",
                                "line1": "123 Main St",
                                "line2": "Apt 3",
                                "city": "Chicago",
                                "state": "IL",
                                "postalCode": "12345",
                                "countryCode": "US"
                            },
                            "billingAddress": {
                                "recipientName": "billing-name",
                                "line1": "456 Main St",
                                "line2": "Unit 7",
                                "city": "Springfield",
                                "state": "MN",
                                "postalCode": "67890",
                                "countryCode": "US"
                            }
                        },
                        "creditFinancingOffered": {
                            "cardAmountImmutable": true,
                            "payerAcceptance": true,
                            "term": 5,
                            "monthlyPayment": {
                                "currency": "USD",
                                "value": "100"
                            },
                            "totalCost": {
                                "currency": "USD",
                                "value": "500"
                            },
                            "totalInterest": {
                                "currency": "USD",
                                "value": "25"
                            }
                        }
                    }
                }
            ]
        }
        """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let accountNonce = BTPayPalAccountNonce(json: json)

        XCTAssertEqual(accountNonce?.nonce, "some-nonce")
        XCTAssertEqual(accountNonce?.type, "PayPal")
        XCTAssertEqual(accountNonce?.isDefault, true)
        XCTAssertEqual(accountNonce?.email, "test@example.com")
        XCTAssertEqual(accountNonce?.clientMetadataID, "some-correlation-id")
        XCTAssertEqual(accountNonce?.firstName, "First")
        XCTAssertEqual(accountNonce?.lastName, "Last")
        XCTAssertEqual(accountNonce?.phone, "1112223333")
        XCTAssertEqual(accountNonce?.payerID, "some-payer-id")

        XCTAssertEqual(accountNonce?.shippingAddress?.recipientName, "shipping-name")
        XCTAssertEqual(accountNonce?.shippingAddress?.streetAddress, "123 Main St")
        XCTAssertEqual(accountNonce?.shippingAddress?.extendedAddress, "Apt 3")
        XCTAssertEqual(accountNonce?.shippingAddress?.locality, "Chicago")
        XCTAssertEqual(accountNonce?.shippingAddress?.region, "IL")
        XCTAssertEqual(accountNonce?.shippingAddress?.postalCode, "12345")
        XCTAssertEqual(accountNonce?.shippingAddress?.countryCodeAlpha2, "US")

        XCTAssertEqual(accountNonce?.billingAddress?.recipientName, "billing-name")
        XCTAssertEqual(accountNonce?.billingAddress?.streetAddress, "456 Main St")
        XCTAssertEqual(accountNonce?.billingAddress?.extendedAddress, "Unit 7")
        XCTAssertEqual(accountNonce?.billingAddress?.locality, "Springfield")
        XCTAssertEqual(accountNonce?.billingAddress?.region, "MN")
        XCTAssertEqual(accountNonce?.billingAddress?.postalCode, "67890")
        XCTAssertEqual(accountNonce?.billingAddress?.countryCodeAlpha2, "US")

        XCTAssertEqual(accountNonce?.creditFinancing?.cardAmountImmutable, true)
        XCTAssertEqual(accountNonce?.creditFinancing?.payerAcceptance, true)
        XCTAssertEqual(accountNonce?.creditFinancing?.term, 5)
        XCTAssertEqual(accountNonce?.creditFinancing?.monthlyPayment?.currency, "USD")
        XCTAssertEqual(accountNonce?.creditFinancing?.monthlyPayment?.value, "100")
        XCTAssertEqual(accountNonce?.creditFinancing?.totalCost?.currency, "USD")
        XCTAssertEqual(accountNonce?.creditFinancing?.totalCost?.value, "500")
        XCTAssertEqual(accountNonce?.creditFinancing?.totalInterest?.currency, "USD")
        XCTAssertEqual(accountNonce?.creditFinancing?.totalInterest?.value, "25")
    }

    func testInit_whenEmailNestedUnderPayerInfo_setsEmail() {
        let jsonString =
        """
        {
            "paypalAccounts": [
                {
                    "nonce": "some-nonce",
                    "default": true,
                    "details": {
                        "payerInfo": {
                            "email": "test@example.com"
                        }
                    }
                }
            ]
        }
        """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let accountNonce = BTPayPalAccountNonce(json: json)

        XCTAssertEqual(accountNonce?.nonce, "some-nonce")
        XCTAssertEqual(accountNonce?.type, "PayPal")
        XCTAssertEqual(accountNonce?.isDefault, true)
        XCTAssertEqual(accountNonce?.email, "test@example.com")
    }

    func testInit_whenShippingAddressIsNotPresent_usesAccountAddress() {
        let jsonString =
        """
        {
            "paypalAccounts": [
                {
                    "nonce": "some-nonce",
                    "default": true,
                    "details": {
                        "payerInfo": {
                            "accountAddress": {
                                "recipientName": "account-name",
                                "street1": "789 Main St",
                                "street2": "Floor 1",
                                "city": "Rockford",
                                "state": "IL",
                                "postalCode": "54321",
                                "countryCode": "US"
                            }
                        }
                    }
                }
            ]
        }
        """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let accountNonce = BTPayPalAccountNonce(json: json)

        XCTAssertEqual(accountNonce?.nonce, "some-nonce")
        XCTAssertEqual(accountNonce?.type, "PayPal")
        XCTAssertEqual(accountNonce?.isDefault, true)

        XCTAssertEqual(accountNonce?.shippingAddress?.recipientName, "account-name")
        XCTAssertEqual(accountNonce?.shippingAddress?.streetAddress, "789 Main St")
        XCTAssertEqual(accountNonce?.shippingAddress?.extendedAddress, "Floor 1")
        XCTAssertEqual(accountNonce?.shippingAddress?.locality, "Rockford")
        XCTAssertEqual(accountNonce?.shippingAddress?.region, "IL")
        XCTAssertEqual(accountNonce?.shippingAddress?.postalCode, "54321")
        XCTAssertEqual(accountNonce?.shippingAddress?.countryCodeAlpha2, "US")
    }

    func testInit_whenNonceIsNotPresent_returnsNil() {
        let jsonString =
        """
        {
            "something": "unexpected"
        }
        """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let accountNonce = BTPayPalAccountNonce(json: json)
        XCTAssertNil(accountNonce)
    }
}
