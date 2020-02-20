import XCTest

class BTThreeDSecureRequest_Tests: XCTestCase {
    
    // MARK: - handleRequest
    
    func testHandleRequest_whenAmountIsNotANumber_throwsError() {
        let request =  BTThreeDSecureRequest()
        request.amount = NSDecimalNumber.notANumber
        
        let mockAPIClient = MockAPIClient(authorization: "development_client_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [])
        
        let mockPaymentFlowDriverDelegate = MockPaymentFlowDriverDelegate()
        let expectation = self.expectation(description: "Calls onPaymentWithURL with result")
        
        mockPaymentFlowDriverDelegate.onPaymentCompleteHandler = { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(error?.localizedDescription, "BTThreeDSecureRequest amount can not be nil or NaN.")
            expectation.fulfill()
        }
        request.paymentFlowDriverDelegate = mockPaymentFlowDriverDelegate
        
        request.handle(request, client: mockAPIClient, paymentDriverDelegate: mockPaymentFlowDriverDelegate)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // MARK: - processLookupResult
    
    func testProcessLookupResult_when3DSv1_constructsRedirectUrl() {

        let request = BTThreeDSecureRequest()
        request.versionRequested = .version1
        
        let lookupResult = BTThreeDSecureLookup()
        lookupResult.acsURL = URL(string: "https://acs.com")!
        lookupResult.threeDSecureVersion = "1.0"
        lookupResult.paReq = "pa.req"
        lookupResult.md = "m d"
        lookupResult.termURL = URL(string: "https://terms.com")!
        
        let configuration = BTConfiguration(json: BTJSON(value: ["assetsUrl": "https://assets.com"]))
        
        let mockPaymentFlowDriverDelegate = MockPaymentFlowDriverDelegate()
        mockPaymentFlowDriverDelegate._returnURLScheme = "com.braintreepayments.Demo.payments"
        
        let expectation = self.expectation(description: "Calls onPaymentWithURL with result")
        mockPaymentFlowDriverDelegate.onPaymentWithURLHandler = { url, error in
            XCTAssertNotNil(url)
            expectation.fulfill()
        }
        request.paymentFlowDriverDelegate = mockPaymentFlowDriverDelegate
        
        request.processLookupResult(lookupResult, configuration: configuration)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // MARK: - handleOpenURL
    
    func testHandleOpenURL_whenAuthenticationSucceeds_returnsResult() {
        let url = URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%7B%22paymentMethod%22:%7B%22type%22:%22CreditCard%22,%22nonce%22:%22c193533b-5b79-0ff7-7405-6c1088979414%22,%22description%22:%22ending+in+02%22,%22consumed%22:false,%22threeDSecureInfo%22:%7B%22enrolled%22:%22Y%22,%22liabilityShifted%22:true,%22liabilityShiftPossible%22:true,%22status%22:%22authenticate_successful%22%7D,%22details%22:%7B%22bin%22:%22400000%22,%22lastTwo%22:%2202%22,%22lastFour%22:%220002%22,%22cardType%22:%22Visa%22,%22expirationYear%22:%2220%22,%22expirationMonth%22:%2201%22%7D,%22binData%22:%7B%22prepaid%22:%22Unknown%22,%22healthcare%22:%22Unknown%22,%22debit%22:%22Unknown%22,%22durbinRegulated%22:%22Unknown%22,%22commercial%22:%22Unknown%22,%22payroll%22:%22Unknown%22,%22issuingBank%22:%22Unknown%22,%22countryOfIssuance%22:%22Unknown%22,%22productId%22:%22Unknown%22%7D%7D,%22threeDSecureInfo%22:%7B%22liabilityShifted%22:true,%22liabilityShiftPossible%22:true%7D,%22success%22:true%7D")!
        
        let expectation = self.expectation(description: "Calls onPaymentComplete with result")
        let mockPaymentFlowDriverDelegate = MockPaymentFlowDriverDelegate()
        
        mockPaymentFlowDriverDelegate.onPaymentCompleteHandler = { result, error in
            guard let threeDSecureResult = result as? BTThreeDSecureResult else {
                XCTFail()
                return
            }
            
            XCTAssertTrue(threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShiftPossible)
            XCTAssertTrue(threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShifted)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        let request = BTThreeDSecureRequest()
        request.versionRequested = .version2
        request.paymentFlowDriverDelegate = mockPaymentFlowDriverDelegate
        
        request.handleOpen(url)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testHandleOpenURL_whenAuthenticationFailed_andVersion1Requested_returnsError() {
        let url = URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%7B%22threeDSecureInfo%22:%7B%22liabilityShifted%22:false,%22liabilityShiftPossible%22:true%7D,%22error%22:%7B%22message%22:%22Failed+to+authenticate,+please+try+a+different+form+of+payment.%22%7D,%22success%22:false%7D")!
        
        let expectation = self.expectation(description: "Calls onPaymentComplete with error")
        let mockPaymentFlowDriverDelegate = MockPaymentFlowDriverDelegate()
        
        mockPaymentFlowDriverDelegate.onPaymentCompleteHandler = { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(error?.localizedDescription, "Failed to authenticate, please try a different form of payment.")
            expectation.fulfill()
        }
        
        let request = BTThreeDSecureRequest()
        request.versionRequested = .version1
        request.paymentFlowDriverDelegate = mockPaymentFlowDriverDelegate
        
        request.handleOpen(url)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testHandleOpenURL_whenAuthenticationFailed_andVersion2Requested_returnsError() {
        let url = URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%7B%22threeDSecureInfo%22:%7B%22liabilityShifted%22:false,%22liabilityShiftPossible%22:true%7D,%22error%22:%7B%22message%22:%22Failed+to+authenticate,+please+try+a+different+form+of+payment.%22%7D,%22success%22:false%7D")!
        
        let expectation = self.expectation(description: "Calls onPaymentComplete with error")
        let mockPaymentFlowDriverDelegate = MockPaymentFlowDriverDelegate()
        
        mockPaymentFlowDriverDelegate.onPaymentCompleteHandler = { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(error?.localizedDescription, "Failed to authenticate, please try a different form of payment.")
            expectation.fulfill()
        }
        
        let request = BTThreeDSecureRequest()
        request.versionRequested = .version2
        request.paymentFlowDriverDelegate = mockPaymentFlowDriverDelegate
        
        request.handleOpen(url)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
