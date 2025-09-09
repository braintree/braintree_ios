import XCTest
import BraintreeTestShared
import VisaCheckoutSDK
@testable import BraintreeCore
@testable import BraintreeVisaCheckout

final class BTVisaCheckoutClient_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    var tokenizeResult: CheckoutResultStatus = .statusSuccess
    var callID = "a"
    var encryptedKey = "b"
    var encryptedPaymentData = "c"

    func testCreateProfile_whenConfigurationFetchErrorOccurs_callsCompletionWithError() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "Profile error")

        client.createProfile { profile, error in
            guard let error = error as? NSError else {
                XCTFail("Expected error")
                return
            }

            XCTAssertNil(profile)
            XCTAssertEqual(error.domain, BTVisaCheckoutError.errorDomain)
            XCTAssertEqual(error.code, BTVisaCheckoutError.fetchConfigurationFailed.errorCode)
            XCTAssertEqual(error.localizedDescription, BTVisaCheckoutError.fetchConfigurationFailed.errorDescription)

            expecation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCreateProfile_whenVisaCheckoutIsNotEnabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: {})

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "profile error")

        client.createProfile { profile, error in
            guard let error = error as NSError? else {
                XCTFail("Expected error")
                return
            }
            XCTAssertNil(profile)
            XCTAssertEqual(error.code, BTVisaCheckoutError.disabled.errorCode)
            XCTAssertEqual(error.localizedDescription, BTVisaCheckoutError.disabled.localizedDescription)

            expecation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCreateProfile_whenSuccessful_returnsProfile() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "environment": "sandbox",
            "visaCheckout": [
                "apikey": "API Key",
                "externalClientId": "clientExternalId",
                "supportedCardTypes": [
                    "Visa",
                    "MasterCard",
                    "American Express",
                    "Discover"
                ]
            ]
        ])

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "profile success")

        client.createProfile { profile, error in
            guard let profile else {
                XCTFail("Failed to create profile")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(profile.apiKey, "API Key")
            XCTAssertEqual(profile.environment, .sandbox)
            XCTAssertEqual(profile.datalevel, .full)
            XCTAssertEqual(profile.clientId, "clientExternalId")

            if let acceptedCardBrands = profile.acceptedCardBrands {
                XCTAssertTrue(acceptedCardBrands.count == 4)
            } else {
                XCTFail("Expected 4 accepted card brands.")
            }
            expecation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenCheckoutResultMissingValues_callsCompletionWithIntegrationError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "environment": "sandbox",
            "visaCheckout": [
                "apikey": "API Key",
                "externalClientId": "clientExternalId",
                "supportedCardTypes": [
                    "Visa",
                    "MasterCard",
                    "American Express",
                    "Discover"
                ]
            ]
        ])

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let encryptedKey = "b"
        let encryptedPaymentData = "c"

        let expecation = expectation(description: "Tokenization error due to malformed CheckoutResult")
        
        client.tokenize(statusCode: .statusSuccess, callID: nil, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { nonce, error in
            guard let error = error as? NSError else {
                XCTFail("Error expected")
                return
            }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.code, BTVisaCheckoutError.integration.errorCode)
            XCTAssertEqual(error.localizedDescription, BTVisaCheckoutError.integration.localizedDescription)
            expecation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenStatusCodeIndicatesCancellation_callsCompletionWithNilNonceAndError() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Callback invoked")

        
        client.tokenize(statusCode: .statusUserCancelled, callID: nil, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(error as! BTVisaCheckoutError, BTVisaCheckoutError.canceled)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenStatusCodeIndicatesError_callsCompletionWithError() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Callback invoked")

        client.tokenize(statusCode: .statusInternalError, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { _, error in
            guard let error = error as NSError? else {
                XCTFail("Expected error")
                return
            }
            XCTAssertEqual(error.code, BTVisaCheckoutError.checkoutUnsuccessful.errorCode)
            XCTAssertEqual(error.localizedDescription, BTVisaCheckoutError.checkoutUnsuccessful.localizedDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenStatusCodeIndicatesCancellation_callsAnalyticsWithCancelled() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expectation = expectation(description: "Analytic sent")
        
        client.tokenize(statusCode: .statusUserCancelled, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { _, _ in
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("visa-checkout:tokenize:failed"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenStatusCodeIndicatesError_callsAnalyticsTokenizeFailed() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expectation = expectation(description: "Analytic sent")

        client.tokenize(statusCode: .statusInternalError, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { _, _ in
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("visa-checkout:tokenize:failed"))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenTokenizationErrorOccurs_callsCompletionWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "environment": "sandbox",
            "visaCheckout": [
                "apikey": "API Key",
                "externalClientId": "clientExternalId",
                "supportedCardTypes": [
                    "Visa",
                    "MasterCard",
                    "American Express",
                    "Discover"
                ]
            ]
        ])
        mockAPIClient.cannedHTTPURLResponse = HTTPURLResponse(url: URL(string: "any")!, statusCode: 503, httpVersion: nil, headerFields: nil)
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization error")
        
        client.tokenize(statusCode: .statusSuccess, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { nonce, error in
            guard let error = error as? NSError else {
                XCTFail("Error expected")
                return
            }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTVisaCheckoutError.errorDomain)
            XCTAssertEqual(error.code, BTVisaCheckoutError.failedToCreateNonce.errorCode)
            XCTAssertEqual(error.localizedDescription, BTVisaCheckoutError.failedToCreateNonce.errorDescription)
            expecation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenTokenizationErrorOccurs_sendsAnalyticsEvent() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "environment": "sandbox",
            "visaCheckout": [
                "apikey": "API Key",
                "externalClientId": "clientExternalId",
                "supportedCardTypes": [
                    "Visa",
                    "MasterCard",
                    "American Express",
                    "Discover"
                ]
            ]
        ])
        mockAPIClient.cannedResponseError = NSError(domain: BTVisaCheckoutError.errorDomain, code: BTVisaCheckoutError.fetchConfigurationFailed.errorCode, userInfo: [NSLocalizedDescriptionKey:"fake-error-description"])

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization error")

        client.tokenize(statusCode: .statusSuccess, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { _, _ in
            expecation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "visa-checkout:tokenize:failed")
    }

    func testTokenize_whenCalled_makesPOSTRequestToTokenizationEndpoint() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization success")
        callID = "callID"
        encryptedKey = "encryptedKey"
        encryptedPaymentData = "encryptedPaymentData"

        client.tokenize(statusCode: .statusSuccess, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { _, _ in
            expecation.fulfill()
        }

        waitForExpectations(timeout: 1)

        XCTAssertEqual(self.mockAPIClient.lastPOSTPath, "v1/payment_methods/visa_checkout_cards")

        if let visaCheckoutCard = self.mockAPIClient.lastPOSTParameters?["visaCheckoutCard"] as? [String: String] {
            XCTAssertEqual(visaCheckoutCard, [
                "callId": "callID",
                "encryptedKey": "encryptedKey",
                "encryptedPaymentData": "encryptedPaymentData"
                ]
            )
        } else {
            XCTFail("No post parameter found")
            return
        }
    }

    func testTokenize_whenMissingPhoneNumber_returnsNilForBothAddresses() {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "visaCheckoutCards":[[
                    "type": "VisaCheckoutCard",
                    "nonce": "123456-12345-12345-a-adfa",
                    "description": "ending in ••11",
                    "default": false,
                    "details": [
                        "cardType": "Visa",
                        "lastTwo": "11"
                    ],
                    "shippingAddress": [
                        "firstName": "First",
                        "lastName": "Last",
                        "streetAddress": "123 Townsend St",
                        "locality": "San Francisco",
                        "region": "CA",
                        "postalCode": "94107",
                        "countryCode": "US"
                    ],
                    "billingAddress": [
                        "firstName": "BT",
                        "lastName": "Test",
                        "streetAddress": "123 Townsend St",
                        "locality": "San Francisco",
                        "region": "CA",
                        "postalCode": "94107",
                        "countryCode": "US"
                    ]
                ]]
            ]
        )

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization success")

        client.tokenize(statusCode: .statusSuccess, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { nonce, error in

            guard let nonce else {
                XCTFail("Expected a nonce")
                return
            }
            XCTAssertNil(error)
            XCTAssertNil(nonce.shippingAddress.phoneNumber)
            XCTAssertNil(nonce.billingAddress.phoneNumber)

            expecation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenTokenizationSuccess_callsAPIClientWithVisaCheckoutCard() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "visaCheckoutCards":[[
                "type": "VisaCheckoutCard",
                "nonce": "123456-12345-12345-a-adfa",
                "description": "ending in ••11",
                "default": false,
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "11"
                ],
                "shippingAddress": [
                    "firstName": "First",
                    "lastName": "Last",
                    "streetAddress": "123 Townsend St",
                    "extendedAddress": "Unit 123",
                    "locality": "San Francisco",
                    "region": "CA",
                    "postalCode": "94107",
                    "countryCode": "US",
                    "phoneNumber": "1234567890"
                ],
                "billingAddress": [
                    "firstName": "First",
                    "lastName": "Last",
                    "streetAddress": "123 Townsend St",
                    "extendedAddress": "Unit 123",
                    "locality": "San Francisco",
                    "region": "CA",
                    "postalCode": "94107",
                    "countryCode": "US",
                    "phoneNumber": "1234567890"
                ],
                "userData": [
                    "userFirstName": "userFirstName",
                    "userLastName": "userLastName",
                    "userFullName": "userFullName",
                    "userName": "userUserName",
                    "userEmail": "userEmail"
                ]
                ]]
            ])

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization success")

        client.tokenize(statusCode: .statusSuccess, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { nonce, error in
            guard let nonce else {
                XCTFail("Expected a nonce")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(nonce.type, "Visa")
            XCTAssertEqual(nonce.nonce, "123456-12345-12345-a-adfa")
            XCTAssertEqual(nonce.lastTwo, "11")

            [(nonce.shippingAddress, "shipping"), (nonce.billingAddress, "billing")].forEach { address, value in
                XCTAssertEqual(address.firstName, "First")
                XCTAssertEqual(address.lastName, "Last")
                XCTAssertEqual(address.streetAddress, "123 Townsend St")
                XCTAssertEqual(address.extendedAddress, "Unit 123")
                XCTAssertEqual(address.locality, "San Francisco")
                XCTAssertEqual(address.region, "CA")
                XCTAssertEqual(address.postalCode, "94107")
                XCTAssertEqual(address.countryCode, "US")
                XCTAssertEqual(address.phoneNumber, "1234567890")
            }

            XCTAssertEqual(nonce.userData.userFirstName, "userFirstName")
            XCTAssertEqual(nonce.userData.userLastName, "userLastName")
            XCTAssertEqual(nonce.userData.userFullName, "userFullName")
            XCTAssertEqual(nonce.userData.username, "userUserName")
            XCTAssertEqual(nonce.userData.userEmail , "userEmail")

            expecation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("visa-checkout:tokenize:succeeded"))
    }

    func testTokenize_whenTokenizationSuccess_sendsAnalyticEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "visaCheckoutCards":[[
                    "type": "VisaCheckoutCard",
                    "nonce": "123456-12345-12345-a-adfa",
                    "description": "ending in ••11",
                    "default": false,
                    "details": [
                        "cardType": "Visa",
                        "lastTwo": "11"
                    ],
                    "shippingAddress": [
                        "firstName": "First",
                        "lastName": "Last",
                        "streetAddress": "123 Townsend St",
                        "locality": "San Francisco",
                        "region": "CA",
                        "postalCode": "94107",
                        "countryCode": "US"
                    ],
                    "billingAddress": [
                        "firstName": "BT",
                        "lastName": "Test",
                        "streetAddress": "123 Townsend St",
                        "locality": "San Francisco",
                        "region": "CA",
                        "postalCode": "94107",
                        "countryCode": "US"
                    ]
                ]]
            ]
        )

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization success")

        client.tokenize(statusCode: .statusSuccess, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { _, _ in
            expecation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("visa-checkout:tokenize:succeeded"))
    }
}
