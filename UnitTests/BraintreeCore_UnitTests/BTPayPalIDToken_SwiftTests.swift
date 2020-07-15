import XCTest

class BTPayPalIDToken_Tests: XCTestCase {

    func testInitWithIDTokenString_setsAllProperties() {
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
            "external_id": [
                "PayPal:fake-pp-merchant",
                "Braintree:fake-bt-merchant"
            ],
            "jti": "fake-jti"
        ]

        let idTokenString = BTPayPalIDTokenTestHelper.encodeIDToken(dict)
        let payPalIDToken = try? BTPayPalIDToken(idTokenString: idTokenString)
        XCTAssertNotNil(payPalIDToken)
        XCTAssertEqual(payPalIDToken?.token, idTokenString)
        XCTAssertEqual(payPalIDToken?.environment, .prod)
        XCTAssertEqual(payPalIDToken?.configURL, URL(string: "https://api.braintreegateway.com:443/merchants/fake-bt-merchant/client_api/v1/configuration"))
        XCTAssertEqual(payPalIDToken?.basePayPalURL, URL(string: "https://api.paypal.com"))
        XCTAssertEqual(payPalIDToken?.baseBraintreeURL, URL(string: "https://api.braintreegateway.com:443/merchants/fake-bt-merchant/client_api"))
    }

    // MARK: - "iss" field properly indicates env
    func testInitWithIDTokenString_whenIDTokenContainsStagingISS_setsEnvironment() {
        let dict: [String : Any] = [
            "iss": "https://api.msmaster.qa.paypal.com",
            "external_id": [
                "Braintree:my-merchant"
            ]
        ]
        let idTokenString = BTPayPalIDTokenTestHelper.encodeIDToken(dict)
        let payPalIDToken = try? BTPayPalIDToken(idTokenString: idTokenString)

        XCTAssertEqual(payPalIDToken?.environment, .stage)
        XCTAssertEqual(payPalIDToken?.baseBraintreeURL, URL(string: "https://api.sandbox.braintreegateway.com:443/merchants/my-merchant/client_api"))
    }

    func testInitWithIDTokenString_whenIDTokenContainsSandboxISS_setsEnvironment() {
        let dict: [String : Any] = [
            "iss": "https://api.sandbox.paypal.com",
            "external_id": [
                "Braintree:my-merchant"
            ]
        ]
        let idTokenString = BTPayPalIDTokenTestHelper.encodeIDToken(dict)
        let payPalIDToken = try? BTPayPalIDToken(idTokenString: idTokenString)

        XCTAssertEqual(payPalIDToken?.environment, .sand)
        XCTAssertEqual(payPalIDToken?.baseBraintreeURL, URL(string: "https://api.sandbox.braintreegateway.com:443/merchants/my-merchant/client_api"))
    }

    // MARK: - padding required for base 64 decoding
    func testInitWithIDTokenString_whenZeroPaddingCharactersAreRequired_createsIDToken() {
        let idTokenString = "123.ewogICJpc3MiOiAiaHR0cHM6Ly9hcGkuc2FuZGJveC5wYXlwYWwuY29tIiwKICAic2NvcGUiOiBbCiAgICAiQnJhaW50cmVlOlZhdWx0IgogIF0sCiAgIm9wdGlvbnMiOiB7fSwKICAiZXh0ZXJuYWxfaWQiOiBbCiAgICAiUGF5UGFsOk1KRlAzOVY0TVFSQUUiLAogICAgIkJyYWludHJlZTpjZnhzM2doendmazJyaHFtIgogIF0sCiAgImV4cCI6IDE1OTg4MSwKICAianRpIjogIlUyQUFIckM2Vjdpc2tqa0J6Z2ZORkhSeXNuekJIUUVacWdVMVl4ZG0xaWl1a1poQ2RQQXRjQnhhdGtzNVpzeHlZN1hZbkNST0cydzFfLTFPV2R1LVJDeEMtMVlCYXdJWUotT1FQRUdEYVhNWnhUMExWUjBDOWVnQ3BIdUItZllnIgp9.456"

        let payPalIDToken = try? BTPayPalIDToken(idTokenString: idTokenString)
        XCTAssertNotNil(payPalIDToken)
        XCTAssertEqual(payPalIDToken?.token, idTokenString)
    }

    func testInitWithIDTokenString_whenOnePaddingCharacterIsRequired_createsIDToken() {
        let idTokenString = "123.eyJpc3MiOiJodHRwczovL2FwaS5zYW5kYm94LnBheXBhbC5jb20iLCJzdWIiOiJNSkZQMzlWNE1RUkFFIiwiYWNyIjpbImNsaWVudCJdLCJzY29wZSI6WyJCcmFpbnRyZWU6VmF1bHQiXSwib3B0aW9ucyI6e30sImF6Ijoic2Iuc2xjIiwiZXh0ZXJuYWxfaWQiOlsiUGF5UGFsOk1KRlAzOVY0TVFSQUUiLCJCcmFpbnRyZWU6Y2Z4czNnaHp3ZmsycmhxbSJdLCJleHAiOjE1OTMwODgxMTMsImp0aSI6IlUyQUFIckM2Vjdpc2tqa0J6Z2ZORkhSeXNuekJIUUVacWdVMVl4ZG0xaWl1a1poQ2RQQXRjQnhhdGtzNVpzeHlZN1hZbkNST0cydzFfLTFPV2R1LVJDeEMtMVlCYXdJWUotT1FQRUdEYVhNWnhUMExWUjBDOWVnQ3BIdUItZllnIn0.456"

        let payPalIDToken = try? BTPayPalIDToken(idTokenString: idTokenString)
        XCTAssertNotNil(payPalIDToken)
        XCTAssertEqual(payPalIDToken?.token, idTokenString)
    }

    func testInitWithIDTokenString_whenTwoPaddingCharactersAreRequired_createsIDToken() {
        let idTokenString = "123.ewogICJpc3MiOiAiaHR0cHM6Ly9hcGkuc2FuZGJveC5wYXlwYWwuY29tIiwKICAic2NvcGUiOiBbCiAgICAiQnJhaW50cmVlOlZhdWx0IgogIF0sCiAgIm9wdGlvbnMiOiB7fSwKICAiYXoiOiAic2Iuc2xjIiwKICAiZXh0ZXJuYWxfaWQiOiBbCiAgICAiUGF5UGFsOk1KRlAzOVY0TVFSQUUiLAogICAgIkJyYWludHJlZTpjZnhzM2doendmazJyaHFtIgogIF0sCiAgImV4cCI6IDE1OTMwODgzOTAsCiAgImp0aSI6ICJVMkFBR3V6Wlg2bG5fU1l4M3VjbUJCQ2dRVmxqaklXZ0EtMURBRzFYOWlZNkNxSi1mOV96MFVPVlFrWjhtYVVzVnZLeC0wSzBaNnZjd3ZBN09XV3Z5QktJaEFySEsxVFQxZEY2MmY1V3FjVk1ISzJzdzdkYk9FdzVWbmowcEtZUSIKfQ.456"

        let payPalIDToken = try? BTPayPalIDToken(idTokenString: idTokenString)
        XCTAssertNotNil(payPalIDToken)
        XCTAssertEqual(payPalIDToken?.token, idTokenString)
    }

    // MARK: - error scenarios
    func testInitWithIDTokenString_whenIDTokenStringIsMalformed_throwsError() {
        let idTokenString = "malformed-id-token"

        do {
            let _ = try BTPayPalIDToken(idTokenString: idTokenString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal ID Token: Missing payload.")
        }
    }

    func testInitWithIDTokenString_whenBase64DecodingFails_throwsError() {
        let idTokenString = "123.&*^(.456"

        do {
            let _ = try BTPayPalIDToken(idTokenString: idTokenString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal ID Token: Unable to base-64 decode payload.")
        }
    }

    func testInitWithIDTokenString_whenJSONSerializationFails_throwsError() {
        let idTokenString = "123.aW52YWxpZCBqc29u.456"

        do {
            let _ = try BTPayPalIDToken(idTokenString: idTokenString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal ID Token: The data couldn’t be read because it isn’t in the correct format.")
        }
    }

    func testInitWithIDTokenString_whenJSONIsNotDictionary_throwsError() {
        let idTokenString = "123.WyAic3RyaW5nIiBd.456"

        do {
            let _ = try BTPayPalIDToken(idTokenString: idTokenString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal ID Token: Expected to find an object at JSON root.")
        }
    }

    func testInitWithIDTokenString_whenJSONDoesNotContainExternalIds_throwsError() {
        let dict: [String : Any] = ["hello" : "world"]
        let idTokenString = BTPayPalIDTokenTestHelper.encodeIDToken(dict)

        do {
            let _ = try BTPayPalIDToken(idTokenString: idTokenString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal ID Token: Associated Braintree merchant ID missing.")
        }
    }

    func testInitWithIDTokenString_whenJSONContainsUnknownIssuer_throwsError() {
        let dict: [String : Any] = [
            "iss": "www.im-a-fraud.com",
            "external_id": [
                "Braintree:fake-bt-merchant"
            ]
        ]
        let idTokenString = BTPayPalIDTokenTestHelper.encodeIDToken(dict)

        do {
            let _ = try BTPayPalIDToken(idTokenString: idTokenString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal ID Token: Issuer missing or unknown.")
        }
    }

    func testInitWithIDTokenString_whenJSONDoesNotContainBraintreeMerchantId_throwsError() {
        let dict: [String : Any] = [
            "external_id": [
                "PayPal:merchant-id"
            ]
        ]
        let idTokenString = BTPayPalIDTokenTestHelper.encodeIDToken(dict)

        do {
            let _ = try BTPayPalIDToken(idTokenString: idTokenString)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, "Invalid PayPal ID Token: Associated Braintree merchant ID missing.")
        }
    }
}
