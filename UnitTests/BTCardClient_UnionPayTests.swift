import XCTest
import BraintreeUnionPay

class BTCardClient_UnionPayTests: XCTestCase {
   
    // TODO: add tests  for enroll and fetchCapabilities that tokenization key returns error
    
    // MARK: - Fetch capabilities
    
    func testFetchCapabilities_whenSuccessful_returnsCardCapabilities() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("GET", toEndpoint: "v1/credit_cards/capabilities", respondWith: [
            "isUnionPay": true,
            "isDebit": false,
            "unionPay": [
                "supportsTwoStepAuthAndCapture": true,
                "isUnionPayEnrollmentRequired": false
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
    
    func testFetchCapabilities_whenFailure_returnsError() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        let stubbedError = NSError(domain: "FakeError", code: 1, userInfo: nil)
        stubHTTP.stubRequest("GET", toEndpoint: "v1/credit_cards/capabilities", respondWithError: stubbedError)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let cardNumber = "411111111111111"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (cardCapabilities, error) -> Void in
            guard let error = error else {
                XCTFail("Expected error")
                return
            }
            
            XCTAssertNil(cardCapabilities)
            XCTAssertEqual(error.domain, stubbedError.domain)
            XCTAssertEqual(error.code, stubbedError.code)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    // MARK: - Enrollment
   
    func testEnrollUnionPayCard_whenSuccessful_returnsEnrollmentID() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWith: [
            "unionPayEnrollmentId": "fake-enrollment-id"
            ], statusCode: 201)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTUnionPayRequest()
        request.card = card

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollUnionPayCard(request) { (enrollmentID, error) -> Void in
            guard let enrollmentID = enrollmentID else {
                XCTFail("Expected union pay enrollment")
                return
            }
            XCTAssertNil(error)
            XCTAssertEqual(enrollmentID, "fake-enrollment-id")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testEnrollUnionPayCard_when422Failure_returnsValidationError() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        let stubbed422HTTPResponse = NSHTTPURLResponse(URL: NSURL(string: "someendpoint")!, statusCode: 422, HTTPVersion: nil, headerFields: nil)!
        let stubbed422ResponseBody = BTJSON(value: ["some": "thing"])
        let stubbedError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.ClientError.rawValue, userInfo: [
            BTHTTPURLResponseKey: stubbed422HTTPResponse,
            BTHTTPJSONResponseBodyKey: stubbed422ResponseBody])
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWithError:stubbedError)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTUnionPayRequest()
        request.card = card

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollUnionPayCard(request) { (enrollmentID, error) -> Void in
            guard let error = error else {
                XCTFail("Expected union pay error")
                return
            }
           
            XCTAssertNil(enrollmentID)
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTError.CustomerInputInvalid.rawValue)
           
            guard let inputErrors = error.userInfo[BTCustomerInputBraintreeValidationErrorsKey] as? [String:String] else {
                XCTFail("Expected error userInfo to contain validation errors")
                return
            }
            XCTAssertEqual(inputErrors["some"], "thing")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    // TODO: Add main thread callback test
    
    func testEnrollUnionPayCard_whenOtherFailure_returnsError() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        let stubbedError = NSError(domain: "FakeError", code: 1, userInfo: nil)
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWithError:stubbedError)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTUnionPayRequest()
        request.card = card

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollUnionPayCard(request) { (enrollmentID, error) -> Void in
            guard let error = error else {
                XCTFail("Expected union pay error")
                return
            }
            
            XCTAssertNil(enrollmentID)
            XCTAssertEqual(error.domain, "FakeError")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
   
    // MARK: - Tokenization
    
    func testTokenization_whenAPIClientUsesTokenizationKey_returnsError() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTUnionPayRequest()
        request.card = card

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.tokenizeUnionPayCard(request, options: nil) { (cardNonce, error) in
            guard let error = error else {
                XCTFail("Expected error")
                return
            }

            XCTAssertEqual(error.domain, BTCardClientErrorDomain);
            XCTAssertEqual(error.code, BTCardClientErrorType.Integration.rawValue);
            XCTAssertEqual(error.localizedDescription, "Cannot use tokenization key with tokenizeUnionPayCard:options:completion:");
            XCTAssertEqual(error.localizedRecoverySuggestion, "Use a client token to authorize BTAPIClient");
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testTokenization_POSTsToTokenizationEndpoint() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let request = BTUnionPayRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.enrollmentAuthCode = "12345"
        // This is an internal-only property, but we want to verify that it gets sent when hitting the tokenization endpoint
        request.enrollmentID = "enrollment-id"

        cardClient.tokenizeUnionPayCard(request, options: nil) { (_, _) -> Void in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/credit_cards")
        
        if let parameters = mockAPIClient.lastPOSTParameters as? [String:AnyObject] {
            print(parameters)
            guard let cardParameters = parameters["credit_card"] as? [String:AnyObject] else {
                XCTFail("Card should be in parameters")
                return
            }
            XCTAssertEqual(cardParameters["number"] as? String, "4111111111111111")
            XCTAssertEqual(cardParameters["expiration_date"] as? String, "12/2038")
            XCTAssertEqual(cardParameters["cvv"] as? String, "123")
            
            guard let tokenizationOptionsParameters = parameters["options"] as? [String:AnyObject] else {
                XCTFail("Tokenization options should be present")
                return
            }
            
            XCTAssertEqual(tokenizationOptionsParameters["sms_code"] as? String, "12345")
            XCTAssertEqual(tokenizationOptionsParameters["id"] as? String, "enrollment-id")
        } else {
            XCTFail()
        }
    }

    func testTokenization_whenTokenizationEndpointReturns422_callCompletionWithValidationError() {
        let stubAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        let stubError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.ClientError.rawValue, userInfo: [
            BTHTTPURLResponseKey: NSHTTPURLResponse(URL: NSURL(string: "http://fake")!, statusCode: 422, HTTPVersion: nil, headerFields: nil)!,
            BTHTTPJSONResponseBodyKey: BTJSON(value: ["someError": "details"])
            ])
        stubAPIClient.cannedResponseError = stubError
        let cardClient = BTCardClient(APIClient: stubAPIClient)
        let request = BTUnionPayRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.enrollmentAuthCode = "12345"

        let expectation = expectationWithDescription("Callback invoked with error")
        cardClient.tokenizeUnionPayCard(request, options: nil) { (cardNonce, error) -> Void in
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
    
    func testTokenization_whenTokenizationEndpointReturnsAnyNon422Error_callCompletionWithError() {
        let stubAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        stubAPIClient.cannedResponseError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.ClientError.rawValue, userInfo: nil)
        let cardClient = BTCardClient(APIClient: stubAPIClient)
        let request = BTUnionPayRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.enrollmentAuthCode = "12345"
        request.enrollmentID = "fake-enrollment-id"

        let expectation = expectationWithDescription("Callback invoked with error")
        cardClient.tokenizeUnionPayCard(request, options: nil) { (cardNonce, error) -> Void in
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

    func testTokenization_whenTokenizationIsSuccessful_returnsCardNonce() {
        let stubAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        stubAPIClient.cannedResponseBody = BTJSON(value: [
            "creditCards": [
                [
                    "nonce": "fake-nonce",
                    "description": "UnionPay ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "unionpay"] ] ] ] )
        let cardClient = BTCardClient(APIClient: stubAPIClient)
        let request = BTUnionPayRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.enrollmentAuthCode = "12345"
        request.enrollmentID = "fake-enrollment-id"

        let expectation = expectationWithDescription("Callback invoked with error")
        cardClient.tokenizeUnionPayCard(request, options: nil) { (cardNonce, error) -> Void in
            guard let cardNonce = cardNonce else {
                XCTFail("Expected card nonce in callback")
                return
            }
            
            print(cardNonce.nonce)
            XCTAssertNil(error)
            XCTAssertEqual(cardNonce.nonce, "fake-nonce")
            XCTAssertEqual(cardNonce.localizedDescription, "UnionPay ending in 11")
            XCTAssertEqual(cardNonce.lastTwo, "11")
            
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

//    func testTokenization_whenChallengeResponseCallbackInvoked_tokenizesCard() {
//        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
//        let stubHTTP = BTFakeHTTP()!
//        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWith: ["unionPayEnrollmentId": "enrollment-id"], statusCode: 201)
//        let stubbedTokenizationResponseJSON = [
//            "creditCards": [
//                [
//                    "nonce": "fake-nonce",
//                    "description": "UnionPay ending in 11",
//                    "details": [
//                        "lastTwo" : "11",
//                        "cardType": "unionpay"] ] ] ]
//        stubHTTP.stubRequest("POST", toEndpoint: "v1/payment_methods/credit_cards", respondWith: stubbedTokenizationResponseJSON, statusCode: 201)
//        apiClient.http = stubHTTP
//        let cardClient = BTCardClient(APIClient: apiClient)
//        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
//        let request = BTUnionPayRequest()
//        request.card = card
//        request.mobileCountryCode = "62"
//        request.mobilePhoneNumber = "867530911"
//
//        let expectation = expectationWithDescription("Callback invoked")
//        cardClient.tokenizeUnionPayCard(request, authCodeChallenge: { $0("12345") }) { (cardNonce, error) -> Void in
//            guard let cardNonce = cardNonce else {
//                XCTFail("Expected card nonce")
//                return
//            }
//            XCTAssertNil(error)
//            XCTAssertEqual(cardNonce.nonce, "fake-nonce")
//            expectation.fulfill()
//        }
//
//        waitForExpectationsWithTimeout(2, handler: nil)
//    }
}
