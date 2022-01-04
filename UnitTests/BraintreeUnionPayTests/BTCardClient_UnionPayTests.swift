import XCTest
import BraintreeUnionPay
import BraintreeTestShared

class BTCardClient_UnionPayTests: XCTestCase {
    
    var mockAPIClient: MockAPIClient!
    let standardTimeout: TimeInterval = 2
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: TestClientTokenFactory.validClientToken)!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["unionPay": ["enabled": true]])
    }

    // MARK: - Fetch capabilities

    func testFetchCapabilities_whenConfigurationFetchFails_returnsError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "FakeDomain", code: 2, userInfo: nil)

        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let cardNumber = "411111111111111"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (cardNonce, error) -> Void in
            guard let error = error as NSError? else {
                XCTFail()
                return
            }

            XCTAssertNil(cardNonce)
            XCTAssertEqual(error.domain, "FakeDomain")
            XCTAssertEqual(error.code, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    func testFetchCapabilities_whenCallToCapabilitiesEndpointReturnsError_sendsAnalyticsEvent() {
        mockAPIClient.cannedResponseError = NSError(domain: "FakeError", code: 0, userInfo: nil)
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let cardNumber = "411111111111111"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (_, _) -> Void in
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.capabilities-failed")
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    func testFetchCapabilities_whenUnionPayIsNotEnabledForMerchant_returnsError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["unionPay": ["enabled": false]])
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let cardNumber = "411111111111111"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (cardNonce, error) -> Void in
            XCTAssertNil(cardNonce)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTCardClientErrorType.paymentOptionNotEnabled.rawValue)
            XCTAssertEqual(error.localizedDescription, "UnionPay is not enabled for this merchant")
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }
    
    func testFetchCapabilities_whenUnionPayIsEnabledForMerchant_sendsGETRequestToCapabilitiesEndpointWithExpectedPayload() {
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let cardNumber = "411111111111111"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (_, _) -> Void in
            expectation.fulfill()
        }
        waitForExpectations(timeout: standardTimeout, handler: nil)

        XCTAssertEqual(self.mockAPIClient.lastGETPath, "v1/payment_methods/credit_cards/capabilities")
        guard let lastRequestParameters = self.mockAPIClient.lastGETParameters else {
            XCTFail()
            return
        }

        XCTAssertEqual(lastRequestParameters["credit_card[number]"], cardNumber)
    }

    func testFetchCapabilities_whenSuccessful_parsesCardCapabilitiesFromJSONResponse() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "isUnionPay": true,
            "isDebit": false,
            "unionPay": [
                "supportsTwoStepAuthAndCapture": true,
                "isSupported": true
            ]
        ])

        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let cardNumber = "411111111111111"

        let expectation = self.expectation(description: "Callback invoked")
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

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    func testFetchCapabilities_whenSuccessful_sendsAnalyticsEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(value:[
            "isUnionPay": true,
            "isDebit": false,
            "unionPay": [
                "supportsTwoStepAuthAndCapture": true,
                "isSupported": true
            ]
        ])
        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let cardNumber = "411111111111111"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (cardCapabilities, error) -> Void in
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.capabilities-received")
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    func testFetchCapabilities_whenFailure_returnsError() {
        mockAPIClient.cannedResponseError = NSError(domain: "FakeError", code: 1, userInfo: nil)

        let cardClient = BTCardClient(apiClient: mockAPIClient)
        let cardNumber = "411111111111111"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.fetchCapabilities(cardNumber) { (cardCapabilities, error) -> Void in
            XCTAssertNil(cardCapabilities)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "FakeError")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }
    
    // MARK: - Enrollment

    func testEnroll_whenConfigurationFetchFails_returnsError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "FakeDomain", code: 2, userInfo: nil)

        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest(card: card)
        request.mobileCountryCode = "123"
        request.mobilePhoneNumber = "321"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { (enrollmentID, smsCodeRequired, error) -> Void in
            guard let error = error as NSError? else {
                XCTFail()
                return
            }

            XCTAssertNil(enrollmentID)
            XCTAssertEqual(error.domain, "FakeDomain")
            XCTAssertEqual(error.code, 2)
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }
    
    func testEnrollment_whenUnionPayIsNotEnabledForMerchant_returnsError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["unionPay": ["enabled": false]])
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest(card: card)
        request.mobileCountryCode = "123"
        request.mobilePhoneNumber = "321"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { (enrollmentID, smsCodeRequired, error) -> Void in
            XCTAssertNil(enrollmentID)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTCardClientErrorType.paymentOptionNotEnabled.rawValue)
            XCTAssertEqual(error.localizedDescription, "UnionPay is not enabled for this merchant")
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    func testEnrollment_whenUnionPayIsEnabledForMerchant_sendsPOSTRequestToEnrollmentEndpointWithExpectedPayload() {
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest(card: card)
        request.mobileCountryCode = "123"
        request.mobilePhoneNumber = "321"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { _,_,_  -> Void in
            expectation.fulfill()
        }
        waitForExpectations(timeout: standardTimeout, handler: nil)

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
        XCTAssertEqual(enrollment["mobile_country_code"] as? String, request.mobileCountryCode!)
        XCTAssertEqual(enrollment["mobile_number"] as? String, request.mobilePhoneNumber!)
    }

    func testEnrollmentPayload_doesNotContainCVV() {
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest(card: card)
        request.mobileCountryCode = "123"
        request.mobilePhoneNumber = "321"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { _,_,_  -> Void in
            expectation.fulfill()
        }
        waitForExpectations(timeout: standardTimeout, handler: nil)

        guard let parameters = mockAPIClient.lastPOSTParameters as? [String:AnyObject] else {
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
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "unionPayEnrollmentId": "fake-enrollment-id",
            "smsCodeRequired": true
        ])

        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let request = BTCardRequest(card: card)

        let expectation = self.expectation(description: "Callback invoked")
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

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }
    
    func testEnrollCard_when422Failure_returnsValidationError() {
        let stubbed422HTTPResponse = HTTPURLResponse(url: URL(string: "someendpoint")!, statusCode: 422, httpVersion: nil, headerFields: nil)!
        let stubbed422ResponseBody = BTJSON(value: ["some": "thing"])
        mockAPIClient.cannedResponseError = NSError(domain: BTHTTPErrorDomain, code: BTHTTPErrorCode.clientError.rawValue, userInfo: [
                                    BTHTTPURLResponseKey: stubbed422HTTPResponse,
                                    BTHTTPJSONResponseBodyKey: stubbed422ResponseBody])

        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let request = BTCardRequest(card: card)

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { (enrollmentID, smsCodeRequired, error) -> Void in
            XCTAssertNil(enrollmentID)
            XCTAssertFalse(smsCodeRequired)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTCardClientErrorDomain)
            XCTAssertEqual(error.code, BTCardClientErrorType.customerInputInvalid.rawValue)

            guard let inputErrors = (error._userInfo as! NSDictionary)[BTCustomerInputBraintreeValidationErrorsKey] as? NSDictionary else {
                XCTFail("Expected error userInfo to contain validation errors")
                return
            }
            XCTAssertEqual(inputErrors["some"] as! String, "thing")

            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }
    
    func testEnrollCard_onError_invokesCallbackOnMainThread() {
        mockAPIClient.cannedResponseError = NSError(domain: "CannedError", code: 0, userInfo: nil)

        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let request = BTCardRequest(card: card)

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { _,_,_  -> Void in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    func testEnrollCard_whenEnrollmentEndpointReturnsError_sendsAnalyticsEvent() {
        mockAPIClient.cannedResponseError = NSError(domain: "FakeError", code: 0, userInfo: nil)
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let request = BTCardRequest(card: card)

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { _,_,_  -> Void in
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.enrollment-failed")
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }
    
    func testEnrollCard_onSuccess_invokesCallbackOnMainThread() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "unionPayEnrollmentId": "fake-enrollment-id"
        ])

        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let request = BTCardRequest(card: card)

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { _,_,_  -> Void in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    func testEnrollCard_onSuccess_sendsAnalyticsEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "unionPayEnrollmentId": "fake-enrollment-id",
            "smsCodeRequired": true
        ])
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let request = BTCardRequest(card: card)

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { _,_,_  -> Void in
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.enrollment-succeeded")
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    func testEnrollCard_whenOtherFailure_returnsError() {
        mockAPIClient.cannedResponseError = NSError(domain: "FakeError", code: 1, userInfo: nil)

        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"

        let request = BTCardRequest(card: card)

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.enrollCard(request) { (enrollmentID, smsCodeRequired, error) -> Void in
            XCTAssertNil(enrollmentID)
            XCTAssertFalse(smsCodeRequired)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "FakeError")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    // MARK: - Tokenization
    
    func testTokenization_POSTsToTokenizationEndpoint() {
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest()
        request.card = card
        request.smsCode = "12345"
        // This is an internal-only property, but we want to verify that it gets sent when hitting the tokenization endpoint
        request.enrollmentID = "enrollment-id"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.tokenizeCard(request, options: nil) { (_, _) -> Void in
            expectation.fulfill()
        }
        waitForExpectations(timeout: standardTimeout, handler: nil)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/credit_cards")
        if let parameters = mockAPIClient.lastPOSTParameters as? [String: AnyObject] {
            guard let cardParameters = parameters["credit_card"] as? [String: AnyObject] else {
                XCTFail("Card should be in parameters")
                return
            }
            XCTAssertEqual(cardParameters["number"] as? String, "4111111111111111")
            XCTAssertEqual(cardParameters["expiration_month"] as? String, "12")
            XCTAssertEqual(cardParameters["expiration_year"] as? String, "2038")
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
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest()
        request.card = card
        // This is an internal-only property, but we want to verify that it gets sent when hitting the tokenization endpoint
        request.enrollmentID = "enrollment-id"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.tokenizeCard(request, options: nil) { (_, _) -> Void in
            expectation.fulfill()
        }
        waitForExpectations(timeout: standardTimeout, handler: nil)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/credit_cards")
        if let parameters = mockAPIClient.lastPOSTParameters as? [String: AnyObject] {
            guard let cardParameters = parameters["credit_card"] as? [String: AnyObject] else {
                XCTFail("Card should be in parameters")
                return
            }
            XCTAssertEqual(cardParameters["number"] as? String, "4111111111111111")
            XCTAssertEqual(cardParameters["expiration_month"] as? String, "12")
            XCTAssertEqual(cardParameters["expiration_year"] as? String, "2038")
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
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "creditCards": [
                [
                    "nonce": "fake-nonce",
                    "description": "UnionPay ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "unionpay"]
                ]
            ]
        ])
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest()
        request.smsCode = "12345"
        request.enrollmentID = "enrollment-id"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.tokenizeCard(request, options: nil) { (_, _) -> Void in
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.nonce-received")
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }

    func testTokenization_whenTokenizingUnionPayEnrolledCardFails_sendsAnalyticsEvent() {
        mockAPIClient.cannedResponseError = NSError(domain: "FakeError", code: 0, userInfo: nil)
        let cardClient = BTCardClient(apiClient: mockAPIClient)

        let card = BTCard()
        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        let request = BTCardRequest()
        request.card = card
        request.smsCode = "12345"
        request.enrollmentID = "enrollment-id"

        let expectation = self.expectation(description: "Callback invoked")
        cardClient.tokenizeCard(request, options: nil) { (_, _) -> Void in
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.last!, "ios.custom.unionpay.nonce-failed")
            expectation.fulfill()
        }

        waitForExpectations(timeout: standardTimeout, handler: nil)
    }
}
