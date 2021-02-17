import XCTest
import BraintreeTestShared
import BraintreeCore.Private

class BTCardClient_Tests: XCTestCase {
    // MARK: - ClientAPI
    
    func testTokenization_postsCardDataToClientAPI() {
        let expectation = self.expectation(description: "Tokenize Card")

        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [])

        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "1234"
        card.cardholderName = "Brian Tree"
        card.authenticationInsightRequested = true
        card.merchantAccountID = "some merchant account id"

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            
            XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/credit_cards")
            XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .gateway)

            guard let params = mockAPIClient.lastPOSTParameters else { XCTFail(); return }
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

        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [])
        
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "1234"
        card.authenticationInsightRequested = false
        
        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/credit_cards")
            XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .gateway)

            guard let params = mockAPIClient.lastPOSTParameters else {
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

        let mockTokenizeResponse = [
            "creditCards": [
                [
                    "nonce": "fake-nonce",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "visa"]
                ]
            ]
        ]

        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [])
        mockAPIClient.cannedResponseBody = BTJSON(value: mockTokenizeResponse)

        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }

            XCTAssertEqual(tokenizedCard.nonce, "fake-nonce")
            XCTAssertEqual(tokenizedCard.lastTwo!, "11")
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.visa)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testTokenization_whenAPIClientFails_returnsError() {
        let expectation = self.expectation(description: "Tokenize Card")

        let mockError = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)

        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [])
        mockAPIClient.cannedResponseError = mockError

        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error! as NSError, mockError)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testTokenization_whenTokenizationEndpointReturns422_callCompletionWithValidationError() {
        let stubAPIClient = MockAPIClient(authorization: TestClientTokenFactory.validClientToken)!
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

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest()
        request.card = card

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
        let stubAPIClient = MockAPIClient(authorization: TestClientTokenFactory.validClientToken)!
        stubAPIClient.cannedResponseError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.clientError.rawValue, userInfo: nil)
        let cardClient = BTCardClient(apiClient: stubAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest()
        request.card = card
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
        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        
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
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionID)
    }

    func testAnalyticsEvent_whenTokenizationSucceeds_isSent() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.custom.card.succeeded"))
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

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.custom.card.failed"))
    }


    // MARK: - GraphQL API

    func testTokenization_whenAuthInsightRequestedIsTrue_andMerchantAccountIDIsNil_returnsError() {
        let mockApiClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockApiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ]
        ])
        
        let cardClient = BTCardClient(apiClient: mockApiClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "1234"
        card.authenticationInsightRequested = true
        card.merchantAccountID = nil
        
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

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "1234"
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

    func testTokenization_whenGraphQLIsDisabled_postsCardDataToGatewayAPI() {
        let mockApiClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockApiClient.cannedConfigurationResponseBody = BTJSON(value: [
        ])
        
        let cardClient = BTCardClient(apiClient: mockApiClient)
        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "1234"
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
        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "1234"
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

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "1234"
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

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "1234"

        let expectation = self.expectation(description: "Tokenize Card")

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail()
                return
            }

            XCTAssertEqual(tokenizedCard.nonce, "a-nonce")
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
            XCTAssertEqual(tokenizedCard.binData.productID, "123")

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

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "1234"

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

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let expectation = self.expectation(description: "Tokenized card")
        cardClient.tokenizeCard(card) { _, _ -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.card.graphql.tokenization.failure"))
    }
}
