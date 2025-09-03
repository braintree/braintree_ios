import XCTest
import BraintreeTestShared
import VisaCheckoutSDK
@testable import BraintreeCore
@testable import BraintreeVisaCheckout

final class BTVisaCheckoutClient_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    var visaCheckoutClient: BTVisaCheckoutClient!
    var checkoutResult: CheckoutResult?
    var tokenizeResult: CheckoutResultStatus = .statusSuccess

    func tokenizeVisaCheckout(status: CheckoutResultStatus, callId: String, encryptedKey: String, encryptedPaymentData: String, completion: @escaping (CheckoutResult?, Error?) -> Void) {
        completion(checkoutResult, nil)
    }

    enum VisaCheckoutProfileBuilderResult {
        case success(Profile)
        case failure(Error)
    }
    
    struct VisaPaymentSummary {
        let callId: String
        let encKey: String
        let encPaymentData: String
    }

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        visaCheckoutClient = BTVisaCheckoutClient(apiClient: mockAPIClient)

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
                    "firstName": "shippingFirstName",
                    "lastName": "shippingLastName",
                    "streetAddress": "shippingStreetAddress",
                    "extendedAddress": "shippingExtendedAddress",
                    "locality": "shippingLocality",
                    "region": "shippingRegion",
                    "postalCode": "shippingPostalCode",
                    "countryCode": "shippingCountryCode",
                    "phoneNumber": "phoneNumber"
                ],
                "billingAddress": [
                    "firstName": "billingFirstName",
                    "lastName": "billingLastName",
                    "streetAddress": "billingStreetAddress",
                    "extendedAddress": "billingExtendedAddress",
                    "locality": "billingLocality",
                    "region": "billingRegion",
                    "postalCode": "billingPostalCode",
                    "countryCode": "billingCountryCode",
                    "phoneNumber": "phoneNumber"
                ]
            ]]
        ])
    }

    func testBTVisaCheckoutAddress_initializesAllPropertiesCorrectly() {
        let json: BTJSON = BTJSON(value: [
            "firstName": "John",
            "lastName": "Doe",
            "streetAddress": "123 Main St",
            "extendedAddress": "Apt 4B",
            "locality": "San Francisco",
            "region": "CA",
            "postalCode": "94105",
            "countryCode": "US",
            "phoneNumber": "1234567890"
        ])

        let address = BTVisaCheckoutAddress(json: json)

        XCTAssertEqual(address.firstName, "John")
        XCTAssertEqual(address.lastName, "Doe")
        XCTAssertEqual(address.streetAddress, "123 Main St")
        XCTAssertEqual(address.extendedAddress, "Apt 4B")
        XCTAssertEqual(address.locality, "San Francisco")
        XCTAssertEqual(address.region, "CA")
        XCTAssertEqual(address.postalCode, "94105")
        XCTAssertEqual(address.countryCode, "US")
        XCTAssertEqual(address.phoneNumber, "1234567890")
    }

    func testBTVisaCheckoutAddress_withMissingValues_returnsNilProperties() {
        let json = BTJSON(value: [:])
        let address = BTVisaCheckoutAddress(json: json)

        XCTAssertNil(address.firstName)
        XCTAssertNil(address.lastName)
        XCTAssertNil(address.streetAddress)
        XCTAssertNil(address.extendedAddress)
        XCTAssertNil(address.locality)
        XCTAssertNil(address.region)
        XCTAssertNil(address.postalCode)
        XCTAssertNil(address.countryCode)
        XCTAssertNil(address.phoneNumber)
    }

    func testCreateProfile_whenConfigurationFetchErrorOccurs_callsCompletionWithError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "MyError", code: 123, userInfo: nil)

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "profile error")

        client.createProfile { (profile, error) in
            let err = error! as NSError
            XCTAssertNil(profile)
            XCTAssertEqual(err.domain, "MyError")
            XCTAssertEqual(err.code, 123)

            expecation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCreateProfile_whenVisaCheckoutIsNotEnabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: {})

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "profile error")

        client.createProfile { profile, error in
            XCTAssertNil(profile)
            XCTAssertEqual(error as! BTVisaCheckoutError, BTVisaCheckoutError.disabled)

            expecation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
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
            guard let profile = profile else {
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

        waitForExpectations(timeout: 1, handler: nil)
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
        let expectedErr = BTVisaCheckoutError.integration
//        let callID: String?
        let encryptedKey = "b"
        let encryptedPaymentData = "c"

        let expecation = expectation(description: "Tokenization error due to malformed CheckoutResult")
        
        client.tokenize(statusCode: .statusSuccess, callID: nil, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { nonce, error in
            if nonce != nil {
                XCTFail("Expected nonce")
                return
            }
            
            guard let error = error else {
                XCTFail("Expected error")
                return
            }

            XCTAssertEqual(error as! BTVisaCheckoutError, expectedErr)
            expecation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testTokenize_whenStatusCodeIndicatesCancellation_callsCompletionWithNilNonceAndError() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Callback invoked")
        let callID = "a"
        let encryptedKey = "b"
        let encryptedPaymentData = "c"
        
        client.tokenize(statusCode: .statusUserCancelled, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { result, error in

            XCTAssertNil(result)
            XCTAssertEqual(error as! BTVisaCheckoutError, BTVisaCheckoutError.canceled)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testTokenize_whenStatusCodeIndicatesError_callsCompletionWitheError() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let statusCodes = [
            CheckoutResultStatus.statusDuplicateCheckoutAttempt,
            CheckoutResultStatus.statusNotConfigured,
            CheckoutResultStatus.statusInternalError
        ]
        let callID = "a"
        let encryptedKey = "b"
        let encryptedPaymentData = "c"
        
        statusCodes.forEach { statusCode in
            let expectation = self.expectation(description: "Callback invoked")
            client.tokenize(statusCode: statusCode, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { _, error in
                guard let error = error as NSError? else {
                    XCTFail("Expected an error to be returned")
                    return
                }

                XCTAssertEqual(error.code, BTVisaCheckoutError.checkoutUnsuccessful.rawValue)
                expectation.fulfill()
            }

            self.waitForExpectations(timeout: 1, handler: nil)
        }
    }

    func testTokenize_whenStatusCodeIndicatesCancellation_callsAnalyticsWithCancelled() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expectation = self.expectation(description: "Analytic sent")
        let callID = "a"
        let encryptedKey = "b"
        let encryptedPaymentData = "c"
        
        client.tokenize(statusCode: .statusUserCancelled, callID: callID, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData) { _, _ in
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, BTVisaCheckoutAnalytics.tokenizeFailed.description)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testTokenize_whenStatusCodeIndicatesError_callsAnalyticsWitheError() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let statusCodes = [
            (statusCode: CheckoutResultStatus.statusDuplicateCheckoutAttempt, analyticEvent: "ios.visacheckout.result.failed.duplicate-checkouts-open"),
            (statusCode: CheckoutResultStatus.statusNotConfigured, analyticEvent: "ios.visacheckout.result.failed.not-configured"),
            (statusCode: CheckoutResultStatus.statusInternalError, analyticEvent: "ios.visacheckout.result.failed.internal-error"),
        ]

        statusCodes.forEach { (statusCode, analyticEvent) in
            let expectation = self.expectation(description: "Analytic sent")
            client.tokenize(statusCode: statusCode, callID: "", encryptedKey: "", encryptedPaymentData: "") { _, _ in
                XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, analyticEvent)
                expectation.fulfill()
            }

            self.waitForExpectations(timeout: 1, handler: nil)
        }
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
        mockAPIClient.cannedResponseError = NSError(domain: "foo", code: 123, userInfo: nil)

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization error")
        
        client.tokenize(statusCode: .statusSuccess, callID: "", encryptedKey: "", encryptedPaymentData: "") { (nonce, err) in
            if nonce != nil {
                XCTFail()
                return
            }

            guard let err = err as NSError? else {
                XCTFail()
                return
            }

            XCTAssertEqual(err, self.mockAPIClient.cannedResponseError)
            expecation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
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
        mockAPIClient.cannedHTTPURLResponse = HTTPURLResponse(url: URL(string: "any")!, statusCode: 503, httpVersion: nil, headerFields: nil)
        mockAPIClient.cannedResponseError = NSError(domain: "foo", code: 123, userInfo: nil)

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization error")

        client.tokenize(statusCode: .statusSuccess, callID: "", encryptedKey: "", encryptedPaymentData: "") { _, _ in
            expecation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.visacheckout.tokenize.failed")
    }

    func testTokenize_whenCalled_makesPOSTRequestToTokenizationEndpoint() {
        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization success")

        client.tokenize(statusCode: .statusSuccess, callID: "callId", encryptedKey: "encryptedKey", encryptedPaymentData: "encryptedPaymentData") { _, _ in
            expecation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertEqual(self.mockAPIClient.lastPOSTPath, "v1/payment_methods/visa_checkout_cards")
        if let visaCheckoutCard = self.mockAPIClient.lastPOSTParameters?["visaCheckoutCard"] as? [String: String] {
            XCTAssertEqual(visaCheckoutCard, [
                "callId": "callId",
                "encryptedKey": "encryptedKey",
                "encryptedPaymentData": "encryptedPaymentData"
                ])
        } else {
            XCTFail()
            return
        }
    }

    func testTokenize_whenMissingPhoneNumber_returnsNilForBothAddresses() {
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
                    "firstName": "BT - shipping",
                    "lastName": "Test - shipping",
                    "streetAddress": "123 Townsend St Fl 6 - shipping",
                    "locality": "San Francisco - shipping",
                    "region": "CA - shipping",
                    "postalCode": "94107 - shipping",
                    "countryCode": "US - shipping"
                ],
                "billingAddress": [
                    "firstName": "BT - billing",
                    "lastName": "Test - billing",
                    "streetAddress": "123 Townsend St Fl 6 - billing",
                    "locality": "San Francisco - billing",
                    "region": "CA - billing",
                    "postalCode": "94107 - billing",
                    "countryCode": "US - billing"
                ]
                ]]
            ])

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization success")
        client.tokenize(statusCode: .statusSuccess, callID: "", encryptedKey: "", encryptedPaymentData: "") { (nonce, error) in
            if (error != nil) {
                XCTFail()
                return
            }

            guard let nonce = nonce else {
                XCTFail()
                return
            }
            
            XCTAssertNil(nonce.shippingAddress.phoneNumber)
            XCTAssertNil(nonce.billingAddress.phoneNumber)

            expecation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
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
                    "firstName": "BT - shipping",
                    "lastName": "Test - shipping",
                    "streetAddress": "123 Townsend St Fl 6 - shipping",
                    "extendedAddress": "Unit 123 - shipping",
                    "locality": "San Francisco - shipping",
                    "region": "CA - shipping",
                    "postalCode": "94107 - shipping",
                    "countryCode": "US - shipping",
                    "phoneNumber": "1234567890 - shipping"
                ],
                "billingAddress": [
                    "firstName": "BT - billing",
                    "lastName": "Test - billing",
                    "streetAddress": "123 Townsend St Fl 6 - billing",
                    "extendedAddress": "Unit 123 - billing",
                    "locality": "San Francisco - billing",
                    "region": "CA - billing",
                    "postalCode": "94107 - billing",
                    "countryCode": "US - billing",
                    "phoneNumber": "1234567890 - billing"
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

        client.tokenize(statusCode: .statusSuccess, callID: "", encryptedKey: "", encryptedPaymentData: "") { (nonce, error) in
            if (error != nil) {
                XCTFail()
                return
            }

            guard let nonce = nonce else {
                XCTFail()
                return
            }

            XCTAssertEqual(nonce.type, "VisaCheckoutCard")
            XCTAssertEqual(nonce.nonce, "123456-12345-12345-a-adfa")
//            XCTAssertEqual(nonce.cardType, BTCardNetwork.visa.rawValue)
            XCTAssertEqual(nonce.lastTwo, "11")

            [(nonce.shippingAddress, "shipping"), (nonce.billingAddress, "billing")].forEach { (address, type) in
                XCTAssertEqual(address.firstName, "BT - " + type)
                XCTAssertEqual(address.lastName, "Test - " + type)
                XCTAssertEqual(address.streetAddress, "123 Townsend St Fl 6 - " + type)
                XCTAssertEqual(address.extendedAddress, "Unit 123 - " + type)
                XCTAssertEqual(address.locality, "San Francisco - " + type)
                XCTAssertEqual(address.region, "CA - " + type)
                XCTAssertEqual(address.postalCode, "94107 - " + type)
                XCTAssertEqual(address.countryCode, "US - " + type)
                XCTAssertEqual(address.phoneNumber, "1234567890 - " + type)
            }

            XCTAssertEqual(nonce.userData.userFirstName, "userFirstName")
            XCTAssertEqual(nonce.userData.userLastName, "userLastName")
            XCTAssertEqual(nonce.userData.userFullName, "userFullName")
            XCTAssertEqual(nonce.userData.username, "userUserName")
            XCTAssertEqual(nonce.userData.userEmail , "userEmail")

            expecation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testTokenize_whenTokenizationSuccess_sendsAnalyticEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "visaCheckoutCards":[[:]]
            ])

        let client = BTVisaCheckoutClient(apiClient: mockAPIClient)
        let expecation = expectation(description: "tokenization success")

        client.tokenize(statusCode: .statusSuccess, callID: "", encryptedKey: "", encryptedPaymentData: "") { _, _ in
            expecation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last, "ios.visacheckout.tokenize.succeeded")
    }
}
