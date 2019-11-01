import XCTest

class BTCardClient_Tests: XCTestCase {

    // MARK: - ClientAPI
    
    func testTokenization_postsCardDataToClientAPI() {
        let expectation = self.expectation(description: "Tokenize Card")
        let fakeHTTP = FakeHTTP.fakeHTTP()
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = fakeHTTP
        let mockConfigurationHTTP = BTFakeHTTP()!
        mockConfigurationHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/configuration", respondWith: [], statusCode: 200)
        apiClient.configurationHTTP = mockConfigurationHTTP

        let cardClient = BTCardClient(apiClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.cardholderName = "Brian Tree"
        card.authenticationInsightRequested = true
        card.merchantAccountId = "some merchant account id"

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let lastRequest = fakeHTTP.lastRequest else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(lastRequest.endpoint, "v1/payment_methods/credit_cards")
            XCTAssertEqual(lastRequest.method, "POST")

            let params = lastRequest.parameters
            XCTAssertEqual(params["authenticationInsight"] as? Bool, true)
            XCTAssertEqual(params["merchantAccountId"] as? String, "some merchant account id")
            
            guard let cardParams = params["credit_card"] as? [String : AnyObject] else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(cardParams["number"] as? String, "4111111111111111")
            XCTAssertEqual(cardParams["expiration_date"] as? String, "12/2038")
            XCTAssertEqual(cardParams["cvv"] as? String, "1234")
            XCTAssertEqual(cardParams["cardholder_name"] as? String, "Brian Tree")
            
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testTokenization_whenAuthInsightIsNotRequested_postsCardDataWithoutAuthInsight() {
        let expectation = self.expectation(description: "Tokenize Card")
        let fakeHTTP = FakeHTTP.fakeHTTP()
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = fakeHTTP
        let mockConfigurationHTTP = BTFakeHTTP()!
        mockConfigurationHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/configuration", respondWith: [], statusCode: 200)
        apiClient.configurationHTTP = mockConfigurationHTTP
        
        let cardClient = BTCardClient(apiClient: apiClient)
        
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.authenticationInsightRequested = false
        
        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let params = fakeHTTP.lastRequest?.parameters else {
                XCTFail()
                return
            }
            
            XCTAssertNil(params["authenticationInsight"])
            XCTAssertNil(params["merchantAccountId"])
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testTokenization_whenAPIClientSucceeds_returnsTokenizedCard() {
        let expectation = self.expectation(description: "Tokenize Card")
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = FakeHTTP.fakeHTTP()
        let mockConfigurationHTTP = BTFakeHTTP()!
        mockConfigurationHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/configuration", respondWith: [], statusCode: 200)
        apiClient.configurationHTTP = mockConfigurationHTTP

        let cardClient = BTCardClient(apiClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }

            XCTAssertEqual(tokenizedCard.nonce, FakeHTTP.fakeNonce)
            XCTAssertEqual(tokenizedCard.localizedDescription, "Visa ending in 11")
            XCTAssertEqual(tokenizedCard.lastTwo!, "11")
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.visa)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testTokenization_whenAPIClientFails_returnsError() {
        let expectation = self.expectation(description: "Tokenize Card")
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = ErrorHTTP.fakeHTTP()
        let mockConfigurationHTTP = BTFakeHTTP()!
        mockConfigurationHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/configuration", respondWith: [], statusCode: 200)
        apiClient.configurationHTTP = mockConfigurationHTTP

        let cardClient = BTCardClient(apiClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error! as NSError, ErrorHTTP.error)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testTokenization_whenTokenizationEndpointReturns422_callCompletionWithValidationError() {
        let stubAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        let stubJSONResponse = BTJSON(value: [
            "error" : [
                "message" : "Credit card is invalid"
            ],
            "fieldErrors" : [
                [
                    "field" : "creditCard",
                    "fieldErrors" : [
                        [
                            "field" : "number",
                            "message" : "Credit card number must be 12-19 digits",
                            "code" : "81716"
                        ]
                    ]
                ]
            ]
            ])
        let stubError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.clientError.rawValue, userInfo: [
            BTHTTPURLResponseKey: HTTPURLResponse(url: URL(string: "http://fake")!, statusCode: 422, httpVersion: nil, headerFields: nil)!,
            BTHTTPJSONResponseBodyKey: stubJSONResponse
            ])
        stubAPIClient.cannedResponseError = stubError
        let cardClient = BTCardClient(apiClient: stubAPIClient)
        let request = BTCardRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")

        let expectation = self.expectation(description: "Callback invoked with error")
        cardClient.tokenizeCard(request, options: nil) { (cardNonce, error) -> Void in
            XCTAssertNil(cardNonce)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTCardClientErrorType.customerInputInvalid.rawValue)
            if let json = (error.userInfo as NSDictionary)[BTCustomerInputBraintreeValidationErrorsKey] as? NSDictionary {
                XCTAssertEqual(json, (stubJSONResponse as BTJSON).asDictionary()! as NSDictionary)
            } else {
                XCTFail("Expected JSON response in userInfo[BTCustomInputBraintreeValidationErrorsKey]")
            }
            XCTAssertEqual(error.localizedDescription, "Credit card is invalid")
            XCTAssertEqual((error as NSError).localizedFailureReason, "Credit card number must be 12-19 digits")
            
            
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTokenization_whenTokenizationEndpointReturnsAnyNon422Error_callCompletionWithError() {
        let stubAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        stubAPIClient.cannedResponseError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.clientError.rawValue, userInfo: nil)
        let cardClient = BTCardClient(apiClient: stubAPIClient)
        let request = BTCardRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.smsCode = "12345"
        request.enrollmentID = "fake-enrollment-id"

        let expectation = self.expectation(description: "Callback invoked with error")
        cardClient.tokenizeCard(request, options: nil) { (cardNonce, error) -> Void in
            XCTAssertNil(cardNonce)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTHTTPErrorDomain)
            XCTAssertEqual(error.code, BTHTTPErrorCode.clientError.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testMetaParameter_whenTokenizationIsSuccessful_isPOSTedToServer() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        
        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _,_  -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/credit_cards")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let metaParameters = lastPostParameters["_meta"] as! NSDictionary
        XCTAssertEqual(metaParameters["source"] as? String, "unknown")
        XCTAssertEqual(metaParameters["integration"] as? String, "custom")
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionId)
    }

    func testAnalyticsEvent_whenTokenizationSucceeds_isSent() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.custom.card.succeeded"))
    }

    func testCollectsDeviceData_whenEnabled_withCorrectParams_usingNonceAsClientMetadataId_withoutCustomer() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "creditCards": [
                "collectDeviceData": true
            ],
            "merchantId": "fake-merchant"
            ])

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "creditCards": [
                [
                    "nonce": "cmid-nonce",
                    "description": "Visa ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "visa"] ] ]
            ])

