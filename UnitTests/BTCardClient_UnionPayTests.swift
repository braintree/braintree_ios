import XCTest
import BraintreeUnionPay

class BTCardClient_UnionPayTests: XCTestCase {
    
    var apiClient: BTAPIClient!
    
    override func setUp() {
        super.setUp()
        apiClient = clientWithUnionPayEnabled(true)
    }
   
    // MARK: - Fetch capabilities

    func testFetchCapabilities_whenConfigurationFetchFails_returnsError() {
        let stubConfigurationHTTP = BTFakeHTTP()!
        stubConfigurationHTTP.cannedError = NSError(domain: "FakeDomain", code: 2, userInfo: nil)
        apiClient.configurationHTTP = stubConfigurationHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let cardNumber = "411111111111111"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (cardNonce, error) -> Void in
            guard let error = error else {
                XCTFail()
                return
            }
            
            XCTAssertNil(cardNonce)
            XCTAssertEqual(error, stubConfigurationHTTP.cannedError)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testFetchCapabilities_whenCallToCapabilitiesEndpointReturnsError_sendsAnalyticsEvent() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["unionPay": ["enabled": true]])
        mockAPIClient.cannedResponseError = NSError(domain: "FakeError", code: 0, userInfo: nil)
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let cardNumber = "411111111111111"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (_, _) -> Void in
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.capabilities-failed")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testFetchCapabilities_whenUnionPayIsNotEnabledForMerchant_returnsError() {
        apiClient = clientWithUnionPayEnabled(false)
        let cardClient = BTCardClient(APIClient: apiClient)
        let cardNumber = "411111111111111"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (cardNonce, error) -> Void in
            guard let error = error else {
                XCTFail()
                return
            }
            
