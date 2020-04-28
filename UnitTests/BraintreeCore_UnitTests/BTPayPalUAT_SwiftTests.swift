import XCTest

class BTPayPalUAT_Tests: XCTestCase {

    func testInitWithUATString_setsAllProperties() {
        let dict: [String : Any] = [
            "iss": "https://api.paypal.com",
            "sub": "PayPal:fake-pp-merchant",
            "acr": [
                "client"
            ],
            "scopes": [
                "Braintree:Vault"
            ],
            "exp": 1571980506,
            "external_ids": [
                "PayPal:fake-pp-merchant",
                "Braintree:fake-bt-merchant"
            ],
            "jti": "fake-jti"
        ]

        let uatString = BTPayPalUATTestHelper.encodeUAT(dict)
        let payPalUAT = try? BTPayPalUAT(uatString: uatString)
        XCTAssertNotNil(payPalUAT)
        XCTAssertEqual(payPalUAT?.token, uatString)
        XCTAssertEqual(payPalUAT?.environment, .prod)
        XCTAssertEqual(payPalUAT?.configURL, URL(string: "https://api.braintreegateway.com:443/merchants/fake-bt-merchant/client_api/v1/configuration"))
        XCTAssertEqual(payPalUAT?.basePayPalURL, URL(string: "https://api.paypal.com"))
        XCTAssertEqual(payPalUAT?.baseBraintreeURL, URL(string: "https://api.braintreegateway.com:443/merchants/fake-bt-merchant/client_api"))
    }

    // MARK: - "iss" field properly indicates env
    func testInitWithUATString_whenUATContainsStagingISS_setsEnvironment() {
        let dict: [String : Any] = [
            "iss": "https://api.msmaster.qa.paypal.com",
            "external_ids": [
                "Braintree:my-merchant"
            ]
        ]
        let uatString = BTPayPalUATTestHelper.encodeUAT(dict)
        let payPalUAT = try? BTPayPalUAT(uatString: uatString)

        XCTAssertEqual(payPalUAT?.environment, .stage)
        XCTAssertEqual(payPalUAT?.baseBraintreeURL, URL(string: "https://api.sandbox.braintreegateway.com:443/merchants/my-merchant/client_api"))
    }

    func testInitWithUATString_whenUATContainsSandboxISS_setsEnvironment() {
        let dict: [String : Any] = [
            "iss": "https://api.sandbox.paypal.com",
            "external_ids": [
                "Braintree:my-merchant"
            ]
        ]
        let uatString = BTPayPalUATTestHelper.encodeUAT(dict)
        let payPalUAT = try? BTPayPalUAT(uatString: uatString)

        XCTAssertEqual(payPalUAT?.environment, .sand)
        XCTAssertEqual(payPalUAT?.baseBraintreeURL, URL(string: "https://api.sandbox.braintreegateway.com:443/merchants/my-merchant/client_api"))
    }

    // MARK: - padding required for base 64 decoding
    func testInitWithUATString_whenZeroPaddingCharactersAreRequired_createsUAT() {
        let uatString = "123.ewogICAiaXNzIjoiaHR0cHM6Ly9hcGkucGF5cGFsLmNvbSIsCiAgICJzdWIiOiJQYXlQYWw6ZmFrZS1wcC1tZXJjaGFudCIsCiAgICJhY3IiOlsKICAgICAgImNsaWVudCIKICAgXSwKICAgInNjb3BlcyI6WwogICAgICAiQnJhaW50cmVlOlZhdWx0IgogICBdLAogICAiZXhwIjoxNTcxOTgwNTA2LAogICAiZXh0ZXJuYWxfaWRzIjpbCiAgICAgICJQYXlQYWw6ZmFrZS1wcC1tZXJjaGFudCIsCiAgICAgICJCcmFpbnRyZWU6ZmFrZS1idC1tZXJjaGFudCIKICAgXSwKICAgImp0aSI6ImZha2UtanRpIgp9.456"

        let payPalUAT = try? BTPayPalUAT(uatString: uatString)
        XCTAssertNotNil(payPalUAT)
        XCTAssertEqual(payPalUAT?.token, uatString)
    }

