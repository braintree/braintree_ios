import XCTest
@testable import BraintreeTestShared

class BTThreeDSecureRequest_Tests: XCTestCase {

    // MARK: - accountTypeAsString

    func testAccountTypeAsString_whenAccountTypeIsCredit_returnsCredit() {
        let request = BTThreeDSecureRequest()
        request.accountType = .credit
        XCTAssertEqual(request.accountTypeAsString, "credit")
    }

    func testAccountTypeAsString_whenAccountTypeIsDebit_returnsDebit() {
        let request = BTThreeDSecureRequest()
        request.accountType = .debit
        XCTAssertEqual(request.accountTypeAsString, "debit")
    }

    func testAccountTypeAsString_whenAccountTypeIsUnspecified_returnsNil() {
        let request = BTThreeDSecureRequest()
        request.accountType = .unspecified
        XCTAssertEqual(request.accountTypeAsString, nil)
    }

    func testAccountTypeAsString_whenAccountTypeIsNotSet_returnsNil() {
        let request = BTThreeDSecureRequest()
        XCTAssertEqual(request.accountTypeAsString, nil)
    }

    // MARK: - shippingMethodAsString

    func testShippingMethodAsString_whenShippingMethodIsSameDay_returns01() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .sameDay
        XCTAssertEqual(request.shippingMethodAsString, "01")
    }

    func testShippingMethodAsString_whenShippingMethodIsExpedited_returns02() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .expedited
        XCTAssertEqual(request.shippingMethodAsString, "02")
    }

    func testShippingMethodAsString_whenShippingMethodIsPriority_returns03() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .priority
        XCTAssertEqual(request.shippingMethodAsString, "03")
    }

    func testShippingMethodAsString_whenShippingMethodIsGround_returns04() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .ground
        XCTAssertEqual(request.shippingMethodAsString, "04")
    }

    func testShippingMethodAsString_whenShippingMethodIsElectronicDelivery_returns05() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .electronicDelivery
        XCTAssertEqual(request.shippingMethodAsString, "05")
    }

    func testShippingMethodAsString_whenShippingMethodIsShipToStore_returns06() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .shipToStore
        XCTAssertEqual(request.shippingMethodAsString, "06")
    }

    func testShippingMethodAsString_whenShippingMethodIsUnspecified_returnsNil() {
        let request = BTThreeDSecureRequest()
        request.shippingMethod = .unspecified
        XCTAssertEqual(request.shippingMethodAsString, nil)
    }

    func testShippingMethodAsString_whenShippingMethodIsNotSet_returnsNil() {
        let request = BTThreeDSecureRequest()
        XCTAssertEqual(request.shippingMethodAsString, nil)
    }

    // MARK: - requestedExemptionTypeAsString

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsLowValue_returnsLowValue() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .lowValue
        XCTAssertEqual(request.requestedExemptionTypeAsString, "low_value")
    }

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsSecureCorporate_returnsSecureCorporate() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .secureCorporate
        XCTAssertEqual(request.requestedExemptionTypeAsString, "secure_corporate")
    }

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsTrustedBeneficiary_returnsTrustedBeneficiary() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .trustedBeneficiary
        XCTAssertEqual(request.requestedExemptionTypeAsString, "trusted_beneficiary")
    }

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsTransactionRiskAnalysis_returnsTransactionRiskAnalysis() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .transactionRiskAnalysis
        XCTAssertEqual(request.requestedExemptionTypeAsString, "transaction_risk_analysis")
    }

    func testRequestedExemptionTypeAsString_whenAccountTypeIsUnspecified_returnsNil() {
        let request = BTThreeDSecureRequest()
        request.requestedExemptionType = .unspecified
        XCTAssertEqual(request.requestedExemptionTypeAsString, nil)
    }

    func testRequestedExemptionTypeAsString_whenAccountTypeIsNotSet_returnsNil() {
        let request = BTThreeDSecureRequest()
        XCTAssertEqual(request.requestedExemptionTypeAsString, nil)
    }

    // MARK: - handleRequest
    
    func testHandleRequest_whenAmountIsNotANumber_throwsError() {
        let request =  BTThreeDSecureRequest()
        request.amount = NSDecimalNumber.notANumber

        let mockThreeDSecureRequestDelegate = MockThreeDSecureRequestDelegate()
        request.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        
        let mockAPIClient = MockAPIClient(authorization: "development_client_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [])
        
        let mockPaymentFlowClientDelegate = MockPaymentFlowClientDelegate()
        let expectation = self.expectation(description: "Calls onPaymentWithURL with result")
        
        mockPaymentFlowClientDelegate.onPaymentCompleteHandler = { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(error?.localizedDescription, "BTThreeDSecureRequest amount can not be nil or NaN.")
            expectation.fulfill()
        }
        request.paymentFlowClientDelegate = mockPaymentFlowClientDelegate
        
        request.handle(request, client: mockAPIClient, paymentClientDelegate: mockPaymentFlowClientDelegate)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // MARK: - handleOpenURL
    
    func testHandleOpenURL_whenAuthenticationSucceeds_returnsResult() {
        let url = URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%7B%22paymentMethod%22:%7B%22type%22:%22CreditCard%22,%22nonce%22:%22c193533b-5b79-0ff7-7405-6c1088979414%22,%22description%22:%22ending+in+02%22,%22consumed%22:false,%22threeDSecureInfo%22:%7B%22enrolled%22:%22Y%22,%22liabilityShifted%22:true,%22liabilityShiftPossible%22:true,%22status%22:%22authenticate_successful%22%7D,%22details%22:%7B%22bin%22:%22400000%22,%22lastTwo%22:%2202%22,%22lastFour%22:%220002%22,%22cardType%22:%22Visa%22,%22expirationYear%22:%2220%22,%22expirationMonth%22:%2201%22%7D,%22binData%22:%7B%22prepaid%22:%22Unknown%22,%22healthcare%22:%22Unknown%22,%22debit%22:%22Unknown%22,%22durbinRegulated%22:%22Unknown%22,%22commercial%22:%22Unknown%22,%22payroll%22:%22Unknown%22,%22issuingBank%22:%22Unknown%22,%22countryOfIssuance%22:%22Unknown%22,%22productId%22:%22Unknown%22%7D%7D,%22threeDSecureInfo%22:%7B%22liabilityShifted%22:true,%22liabilityShiftPossible%22:true%7D,%22success%22:true%7D")!
        
        let expectation = self.expectation(description: "Calls onPaymentComplete with result")
        let mockPaymentFlowClientDelegate = MockPaymentFlowClientDelegate()
        
        mockPaymentFlowClientDelegate.onPaymentCompleteHandler = { result, error in
            guard let threeDSecureResult = result as? BTThreeDSecureResult else { XCTFail(); return }
            guard let tokenizedCard = threeDSecureResult.tokenizedCard else { XCTFail(); return }

            XCTAssertTrue(tokenizedCard.threeDSecureInfo.liabilityShiftPossible)
            XCTAssertTrue(tokenizedCard.threeDSecureInfo.liabilityShifted)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        let request = BTThreeDSecureRequest()
        request.paymentFlowClientDelegate = mockPaymentFlowClientDelegate
        
        request.handleOpen(url)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testHandleOpenURL_whenAuthenticationFailed_andVersion2Requested_returnsError() {
        let url = URL(string: "com.braintreepayments.demo.payments://x-callback-url/braintree/threedsecure?auth_response=%7B%22threeDSecureInfo%22:%7B%22liabilityShifted%22:false,%22liabilityShiftPossible%22:true%7D,%22error%22:%7B%22message%22:%22Failed+to+authenticate,+please+try+a+different+form+of+payment.%22%7D,%22success%22:false%7D")!
        
        let expectation = self.expectation(description: "Calls onPaymentComplete with error")
        let mockPaymentFlowClientDelegate = MockPaymentFlowClientDelegate()
        
        mockPaymentFlowClientDelegate.onPaymentCompleteHandler = { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(error?.localizedDescription, "Failed to authenticate, please try a different form of payment.")
            expectation.fulfill()
        }
        
        let request = BTThreeDSecureRequest()
        request.paymentFlowClientDelegate = mockPaymentFlowClientDelegate
        
        request.handleOpen(url)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
