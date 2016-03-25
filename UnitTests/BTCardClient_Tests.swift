import XCTest

class BTCardClient_Tests: XCTestCase {
    
    func testTokenization_sendsDataToClientAPI() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let fakeHTTP = FakeHTTP.fakeHTTP()
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = fakeHTTP
        let cardClient = BTCardClient(APIClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertEqual(fakeHTTP.lastRequest!.endpoint, "v1/payment_methods/credit_cards")
            XCTAssertEqual(fakeHTTP.lastRequest!.method, "POST")

            if let cardParameters = fakeHTTP.lastRequest!.parameters["credit_card"] as? [String:AnyObject] {
                XCTAssertEqual(cardParameters["number"] as? String, "4111111111111111")
                XCTAssertEqual(cardParameters["expiration_date"] as? String, "12/2038")
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

    // MARK: - UnionPay

    func testUnionPayTokenization_whenAPIClientUsesTokenizationKey_returnsError() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardTokenizationRequest(card: card)

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.tokenizeCard(request, authCodeChallenge: { _ -> Void in }) { (cardNonce, error) -> Void in
            guard let error = error else {
                XCTFail("Expected error")
                return
            }

            XCTAssertEqual(error.domain, BTCardClientErrorDomain);
            XCTAssertEqual(error.code, BTCardClientErrorType.Integration.rawValue);
            XCTAssertEqual(error.localizedDescription, "Cannot use tokenization key with tokenizeCard:authCodeChallenge:completion:");
            XCTAssertEqual(error.localizedRecoverySuggestion, "Use a client token to initialize BTAPIClient");
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testUnionPayTokenization_sendsPOSTRequestToEnrollmentEndpoint() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let mockHTTP = BTFakeHTTP()!
        apiClient.http = mockHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        let request = BTCardTokenizationRequest(card: card)
        request.mobileCountryCode = "62"
        request.mobilePhoneNumber = "867530911"

        cardClient.tokenizeCard(request, authCodeChallenge: { _ -> Void in }) { (_, _) -> Void in }

        XCTAssertEqual(mockHTTP.lastRequestEndpoint!, "v1/union_pay_enrollments")
        XCTAssertEqual(mockHTTP.lastRequestMethod!, "POST")

        if let enrollmentParameters = mockHTTP.lastRequestParameters!["union_pay_enrollment"] as? [String:AnyObject] {
            XCTAssertEqual(enrollmentParameters["number"] as? String, "4111111111111111")
            XCTAssertEqual(enrollmentParameters["expiration_month"] as? String, "12")
            XCTAssertEqual(enrollmentParameters["expiration_year"] as? String, "2038")
            XCTAssertEqual(enrollmentParameters["mobile_country_code"] as? String, "62")
            XCTAssertEqual(enrollmentParameters["mobile_number"] as? String, "867530911")
            XCTAssertEqual(enrollmentParameters["cvv"] as? String, "123")
        } else {
            XCTFail()
        }
    }

    func testUnionPayTokenization_whenEnrollmentEndpointReturns422_callCompletionWithValidationError() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        let stubHTTPResponse = NSHTTPURLResponse(URL: NSURL(string: "http://fake")!, statusCode: 422, HTTPVersion: nil, headerFields: nil)!
        let stubJsonResponse = BTJSON(value: ["someError": "details"])
        let stubError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.ClientError.rawValue, userInfo: [
            BTHTTPURLResponseKey: stubHTTPResponse,
            BTHTTPJSONResponseBodyKey: stubJsonResponse
            ])
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWithError: stubError)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardTokenizationRequest(card: card)
        request.mobileCountryCode = "62"
        request.mobilePhoneNumber = "867530911"