        FakePPDataCollector.resetState()
        BTCardClient.setPayPalDataCollectorClass(FakePPDataCollector.self)
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(FakePPDataCollector.didGetClientMetadataID)
        XCTAssertTrue(FakePPDataCollector.lastBeaconState)
        XCTAssertEqual("cmid-nonce", FakePPDataCollector.lastClientMetadataId)
        guard let data:[String : String] = (FakePPDataCollector.lastData as! [String : String]?) else { return XCTFail() }
        XCTAssertEqual("fake-merchant", data["mid"])
        XCTAssertEqual("bt_card", data["rda_tenant"])
        XCTAssertNil(data["cid"])
    }

    func testCollectsDeviceData_whenEnabled_withCorrectParams_withCustomer() {
        let clientTokenString = BTTestClientTokenFactory.token(withVersion: 2, overrides: [
            BTClientTokenKeyConfigURL: "https://api.example.com/client_api/v1/configuration",
            BTClientTokenKeyAuthorizationFingerprint: "an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=fake-customer-123&public_key=integration_public_key"
            ])

        let mockAPIClient = MockAPIClient(authorization: clientTokenString!)!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "creditCards": [
                "collectDeviceData": true
            ],
            "merchantId": "fake-merchant"
            ])

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "creditCards": [
                [
                    "nonce": "cmid-nonce",
                    "description": "Visa ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "visa"] ] ]
            ])

        FakePPDataCollector.resetState()
        BTCardClient.setPayPalDataCollectorClass(FakePPDataCollector.self)
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(FakePPDataCollector.didGetClientMetadataID)
        XCTAssertTrue(FakePPDataCollector.lastBeaconState)
        XCTAssertEqual("cmid-nonce", FakePPDataCollector.lastClientMetadataId)
        guard let data:[String : String] = (FakePPDataCollector.lastData as! [String : String]?) else { return XCTFail() }
        XCTAssertEqual("fake-merchant", data["mid"])
        XCTAssertEqual("bt_card", data["rda_tenant"])
        XCTAssertEqual("fake-customer-123", data["cid"])
    }

    func testDoesNotCollectsDeviceData_whenDisabled() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "creditCards": [
                "collectDeviceData": false
            ],
            "merchantId": "fake-merchant"
            ])

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "creditCards": [
                [
                    "nonce": "cmid-nonce",
                    "description": "Visa ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "visa"] ] ]
            ])

        FakePPDataCollector.resetState()
        BTCardClient.setPayPalDataCollectorClass(FakePPDataCollector.self)
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertFalse(FakePPDataCollector.didGetClientMetadataID)
    }

    func testAnalyticsEvent_whenTokenizationFails_isSent() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let stubJSONResponse = BTJSON(value: [
            "error" : [
                "message" : "Credit card is invalid"
            ],
            "fieldErrors" : [
                [
                    "field" : "creditCard",
                    "fieldErrors" : [
                        [
                            "field" : "number",
                            "message" : "Credit card number must be 12-19 digits",
                            "code" : "81716"
                        ]
                    ]
                ]
            ]
            ])
        let stubError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.clientError.rawValue, userInfo: [
            BTHTTPURLResponseKey: HTTPURLResponse(url: URL(string: "http://fake")!, statusCode: 422, httpVersion: nil, headerFields: nil)!,
            BTHTTPJSONResponseBodyKey: stubJSONResponse
            ])
        mockAPIClient.cannedResponseError = stubError
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.custom.card.failed"))
    }


    // MARK: - GraphQL API

    func testTokenization_whenAuthInsightRequestedIsTrue_andMerchantAccountIdIsNil_returnsError() {
        let mockApiClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockApiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
            ])
        
        let cardClient = BTCardClient(apiClient: mockApiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.authenticationInsightRequested = true
        card.merchantAccountId = nil
        
        let expectation = self.expectation(description: "Returns an error")
        
        cardClient.tokenizeCard(card) { (nonce, error) in
            XCTAssertNil(nonce)
            XCTAssertEqual(error?.localizedDescription,
                           "BTCardClient tokenization failed because a merchant account ID is required when authenticationInsightRequested is true.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testTokenization_whenGraphQLIsEnabled_postsCardDataToGraphQLAPI() {
        let mockApiClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockApiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
            ])

        let cardClient = BTCardClient(apiClient: mockApiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.cardholderName = "Brian Tree"

        let expectation = self.expectation(description: "Tokenize Card")

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertTrue(mockApiClient.lastPOSTAPIClientHTTPType! == BTAPIClientHTTPType.graphQLAPI)
            guard var lastPostParameters = mockApiClient.lastPOSTParameters else {
                XCTFail()
                return
            }
            lastPostParameters.removeValue(forKey: "clientSdkMetadata")
            XCTAssertEqual(lastPostParameters as NSObject, card.graphQLParameters() as NSObject)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testCollectsDeviceData_whenEnabledWithGraphQL_withCorrectParams_usingNonceAsClientMetadataId_withoutCustomer() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "creditCards": [
                "collectDeviceData": true
            ],
            "merchantId": "fake-merchant",
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
            ])

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "tokenizeCreditCard" : [
                    "token" : "abc-nonce",
                    "creditCard" : [
                        "brand" : "Visa",
                        "last4" : "1111",
                        "binData": [
                            "prepaid": "Yes",
                            "healthcare": "Yes",
                            "debit": "No",
                            "durbinRegulated": "No",
                            "commercial": "Yes",
                            "payroll": "No",
                            "issuingBank": "US",
                            "countryOfIssuance": "Something",
                            "productId": "123"
                        ]
                    ]
                ]
            ],
            "extensions": [
            ]
            ])

        FakePPDataCollector.resetState()
        BTCardClient.setPayPalDataCollectorClass(FakePPDataCollector.self)
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.cardholderName = "Brian Tree"

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            XCTAssertTrue(mockAPIClient.lastPOSTAPIClientHTTPType! == BTAPIClientHTTPType.graphQLAPI)
            guard var lastPostParameters = mockAPIClient.lastPOSTParameters else {
                XCTFail()
                return
            }
            lastPostParameters.removeValue(forKey: "clientSdkMetadata")
            XCTAssertEqual(lastPostParameters as NSObject, card.graphQLParameters() as NSObject)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(FakePPDataCollector.didGetClientMetadataID)
        XCTAssertTrue(FakePPDataCollector.lastBeaconState)
        XCTAssertEqual("abc-nonce", FakePPDataCollector.lastClientMetadataId)
        guard let data:[String : String] = (FakePPDataCollector.lastData as! [String : String]?) else { return XCTFail() }
        XCTAssertEqual("fake-merchant", data["mid"])
        XCTAssertEqual("bt_card", data["rda_tenant"])
        XCTAssertNil(data["cid"])
    }

    func testCollectsDeviceData_whenEnabledWithGraphQL_withCustomer() {
        let clientTokenString = BTTestClientTokenFactory.token(withVersion: 2, overrides: [
            BTClientTokenKeyConfigURL: "https://api.example.com/client_api/v1/configuration",
            BTClientTokenKeyAuthorizationFingerprint: "an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=fake-customer-123&public_key=integration_public_key"
            ])

        let mockAPIClient = MockAPIClient(authorization: clientTokenString!)!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "creditCards": [
                "collectDeviceData": true
            ],
            "merchantId": "fake-merchant",
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
            ])

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "tokenizeCreditCard" : [
                    "token" : "abc-nonce",
                    "creditCard" : [
                        "brand" : "Visa",
                        "last4" : "1111",
                        "binData": [
                            "prepaid": "Yes",
                            "healthcare": "Yes",
                            "debit": "No",
                            "durbinRegulated": "No",
                            "commercial": "Yes",
                            "payroll": "No",
                            "issuingBank": "US",
                            "countryOfIssuance": "Something",
                            "productId": "123"
                        ]
                    ]
                ]
            ],
            "extensions": [
            ]
            ])

        FakePPDataCollector.resetState()
        BTCardClient.setPayPalDataCollectorClass(FakePPDataCollector.self)
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.cardholderName = "Brian Tree"

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            XCTAssertTrue(mockAPIClient.lastPOSTAPIClientHTTPType! == BTAPIClientHTTPType.graphQLAPI)
            guard var lastPostParameters = mockAPIClient.lastPOSTParameters else {
                XCTFail()
                return
            }
            lastPostParameters.removeValue(forKey: "clientSdkMetadata")
            XCTAssertEqual(lastPostParameters as NSObject, card.graphQLParameters() as NSObject)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(FakePPDataCollector.didGetClientMetadataID)
        XCTAssertTrue(FakePPDataCollector.lastBeaconState)
        XCTAssertEqual("abc-nonce", FakePPDataCollector.lastClientMetadataId)
        guard let data:[String : String] = (FakePPDataCollector.lastData as! [String : String]?) else { return XCTFail() }
        XCTAssertEqual("fake-merchant", data["mid"])
        XCTAssertEqual("bt_card", data["rda_tenant"])
        XCTAssertEqual("fake-customer-123", data["cid"])
    }

    func testDoesNotCollectsDeviceData_whenDisabledWithGraphQL() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "creditCards": [
                "collectDeviceData": false
            ],
            "merchantId": "fake-merchant",
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
            ])

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "tokenizeCreditCard" : [
                    "token" : "abc-nonce",
                    "creditCard" : [
                        "brand" : "Visa",
                        "last4" : "1111",
                        "binData": [
                            "prepaid": "Yes",
                            "healthcare": "Yes",
                            "debit": "No",
                            "durbinRegulated": "No",
                            "commercial": "Yes",
                            "payroll": "No",
                            "issuingBank": "US",
                            "countryOfIssuance": "Something",
                            "productId": "123"
                        ]
                    ]
                ]
            ],
            "extensions": [
            ]
            ])

        FakePPDataCollector.resetState()
        BTCardClient.setPayPalDataCollectorClass(FakePPDataCollector.self)
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.cardholderName = "Brian Tree"

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            XCTAssertTrue(mockAPIClient.lastPOSTAPIClientHTTPType! == BTAPIClientHTTPType.graphQLAPI)
            guard var lastPostParameters = mockAPIClient.lastPOSTParameters else {
                XCTFail()
                return
            }
            lastPostParameters.removeValue(forKey: "clientSdkMetadata")
            XCTAssertEqual(lastPostParameters as NSObject, card.graphQLParameters() as NSObject)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertFalse(FakePPDataCollector.didGetClientMetadataID)
    }

    func testTokenization_whenGraphQLIsDisabled_postsCardDataToGatewayAPI() {
        let mockApiClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockApiClient.cannedConfigurationResponseBody = BTJSON(value: [
            ])
        
        let cardClient = BTCardClient(apiClient: mockApiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.cardholderName = "Brian Tree"
        
        let expectation = self.expectation(description: "Tokenize Card")
        
        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertTrue(mockApiClient.lastPOSTAPIClientHTTPType! == BTAPIClientHTTPType.gateway)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testTokenization_whenGraphQLFeatureIsNotEnabled_postsCardDataToGatewayAPI() {
        let mockApiClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockApiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["do_not_tokenize_credit_cards"]
            ]
            ])
        
        let cardClient = BTCardClient(apiClient: mockApiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.cardholderName = "Brian Tree"
        
        let expectation = self.expectation(description: "Tokenize Card")
        
        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertTrue(mockApiClient.lastPOSTAPIClientHTTPType! == BTAPIClientHTTPType.gateway)

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testTokenization_whenCardIsUnionPayAndGraphQLEnabledForCards_usesGatewayAPI() {
        let mockApiClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockApiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
            ])

        let cardClient = BTCardClient(apiClient: mockApiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.cardholderName = "Brian Tree"
        let cardRequest = BTCardRequest(card: card)
        cardRequest.enrollmentID = "enrollment-id"
        cardRequest.mobileCountryCode = "1"
        cardRequest.mobilePhoneNumber = "867-5309"
        cardRequest.smsCode = "1234"

        let expectation = self.expectation(description: "Tokenize Card")

        cardClient.tokenizeCard(cardRequest) { (tokenizedCard, error) -> Void in
            XCTAssertTrue(mockApiClient.lastPOSTAPIClientHTTPType! == BTAPIClientHTTPType.gateway)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTokenization_whenGraphQLIsEnabledAndTokenizationIsSuccessful_returnsACardNonce() {
        let mockApiClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockApiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
        ])
        mockApiClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "tokenizeCreditCard" : [
                    "token" : "a-nonce",
                    "creditCard" : [
                        "brand" : "Visa",
                        "last4" : "1111",
                        "binData": [
                            "prepaid": "Yes",
                            "healthcare": "Yes",
                            "debit": "No",
                            "durbinRegulated": "No",
                            "commercial": "Yes",
                            "payroll": "No",
                            "issuingBank": "US",
                            "countryOfIssuance": "Something",
                            "productId": "123"
                        ]
                    ]
                ]
            ],
            "extensions": [
            ]
        ])

        let cardClient = BTCardClient(apiClient: mockApiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")

        let expectation = self.expectation(description: "Tokenize Card")

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail()
                return
            }

            XCTAssertEqual(tokenizedCard.nonce, "a-nonce")
            XCTAssertEqual(tokenizedCard.localizedDescription, "ending in 11")
            XCTAssertEqual(tokenizedCard.type, "Visa")
            XCTAssertEqual(tokenizedCard.lastTwo!, "11")
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.visa)
            XCTAssertEqual(tokenizedCard.binData.prepaid, "Yes")
            XCTAssertEqual(tokenizedCard.binData.healthcare, "Yes")
            XCTAssertEqual(tokenizedCard.binData.debit, "No")
            XCTAssertEqual(tokenizedCard.binData.durbinRegulated, "No")
            XCTAssertEqual(tokenizedCard.binData.commercial, "Yes")
            XCTAssertEqual(tokenizedCard.binData.payroll, "No")
            XCTAssertEqual(tokenizedCard.binData.issuingBank, "US")
            XCTAssertEqual(tokenizedCard.binData.countryOfIssuance, "Something")
            XCTAssertEqual(tokenizedCard.binData.productId, "123")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testAnalyticsEvent_whenTokenizationSucceedsWithGraphQL_isSent() {
        let mockApiClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockApiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
            ])
        mockApiClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "tokenizeCreditCard" : [
                    "token" : "a-nonce",
                    "creditCard" : [
                        "brand" : "Visa",
                        "last4" : "1111",
                        "binData": [
                            "prepaid": "Yes",
                            "healthcare": "Yes",
                            "debit": "No",
                            "durbinRegulated": "No",
                            "commercial": "Yes",
                            "payroll": "No",
                            "issuingBank": "US",
                            "countryOfIssuance": "Something",
                            "productId": "123"
                        ]
                    ]
                ]
            ],
            "extensions": []
            ])

        let cardClient = BTCardClient(apiClient: mockApiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")

        let expectation = self.expectation(description: "Tokenize Card")

        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertTrue(mockApiClient.postedAnalyticsEvents.contains("ios.card.graphql.tokenization.success"))
    }

    func testAnalyticsEvent_whenTokenizationFailsWithGraphQL_isSent() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
            ])
        let stubJSONResponse = BTJSON(value: [
            "error" : [
                "message" : "Credit card is invalid"
            ],
            "fieldErrors" : [
                [
                    "field" : "creditCard",
                    "fieldErrors" : [
                        [
                            "field" : "number",
                            "message" : "Credit card number must be 12-19 digits",
                            "code" : "81716"
                        ]
                    ]
                ]
            ]
            ])
        let stubError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.clientError.rawValue, userInfo: [
            BTHTTPURLResponseKey: HTTPURLResponse(url: URL(string: "http://fake")!, statusCode: 422, httpVersion: nil, headerFields: nil)!,
            BTHTTPJSONResponseBodyKey: stubJSONResponse
            ])
        mockAPIClient.cannedResponseError = stubError
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.card.graphql.tokenization.failure"))
    }
}

