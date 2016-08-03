import XCTest

class BTCardClient_Tests: XCTestCase {
    
    func testTokenization_postsCardDataToClientAPI() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let fakeHTTP = FakeHTTP.fakeHTTP()
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = fakeHTTP
        let cardClient = BTCardClient(APIClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "1234")
        card.cardholderName = "Brian Tree"

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertEqual(fakeHTTP.lastRequest!.endpoint, "v1/payment_methods/credit_cards")
            XCTAssertEqual(fakeHTTP.lastRequest!.method, "POST")

            if let cardParameters = fakeHTTP.lastRequest!.parameters["credit_card"] as? [String:AnyObject] {
                XCTAssertEqual(cardParameters["number"] as? String, "4111111111111111")
                XCTAssertEqual(cardParameters["expiration_date"] as? String, "12/2038")
                XCTAssertEqual(cardParameters["cvv"] as? String, "1234")
                XCTAssertEqual(cardParameters["cardholder_name"] as? String, "Brian Tree")
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testTokenization_whenAPIClientSucceeds_returnsTokenizedCard() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = FakeHTTP.fakeHTTP()
        let cardClient = BTCardClient(APIClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertEqual(tokenizedCard.nonce, FakeHTTP.fakeNonce)
            XCTAssertEqual(tokenizedCard.localizedDescription, "Visa ending in 11")
            XCTAssertEqual(tokenizedCard.lastTwo!, "11")
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.Visa)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testTokenization_whenAPIClientFails_returnsError() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = ErrorHTTP.fakeHTTP()
        let cardClient = BTCardClient(APIClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error!, ErrorHTTP.error)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
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
        let stubError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.ClientError.rawValue, userInfo: [
            BTHTTPURLResponseKey: NSHTTPURLResponse(URL: NSURL(string: "http://fake")!, statusCode: 422, HTTPVersion: nil, headerFields: nil)!,
            BTHTTPJSONResponseBodyKey: stubJSONResponse
            ])
        stubAPIClient.cannedResponseError = stubError
        let cardClient = BTCardClient(APIClient: stubAPIClient)
        let request = BTCardRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")

        let expectation = expectationWithDescription("Callback invoked with error")
        cardClient.tokenizeCard(request, options: nil) { (cardNonce, error) -> Void in
            guard let error = error else {
                XCTFail("Expected error in callback")
                return
            }
            XCTAssertNil(cardNonce)
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTCardClientErrorType.CustomerInputInvalid.rawValue)
            if let json = error.userInfo[BTCustomerInputBraintreeValidationErrorsKey] as? NSDictionary {
                XCTAssertEqual(json, stubJSONResponse.asDictionary())
            } else {
                XCTFail("Expected JSON response in userInfo[BTCustomInputBraintreeValidationErrorsKey]")
            }
            XCTAssertEqual(error.localizedDescription, "Credit card is invalid")
            XCTAssertEqual(error.localizedFailureReason, "Credit card number must be 12-19 digits")
            
            
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testTokenization_whenTokenizationEndpointReturnsAnyNon422Error_callCompletionWithError() {
        let stubAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        stubAPIClient.cannedResponseError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.ClientError.rawValue, userInfo: nil)
        let cardClient = BTCardClient(APIClient: stubAPIClient)
        let request = BTCardRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.smsCode = "12345"
        request.enrollmentID = "fake-enrollment-id"

        let expectation = expectationWithDescription("Callback invoked with error")
        cardClient.tokenizeCard(request, options: nil) { (cardNonce, error) -> Void in
            guard let error = error else {
                XCTFail("Expected error in callback")
                return
            }
            
            XCTAssertNil(cardNonce)
            XCTAssertEqual(error.domain, BTHTTPErrorDomain)
            XCTAssertEqual(error.code, BTHTTPErrorCode.ClientError.rawValue)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    // MARK: - _meta parameter
    
    func testMetaParameter_whenTokenizationIsSuccessful_isPOSTedToServer() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        
        let expectation = expectationWithDescription("Tokenized card")
        cardClient.tokenizeCard(card) { _ -> Void in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)
        
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
}

// MARK: - Helpers

class FakeHTTP : BTHTTP {
    struct Request {
        let endpoint : String
        let method : String
        let parameters : [NSObject:AnyObject]
    }

    static let fakeNonce = "fake-nonce"
    var lastRequest : Request?

    class func fakeHTTP() -> FakeHTTP {
        return FakeHTTP(baseURL: NSURL(string: "fake://fake")!, authorizationFingerprint: "")
    }

    override func POST(endpoint: String, parameters: [NSObject : AnyObject]?, completion completionBlock: ((BTJSON?, NSHTTPURLResponse?, NSError?) -> Void)?) {
        self.lastRequest = Request(endpoint: endpoint, method: "POST", parameters: parameters!)

        let response  = NSHTTPURLResponse(URL: NSURL(string: endpoint)!, statusCode: 202, HTTPVersion: nil, headerFields: nil)!

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
        return ErrorHTTP(baseURL: NSURL(), authorizationFingerprint: "")
    }
    
    override func GET(endpoint: String, completion completionBlock: ((BTJSON?, NSHTTPURLResponse?, NSError?) -> Void)?) {
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(nil, nil, ErrorHTTP.error)
    }

    override func POST(endpoint: String, parameters: [NSObject : AnyObject]?, completion completionBlock: ((BTJSON?, NSHTTPURLResponse?, NSError?) -> Void)?) {
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(nil, nil, ErrorHTTP.error)
    }
}