        let expectation = expectationWithDescription("Callback invoked with error")
        cardClient.tokenizeCard(request, authCodeChallenge: { _ -> Void in }) { (cardNonce, error) -> Void in
            guard let error = error else {
                XCTFail("Expected error in callback")
                return
            }
            XCTAssertNil(cardNonce)
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTError.CustomerInputInvalid.rawValue)
            if let json = error.userInfo[BTCustomerInputBraintreeValidationErrorsKey] as? [NSObject:AnyObject] {
                XCTAssertEqual(json["someError"] as? String, "details")
            } else {
                XCTFail("Expected JSON response object in userInfo")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testUnionPayTokenization_whenEnrollmentEndpointReturnsAnyNon422Error_callCompletionWithError() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        let stubHTTPResponse = NSHTTPURLResponse(URL: NSURL(string: "http://fake")!, statusCode: 403, HTTPVersion: nil, headerFields: nil)!
        let stubError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.ClientError.rawValue, userInfo: [
            BTHTTPURLResponseKey: stubHTTPResponse,
            ])
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWithError: stubError)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardTokenizationRequest(card: card)
        request.mobileCountryCode = "62"
        request.mobilePhoneNumber = "867530911"

        let expectation = expectationWithDescription("Callback invoked with error")
        cardClient.tokenizeCard(request, authCodeChallenge: { _ -> Void in }) { (cardNonce, error) -> Void in
            guard let error = error else {
                XCTFail("Expected error in callback")
                return
            }
            if cardNonce != nil {
                XCTFail("Card nonce should be nil")
                return
            }
            XCTAssertEqual(error.domain, BTHTTPErrorDomain)
            XCTAssertEqual(error.code, BTHTTPErrorCode.ClientError.rawValue)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testUnionPayTokenization_whenEnrollmentIsSuccessful_callsAuthChallengeCallback() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWith: ["unionPayEnrollmentId": "enrollment-id"], statusCode: 201)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardTokenizationRequest(card: card)
        request.mobileCountryCode = "62"
        request.mobilePhoneNumber = "867530911"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.tokenizeCard(request, authCodeChallenge: { _ -> Void in
            expectation.fulfill()
            }) { (_, _) -> Void in }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testUnionPayTokenization_whenChallengeResponseCallbackInvoked_tokenizesCard() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWith: ["unionPayEnrollmentId": "enrollment-id"], statusCode: 201)
        let stubbedTokenizationResponseJSON = [
            "creditCards": [
                [
                    "nonce": "fake-nonce",
                    "description": "UnionPay ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "unionpay"] ] ] ]
        stubHTTP.stubRequest("POST", toEndpoint: "v1/payment_methods/credit_cards", respondWith: stubbedTokenizationResponseJSON, statusCode: 201)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardTokenizationRequest(card: card)
        request.mobileCountryCode = "62"
        request.mobilePhoneNumber = "867530911"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.tokenizeCard(request, authCodeChallenge: { $0("12345") }) { (cardNonce, error) -> Void in
            guard let cardNonce = cardNonce else {
                XCTFail("Expected card nonce")
                return
            }
            XCTAssertNil(error)
            XCTAssertEqual(cardNonce.nonce, "fake-nonce")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testUnionPayFetchCapabilities_whenSuccessful_returnsCardCapabilities() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("GET", toEndpoint: "v1/credit_cards/capabilities", respondWith: [
            "isUnionPay": true,
            "isDebit": false,
            "unionPay": [
                "supportsTwoStepAuthAndCapture": true,
                "isUnionPayEnrollmentRequired":false
                ]
            ], statusCode: 201)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let cardNumber = "411111111111111"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (cardCapabilities, error) -> Void in
            guard let cardCapabilities = cardCapabilities else {
                XCTFail("Expected union pay capabilities")
                return
            }
            XCTAssertNil(error)
            XCTAssertEqual(true, cardCapabilities.isUnionPay)
            XCTAssertEqual(false, cardCapabilities.isDebit)
            XCTAssertEqual(true, cardCapabilities.supportsTwoStepAuthAndCapture)
            XCTAssertEqual(false, cardCapabilities.isUnionPayEnrollmentRequired)
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