// MARK: - Helpers

class FakeHTTP : BTHTTP {
    struct Request {
        let endpoint : String
        let method : String
        let parameters : [AnyHashable: Any]
    }

    static let fakeNonce = "fake-nonce"
    var lastRequest : Request?

    class func fakeHTTP() -> FakeHTTP {
        return FakeHTTP(baseURL: URL(string: "fake://fake")!, authorizationFingerprint: "")
    }

    override func post(_ path: String, parameters: [AnyHashable : Any]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.lastRequest = Request(endpoint: path, method: "POST", parameters: parameters!)

        let response  = HTTPURLResponse(url: URL(string: path)!, statusCode: 202, httpVersion: nil, headerFields: nil)!

        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(BTJSON(value: [
            "creditCards": [
                [
                    "nonce": FakeHTTP.fakeNonce,
                    "description": "Visa ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "visa"] ] ] ]), response, nil)
    }
}

class ErrorHTTP : BTHTTP {
    static let error = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)

    class func fakeHTTP() -> ErrorHTTP {
        let fakeURL = URL(string: "fake://fake")
        return ErrorHTTP(baseURL: fakeURL!, authorizationFingerprint: "")
    }
    
    override func get(_ path: String, parameters: [String : String]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(nil, nil, ErrorHTTP.error)
    }

    override func post(_ path: String, parameters: [AnyHashable : Any]?, completion completionBlock: ((BTJSON?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(nil, nil, ErrorHTTP.error)
    }
}
