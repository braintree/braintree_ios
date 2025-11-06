import XCTest
import PassKit
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreeApplePay

class BTApplePay_Tests: XCTestCase {
    var mockClient : MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")

    override func setUp() {
        super.setUp()
        mockClient = MockAPIClient(authorization: "development_tokenization_key")
    }

    // MARK: - Payment Request

    func testCanMakeApplePayPayments_ReturnsTrueWhenEnabled() async {
        let applePayClient = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")

        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production",
                "countryCode": "BT",
                "currencyCode": "BTB",
                "merchantIdentifier": "merchant.com.braintree-unit-tests",
                "supportedNetworks": ["visa", "mastercard", "amex"]
            ] as [String: Any]
        ])

        applePayClient.apiClient = mockClient

        let result = await applePayClient.isApplePaySupported()
        XCTAssertTrue(result)
    }

    func testCanMakeApplePayPayments_ReturnsFalseWhenDisabled() async {
        let applePayClient = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "off"
                ]
        ])

        applePayClient.apiClient = mockClient

        let result = await applePayClient.isApplePaySupported()
        XCTAssertFalse(result)
    }

    func testPaymentRequest_whenConfiguredOff_callsBackWithError() {
        let applePayClient = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "off"
            ]
        ])
        
        applePayClient.apiClient = mockClient

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.makePaymentRequest { (paymentRequest, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayError.errorDomain)
            XCTAssertEqual(error.code, BTApplePayError.unsupported.rawValue)
            XCTAssertEqual(error.localizedDescription, BTApplePayError.unsupported.errorDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testPaymentRequest_whenConfigurationIsMissingApplePayStatus_callsBackWithError() {
        let applePayClient = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [AnyHashable: Any?])
        
        applePayClient.apiClient = mockClient

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.makePaymentRequest { (paymentRequest, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayError.errorDomain)
            XCTAssertEqual(error.code, BTApplePayError.unsupported.rawValue)
            XCTAssertEqual(error.localizedDescription, BTApplePayError.unsupported.errorDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testPaymentRequest_returnsPaymentRequestUsingConfiguration() {
        let applePayClient = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production",
                "countryCode": "BT",
                "currencyCode": "BTB",
                "merchantIdentifier": "merchant.com.braintree-unit-tests",
                "supportedNetworks": ["visa", "mastercard", "amex"]
            ] as [String: Any]
        ])
        
        applePayClient.apiClient = mockClient

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.makePaymentRequest { (paymentRequest, error) in
            guard let paymentRequest = paymentRequest else {
                XCTFail()
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(paymentRequest.countryCode, "BT")
            XCTAssertEqual(paymentRequest.currencyCode, "BTB")
            XCTAssertEqual(paymentRequest.merchantIdentifier, "merchant.com.braintree-unit-tests")
            XCTAssertEqual(paymentRequest.supportedNetworks, [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex])
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testPaymentRequest_whenConfigurationIsMissingValues_returnsPaymentRequestWithValuesUndefined() {
        let applePayClient = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        
        applePayClient.apiClient = mockClient

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.makePaymentRequest { (paymentRequest, error) in
            guard let paymentRequest = paymentRequest else {
                XCTFail()
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(paymentRequest.countryCode, "")
            XCTAssertEqual(paymentRequest.currencyCode, "")
            XCTAssertEqual(paymentRequest.merchantIdentifier, "")
            XCTAssertEqual(paymentRequest.supportedNetworks, [])
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    // MARK: - Tokenization

    func testTokenization_whenConfiguredOff_callsBackWithError() {
        let expectation = self.expectation(description: "Unsuccessful tokenization")

        let client = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "off"
            ]
        ])
        
        client.apiClient = mockClient
        
        let payment = MockPKPayment()
        client.tokenize(payment) { (tokenizedPayment, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayError.errorDomain)
            XCTAssertEqual(error.code, BTApplePayError.unsupported.rawValue)
            XCTAssertEqual(error.localizedDescription, BTApplePayError.unsupported.errorDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenConfigurationIsMissingApplePayStatus_callsBackWithError() {
        let expectation = self.expectation(description: "Unsuccessful tokenization")

        let client = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [AnyHashable: Any])
        
        client.apiClient = mockClient
        
        let payment = MockPKPayment()
        client.tokenize(payment) { (tokenizedPayment, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayError.errorDomain)
            XCTAssertEqual(error.code, BTApplePayError.unsupported.rawValue)
            XCTAssertEqual(error.localizedDescription, BTApplePayError.unsupported.errorDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenConfigurationFetchErrorOccurs_callsBackWithError() {
        let client = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        mockClient.cannedConfigurationResponseError = NSError(domain: "MyError", code: 1, userInfo: nil)
        client.apiClient = mockClient
        
        let payment = MockPKPayment()
        let expectation = self.expectation(description: "tokenization error")

        client.tokenize(payment) { (tokenizedPayment, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "MyError")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenTokenizationErrorOccurs_callsBackWithError() {
        let client = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        mockClient.cannedHTTPURLResponse = HTTPURLResponse(url: URL(string: "any")!, statusCode: 503, httpVersion: nil, headerFields: nil)
        mockClient.cannedResponseError = NSError(domain: "foo", code: 100, userInfo: nil)
        
        client.apiClient = mockClient
        
        let payment = MockPKPayment()
        let expectation = self.expectation(description: "tokenization failure")

        client.tokenize(payment) { (tokenizedPayment, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockClient.cannedResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenTokenizationFailureOccurs_callsBackWithError() {
        let client = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        mockClient.cannedResponseError = NSError(domain: "MyError", code: 1, userInfo: nil)
        
        client.apiClient = mockClient
        
        let payment = MockPKPayment()
        let expectation = self.expectation(description: "tokenization failure")

        client.tokenize(payment) { (tokenizedPayment, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "MyError")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenSuccessfulTokenizationInProduction_callsBackWithTokenizedPayment() {
        let expectation = self.expectation(description: "successful tokenization")

        let client = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        mockClient.cannedResponseBody = BTJSON(
            value: [
                "applePayCards": [
                    [
                        "nonce" : "an-apple-pay-nonce",
                        "default": true,
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
                ] as [[String: Any]]
            ]
        )
        
        client.apiClient = mockClient
        let payment = MockPKPayment()
        client.tokenize(payment) { (tokenizedPayment, error) -> Void in
            XCTAssertNil(error)
            XCTAssertEqual(tokenizedPayment!.nonce, "an-apple-pay-nonce")
            XCTAssertTrue(tokenizedPayment!.isDefault)
            XCTAssertEqual(tokenizedPayment!.binData.prepaid, "Yes")
            XCTAssertEqual(tokenizedPayment!.binData.healthcare, "Yes")
            XCTAssertEqual(tokenizedPayment!.binData.debit, "No")
            XCTAssertEqual(tokenizedPayment!.binData.durbinRegulated, "No")
            XCTAssertEqual(tokenizedPayment!.binData.commercial, "Yes")
            XCTAssertEqual(tokenizedPayment!.binData.payroll, "No")
            XCTAssertEqual(tokenizedPayment!.binData.issuingBank, "US")
            XCTAssertEqual(tokenizedPayment!.binData.countryOfIssuance, "Something")
            XCTAssertEqual(tokenizedPayment!.binData.productID, "123")
            expectation.fulfill()
        }

        XCTAssertEqual(mockClient.lastPOSTPath, "v1/payment_methods/apple_payment_tokens")

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenize_whenBodyIsMissingData_returnsError() {
        let applePayClient = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: ["applePay" : ["status" : "production"]])
        mockClient.cannedResponseBody = nil
        
        applePayClient.apiClient = mockClient
        
        let payment = MockPKPayment()
        let expectation = expectation(description: "Callback invoked")

        applePayClient.tokenize(payment) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertNotNil(error)
            guard let error = error as NSError? else { XCTFail("Should return error"); return }
            XCTAssertEqual(error.domain, BTApplePayError.errorDomain)
            XCTAssertEqual(error.code, BTApplePayError.noApplePayCardsReturned.rawValue)
            XCTAssertEqual(error.localizedDescription, BTApplePayError.noApplePayCardsReturned.errorDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testTokenize_bodyDoesNotContainApplePayCards_returnsError() {
        let applePayClient = BTApplePayClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")

        mockClient.cannedConfigurationResponseBody = BTJSON(value: ["applePay" : ["status" : "production"]])
        mockClient.cannedResponseBody = BTJSON(value: ["notApplePayCards": "badData"])

        applePayClient.apiClient = mockClient

        let payment = MockPKPayment()
        let expectation = expectation(description: "Callback invoked")

        applePayClient.tokenize(payment) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertNotNil(error)
            guard let error = error as NSError? else { XCTFail("Should return error"); return }
            XCTAssertEqual(error.domain, BTApplePayError.errorDomain)
            XCTAssertEqual(error.code, BTApplePayError.failedToCreateNonce.rawValue)
            XCTAssertEqual(error.localizedDescription, BTApplePayError.failedToCreateNonce.errorDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Metadata

    func testMetaParameter_whenTokenizationIsSuccessful_isPOSTedToServer() {
        let applePayClient = BTApplePayClient(authorization: "production_t2wns2y2_dfy45jdj3dxkmz5m")
                
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        
        applePayClient.apiClient = mockAPIClient
                
        let payment = MockPKPayment()

        let expectation = self.expectation(description: "Tokenized card")
        applePayClient.tokenize(payment) { _,_  -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/apple_payment_tokens")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        
        let applePayTokenParams = lastPostParameters["applePaymentToken"] as! NSDictionary
        XCTAssertEqual(applePayTokenParams["paymentData"] as? String, Data().base64EncodedString())
        XCTAssertEqual(applePayTokenParams["transactionIdentifier"] as? String, "fake-transaction-id")
        // The following are expected nil in tests since we cannot mock `PKPaymentToken.paymentMethod`
        XCTAssertNil(applePayTokenParams["paymentInstrumentName"])
        XCTAssertNil(applePayTokenParams["paymentNetwork"])
    }

    class MockPKPaymentToken : PKPaymentToken {
        override var paymentData : Data {
            get {
                return Data()
            }
        }
        override var transactionIdentifier : String {
            get {
                return "fake-transaction-id"
            }
        }
    }

    class MockPKPayment : PKPayment {
        var overrideToken = MockPKPaymentToken()
        override var token : PKPaymentToken {
            get {
                return overrideToken
            }
        }
    }
}