    func testInitWithUATString_whenOnePaddingCharacterIsRequired_createsUAT() {
        let uatString = "123.ewogICAiaXNzIjoiaHR0cHM6Ly9hcGkucGF5cGFsLmNvbSIsCiAgICJzdWIiOiJQYXlQYWw6ZmFrZS1wcC1tZXJjaGFudCIsCiAgICJhY3IiOlsKICAgICAgImNsaWVudCIKICAgXSwKICAgIm9wdGlvbnMiOnsKCiAgIH0sCiAgICJheiI6ImZha2UtYXoiLAogICAic2NvcGVzIjpbCiAgICAgICJCcmFpbnRyZWU6VmF1bHQiCiAgIF0sCiAgICJleHAiOjE1NzE5ODA1MDYsCiAgICJleHRlcm5hbF9pZHMiOlsKICAgICAgIlBheVBhbDpmYWtlLXBwLW1lcmNoYW50IiwKICAgICAgIkJyYWludHJlZTpmYWtlLWJ0LW1lcmNoYW50IgogICBdLAogICAianRpIjoiZmFrZS1qdGkiCn0.456"

        let payPalUAT = try? BTPayPalUAT(uatString: uatString)
        XCTAssertNotNil(payPalUAT)
        XCTAssertEqual(payPalUAT?.token, uatString)
    }

    func testInitWithUATString_whenTwoPaddingCharactersAreRequired_createsUAT() {
        let uatString = "123.ewogICAiaXNzIjoiaHR0cHM6Ly9hcGkucGF5cGFsLmNvbSIsCiAgICJzdWIiOiJQYXlQYWw6ZmFrZS1wcC1tZXJjaGFudCIsCiAgICJzY29wZXMiOlsKICAgICAgIkJyYWludHJlZTpWYXVsdCIKICAgXSwKICAgImV4cCI6MTU3MTk4MDUwNiwKICAgImV4dGVybmFsX2lkcyI6WwogICAgICAiUGF5UGFsOmZha2UtcHAtbWVyY2hhbnQiLAogICAgICAiQnJhaW50cmVlOmZha2UtYnQtbWVyY2hhbnQiCiAgIF0sCiAgICJqdGkiOiJmYWtlLWp0aSIKfQ.456"

        let payPalUAT = try? BTPayPalUAT(uatString: uatString)
        XCTAssertNotNil(payPalUAT)
        XCTAssertEqual(payPalUAT?.token, uatString)
    }

    // MARK: - error scenarios
    func testInitWithUATString_whenUATStringIsMalformed_throwsError() {
        let uatString = "malformed-uat"

        do {
            let _ = try BTPayPalUAT(uatString: uatString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal UAT: Missing payload.")
        }
    }

    func testInitWithUATString_whenBase64DecodingFails_throwsError() {
        let uatString = "123.&*^(.456"

        do {
            let _ = try BTPayPalUAT(uatString: uatString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal UAT: Unable to base-64 decode payload.")
        }
    }

    func testInitWithUATString_whenJSONSerializationFails_throwsError() {
        let uatString = "123.aW52YWxpZCBqc29u.456"

        do {
            let _ = try BTPayPalUAT(uatString: uatString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal UAT: The data couldn’t be read because it isn’t in the correct format.")
        }
    }

    func testInitWithUATString_whenJSONIsNotDictionary_throwsError() {
        let uatString = "123.WyAic3RyaW5nIiBd.456"

        do {
            let _ = try BTPayPalUAT(uatString: uatString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal UAT: Expected to find an object at JSON root.")
        }
    }

    func testInitWithUATString_whenJSONDoesNotContainExternalIds_throwsError() {
        let dict: [String : Any] = ["hello" : "world"]
        let uatString = BTPayPalUATTestHelper.encodeUAT(dict)

        do {
            let _ = try BTPayPalUAT(uatString: uatString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal UAT: Associated Braintree merchant ID missing.")
        }
    }

    func testInitWithUATString_whenJSONContainsUnknownIssuer_throwsError() {
        let dict: [String : Any] = [
            "iss": "www.im-a-fraud.com",
            "external_ids": [
                "Braintree:fake-bt-merchant"
            ]
        ]
        let uatString = BTPayPalUATTestHelper.encodeUAT(dict)

        do {
            let _ = try BTPayPalUAT(uatString: uatString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal UAT: Issuer missing or unknown.")
        }
    }

    func testInitWithUATString_whenJSONDoesNotContainBraintreeMerchantId_throwsError() {
        let dict: [String : Any] = [
            "external_ids": [
                "PayPal:merchant-id"
            ]
        ]
        let uatString = BTPayPalUATTestHelper.encodeUAT(dict)

        do {
            let _ = try BTPayPalUAT(uatString: uatString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal UAT: Associated Braintree merchant ID missing.")
        }
    }
}
