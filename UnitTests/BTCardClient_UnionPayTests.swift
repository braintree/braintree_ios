import XCTest
import BraintreeUnionPay

class BTCardClient_UnionPayTests: XCTestCase {
   
    // MARK: - Fetch capabilities

    func testFetchCapabilities_sendsGETRequestToCapabilitiesEndpointWithExpectedPayload() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let cardNumber = "411111111111111"

        cardClient.fetchCapabilities(cardNumber) { (_, _) -> Void in }

        XCTAssertEqual(mockAPIClient.lastGETPath, "v1/payment_methods/credit_cards/capabilities")
        guard let lastRequestParameters = mockAPIClient.lastGETParameters as? [String:AnyObject] else {
            XCTFail()
            return
        }
        guard let cardParameters = lastRequestParameters["credit_card"] as? [String:AnyObject] else {
            XCTFail()
            return
        }
        XCTAssertEqual(cardParameters["number"] as? String, cardNumber)
    }

    func testFetchCapabilities_whenSuccessful_parsesCardCapabilitiesFromJSONResponse() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("GET", toEndpoint: "v1/payment_methods/credit_cards/capabilities", respondWith: [
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

    func testEnrollment_sendsPOSTRequestToEnrollmentEndpointWithExpectedPayload() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        let request = BTCardTokenizationRequest(card: card)
        request.mobileCountryCode = "123"
        request.mobilePhoneNumber = "321"

        cardClient.enrollCard(request) { _ -> Void in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/union_pay_enrollments")
        guard let parameters = mockAPIClient.lastPOSTParameters as? [String:AnyObject] else {
            XCTFail()
            return
        }
        guard let enrollment = parameters["union_pay_enrollment"] as? [String:AnyObject] else {
            XCTFail()
            return
        }

        XCTAssertEqual(enrollment["number"] as? String, card.number!)
        XCTAssertEqual(enrollment["expiration_month"] as? String, card.expirationMonth!)
        XCTAssertEqual(enrollment["expiration_year"] as? String, card.expirationYear!)
        XCTAssertEqual(enrollment["cvv"] as? String, card.cvv!)
        XCTAssertEqual(enrollment["mobile_country_code"] as? String, request.mobileCountryCode!)
        XCTAssertEqual(enrollment["mobile_number"] as? String, request.mobilePhoneNumber!)
    }

    func testEnrollCard_whenSuccessful_returnsEnrollmentIDFromJSONResponse() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWith: [
            "unionPayEnrollmentId": "fake-enrollment-id"
            ], statusCode: 201)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardTokenizationRequest(card: card)

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { error -> Void in
            guard let enrollmentID = request.enrollmentID else {
                XCTFail("Expected union pay enrollment")
                return
            }
            XCTAssertNil(error)
            XCTAssertEqual(enrollmentID, "fake-enrollment-id")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testEnrollCard_when422Failure_returnsValidationError() {
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
        let request = BTCardTokenizationRequest(card: card)

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { error -> Void in
            guard let error = error else {
                XCTFail("Expected union pay error")
                return
            }
           
            XCTAssertNil(request.enrollmentID)
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
    
    func testEnrollCard_onError_invokesCallbackOnMainThread() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWithError: NSError(domain: "CannedError", code: 0, userInfo: nil))
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardTokenizationRequest(card: card)
      
        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { _ -> Void in
            XCTAssertTrue(NSThread.isMainThread())
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testEnrollCard_onSuccess_invokesCallbackOnMainThread() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWith: [
            "unionPayEnrollmentId": "fake-enrollment-id"
            ], statusCode: 201)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardTokenizationRequest(card: card)
      
        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { _ -> Void in
            XCTAssertTrue(NSThread.isMainThread())
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testEnrollCard_whenOtherFailure_returnsError() {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken)!
        let stubHTTP = BTFakeHTTP()!
        let stubbedError = NSError(domain: "FakeError", code: 1, userInfo: nil)
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWithError:stubbedError)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardTokenizationRequest(card: card)

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { error -> Void in
            guard let error = error else {
                XCTFail("Expected union pay error")
                return
            }
            
            XCTAssertNil(request.enrollmentID)
            XCTAssertEqual(error.domain, "FakeError")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
   
    // MARK: - Tokenization
    
    func testTokenization_POSTsToTokenizationEndpoint() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let request = BTCardTokenizationRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.enrollmentAuthCode = "12345"
        // This is an internal-only property, but we want to verify that it gets sent when hitting the tokenization endpoint
        request.enrollmentID = "enrollment-id"

        cardClient.tokenizeCard(request, options: nil) { (_, _) -> Void in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/credit_cards")
        
        if let parameters = mockAPIClient.lastPOSTParameters as? [String:AnyObject] {
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

}