            XCTAssertNil(cardNonce)
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTCardClientErrorType.PaymentOptionNotEnabled.rawValue)
            XCTAssertEqual(error.localizedDescription, "UnionPay is not enabled for this merchant")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFetchCapabilities_whenUnionPayIsEnabledForMerchant_sendsGETRequestToCapabilitiesEndpointWithExpectedPayload() {
        let mockHTTP = BTFakeHTTP()!
        apiClient.http = mockHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let cardNumber = "411111111111111"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (_, _) -> Void in
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)

        XCTAssertEqual(mockHTTP.lastRequestMethod, "GET")
        XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods/credit_cards/capabilities")
        guard let lastRequestParameters = mockHTTP.lastRequestParameters else {
            XCTFail()
            return
        }
        guard let cardNumberInPayload = lastRequestParameters["credit_card[number]"] as? String else {
            XCTFail()
            return
        }
        XCTAssertEqual(cardNumberInPayload, cardNumber)
    }

    func testFetchCapabilities_whenSuccessful_parsesCardCapabilitiesFromJSONResponse() {
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("GET", toEndpoint: "v1/payment_methods/credit_cards/capabilities", respondWith: [
            "isUnionPay": true,
            "isDebit": false,
            "unionPay": [
                "supportsTwoStepAuthAndCapture": true,
                "isSupported": true
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
            XCTAssertEqual(true, cardCapabilities.isSupported)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testFetchCapabilities_whenSuccessful_sendsAnalyticsEvent() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["unionPay": ["enabled": true]])
        mockAPIClient.cannedResponseBody = BTJSON(value:[
            "isUnionPay": true,
            "isDebit": false,
            "unionPay": [
                "supportsTwoStepAuthAndCapture": true,
                "isSupported": true
                ]
            ])
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let cardNumber = "411111111111111"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (cardCapabilities, error) -> Void in
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.capabilities-received")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testFetchCapabilities_whenFailure_returnsError() {
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

    func testEnroll_whenConfigurationFetchFails_returnsError() {
        let stubConfigurationHTTP = BTFakeHTTP()!
        stubConfigurationHTTP.cannedError = NSError(domain: "FakeDomain", code: 2, userInfo: nil)
        apiClient.configurationHTTP = stubConfigurationHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        let request = BTCardRequest(card: card)
        request.mobileCountryCode = "123"
        request.mobilePhoneNumber = "321"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { (enrollmentID, smsCodeRequired, error) -> Void in
            guard let error = error else {
                XCTFail()
                return
            }
          
            XCTAssertNil(enrollmentID)
            XCTAssertEqual(error, stubConfigurationHTTP.cannedError)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testEnrollment_whenUnionPayIsNotEnabledForMerchant_returnsError() {
        apiClient = clientWithUnionPayEnabled(false)
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        let request = BTCardRequest(card: card)
        request.mobileCountryCode = "123"
        request.mobilePhoneNumber = "321"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { (enrollmentID, smsCodeRequired, error) -> Void in
            guard let error = error else {
                XCTFail()
                return
            }
           
            XCTAssertNil(enrollmentID)
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTCardClientErrorType.PaymentOptionNotEnabled.rawValue)
            XCTAssertEqual(error.localizedDescription, "UnionPay is not enabled for this merchant")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testEnrollment_whenUnionPayIsEnabledForMerchant_sendsPOSTRequestToEnrollmentEndpointWithExpectedPayload() {
        let mockHTTP = BTFakeHTTP()!
        apiClient.http = mockHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        let request = BTCardRequest(card: card)
        request.mobileCountryCode = "123"
        request.mobilePhoneNumber = "321"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { _ -> Void in
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)

        XCTAssertEqual(mockHTTP.lastRequestMethod, "POST")
        XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/union_pay_enrollments")
        guard let parameters = mockHTTP.lastRequestParameters as? [String:AnyObject] else {
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
        XCTAssertEqual(enrollment["mobile_country_code"] as? String, request.mobileCountryCode!)
        XCTAssertEqual(enrollment["mobile_number"] as? String, request.mobilePhoneNumber!)
    }

    func testEnrollmentPayload_doesNotContainCVV() {
        let mockHTTP = BTFakeHTTP()!
        apiClient.http = mockHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        let request = BTCardRequest(card: card)
        request.mobileCountryCode = "123"
        request.mobilePhoneNumber = "321"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { _ -> Void in
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)

        guard let parameters = mockHTTP.lastRequestParameters as? [String:AnyObject] else {
            XCTFail()
            return
        }
        guard let enrollment = parameters["union_pay_enrollment"] as? [String:AnyObject] else {
            XCTFail()
            return
        }

        XCTAssertNil(enrollment["cvv"] as? String)
    }

    func testEnrollCard_whenSuccessful_returnsEnrollmentIDAndSmsCodeRequiredFromJSONResponse() {
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWith: [
            "unionPayEnrollmentId": "fake-enrollment-id",
            "smsCodeRequired": true
            ], statusCode: 201)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardRequest(card: card)

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { (enrollmentID, smsCodeRequired, error) -> Void in
            guard let enrollmentID = enrollmentID else {
                XCTFail("Expected UnionPay enrollment")
                return
            }
            XCTAssertNil(error)
            XCTAssertEqual(enrollmentID, "fake-enrollment-id")
            XCTAssertTrue(smsCodeRequired)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testEnrollCard_when422Failure_returnsValidationError() {
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
        let request = BTCardRequest(card: card)

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { (enrollmentID, smsCodeRequired, error) -> Void in
            guard let error = error else {
                XCTFail("Expected union pay error")
                return
            }
           
            XCTAssertNil(enrollmentID)
            XCTAssertFalse(smsCodeRequired)
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTCardClientErrorType.CustomerInputInvalid.rawValue)
           
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
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWithError: NSError(domain: "CannedError", code: 0, userInfo: nil))
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardRequest(card: card)
      
        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { _ -> Void in
            XCTAssertTrue(NSThread.isMainThread())
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testEnrollCard_whenEnrollmentEndpointReturnsError_sendsAnalyticsEvent() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["unionPay": ["enabled": true]])
        mockAPIClient.cannedResponseError = NSError(domain: "FakeError", code: 0, userInfo: nil)
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardRequest(card: card)
      
        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { _ -> Void in
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.enrollment-failed")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testEnrollCard_onSuccess_invokesCallbackOnMainThread() {
        let stubHTTP = BTFakeHTTP()!
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWith: [
            "unionPayEnrollmentId": "fake-enrollment-id"
            ], statusCode: 201)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardRequest(card: card)
      
        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { _ -> Void in
            XCTAssertTrue(NSThread.isMainThread())
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testEnrollCard_onSuccess_sendsAnalyticsEvent() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["unionPay": ["enabled": true]])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "unionPayEnrollmentId": "fake-enrollment-id",
            "smsCodeRequired": true
        ])
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardRequest(card: card)
      
        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { _ -> Void in
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.enrollment-succeeded")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testEnrollCard_whenOtherFailure_returnsError() {
        let stubHTTP = BTFakeHTTP()!
        let stubbedError = NSError(domain: "FakeError", code: 1, userInfo: nil)
        stubHTTP.stubRequest("POST", toEndpoint: "v1/union_pay_enrollments", respondWithError:stubbedError)
        apiClient.http = stubHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        let request = BTCardRequest(card: card)

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.enrollCard(request) { (enrollmentID, smsCodeRequired, error) -> Void in
            guard let error = error else {
                XCTFail("Expected union pay error")
                return
            }
            
            XCTAssertNil(enrollmentID)
            XCTAssertFalse(smsCodeRequired)
            XCTAssertEqual(error.domain, "FakeError")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
   
    // MARK: - Tokenization
    
    func testTokenization_POSTsToTokenizationEndpoint() {
        let mockHTTP = BTFakeHTTP()!
        apiClient.http = mockHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let request = BTCardRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.smsCode = "12345"
        // This is an internal-only property, but we want to verify that it gets sent when hitting the tokenization endpoint
        request.enrollmentID = "enrollment-id"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.tokenizeCard(request, options: nil) { (_, _) -> Void in
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)

        XCTAssertEqual(mockHTTP.lastRequestMethod, "POST")
        XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods/credit_cards")
        if let parameters = mockHTTP.lastRequestParameters as? [String: AnyObject] {
            guard let cardParameters = parameters["credit_card"] as? [String: AnyObject] else {
                XCTFail("Card should be in parameters")
                return
            }
            XCTAssertEqual(cardParameters["number"] as? String, "4111111111111111")
            XCTAssertEqual(cardParameters["expiration_date"] as? String, "12/2038")
            XCTAssertEqual(cardParameters["cvv"] as? String, "123")
            
            guard let tokenizationOptionsParameters = cardParameters["options"] as? [String: AnyObject] else {
                XCTFail("Tokenization options should be present")
                return
            }
            
            guard let unionPayEnrollmentParameters = tokenizationOptionsParameters["union_pay_enrollment"] as? [String: AnyObject] else {
                XCTFail("UnionPay enrollment should be present")
                return
            }
            
            XCTAssertEqual(unionPayEnrollmentParameters["sms_code"] as? String, "12345")
            XCTAssertEqual(unionPayEnrollmentParameters["id"] as? String, "enrollment-id")
        } else {
            XCTFail()
        }
    }
    
    func testTokenization_withEnrollmentIDAndNoSMSCode_sendsUnionPayEnrollment() {
        let mockHTTP = BTFakeHTTP()!
        apiClient.http = mockHTTP
        let cardClient = BTCardClient(APIClient: apiClient)
        let request = BTCardRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        // This is an internal-only property, but we want to verify that it gets sent when hitting the tokenization endpoint
        request.enrollmentID = "enrollment-id"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.tokenizeCard(request, options: nil) { (_, _) -> Void in
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)

        XCTAssertEqual(mockHTTP.lastRequestMethod, "POST")
        XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods/credit_cards")
        if let parameters = mockHTTP.lastRequestParameters as? [String: AnyObject] {
            guard let cardParameters = parameters["credit_card"] as? [String: AnyObject] else {
                XCTFail("Card should be in parameters")
                return
            }
            XCTAssertEqual(cardParameters["number"] as? String, "4111111111111111")
            XCTAssertEqual(cardParameters["expiration_date"] as? String, "12/2038")
            XCTAssertEqual(cardParameters["cvv"] as? String, "123")
            
            guard let tokenizationOptionsParameters = cardParameters["options"] as? [String: AnyObject] else {
                XCTFail("Tokenization options should be present")
                return
            }
            
            guard let unionPayEnrollmentParameters = tokenizationOptionsParameters["union_pay_enrollment"] as? [String: AnyObject] else {
                XCTFail("UnionPay enrollment should be present")
                return
            }
            
            XCTAssertNil(unionPayEnrollmentParameters["sms_code"])
            XCTAssertEqual(unionPayEnrollmentParameters["id"] as? String, "enrollment-id")
        } else {
            XCTFail()
        }
    }

    func testTokenization_whenTokenizingUnionPayEnrolledCardSucceeds_sendsAnalyticsEvent() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "creditCards": [
                [
                    "nonce": "fake-nonce",
                    "description": "UnionPay ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "unionpay"] ] ] ] )
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let request = BTCardRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.smsCode = "12345"
        request.enrollmentID = "enrollment-id"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.tokenizeCard(request, options: nil) { (_, _) -> Void in
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.nonce-received")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testTokenization_whenTokenizingUnionPayEnrolledCardFails_sendsAnalyticsEvent() {
        let mockAPIClient = MockAPIClient(authorization: BTValidTestClientToken)!
        mockAPIClient.cannedResponseError = NSError(domain: "FakeError", code: 0, userInfo: nil)
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let request = BTCardRequest()
        request.card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: "123")
        request.smsCode = "12345"
        request.enrollmentID = "enrollment-id"

        let expectation = expectationWithDescription("Callback invoked")
        cardClient.tokenizeCard(request, options: nil) { (_, _) -> Void in
            XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.nonce-failed")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // MARK: - Helpers
    
    func clientWithUnionPayEnabled(unionPayEnabled: Bool) -> BTAPIClient {
        let apiClient = BTAPIClient(authorization: BTValidTestClientToken, sendAnalyticsEvent: false)!
        let stubbedConfigurationHTTP = BTFakeHTTP()!
        stubbedConfigurationHTTP.cannedConfiguration = BTJSON(value: ["unionPay": [
            "enabled": unionPayEnabled
            ] ])
        stubbedConfigurationHTTP.cannedStatusCode = 200
        apiClient.configurationHTTP = stubbedConfigurationHTTP
        return apiClient
    }

}
