import XCTest
import PassKit
import BraintreeTestShared

class BTApplePay_Tests: XCTestCase {
    var mockClient : MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!

    override func setUp() {
        super.setUp()
        mockClient = MockAPIClient(authorization: "development_tokenization_key")!
    }

    // MARK: - Payment Request

    func testPaymentRequest_whenConfiguredOff_callsBackWithError() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "off"
            ]
        ])
        let applePayClient = BTApplePayClient(apiClient: mockClient)

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.paymentRequest { (paymentRequest, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayErrorDomain)
            XCTAssertEqual(error.code, BTApplePayErrorType.unsupported.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testPaymentRequest_whenConfigurationIsMissingApplePayStatus_callsBackWithError() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let applePayClient = BTApplePayClient(apiClient: mockClient)

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.paymentRequest { (paymentRequest, error) in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayErrorDomain)
            XCTAssertEqual(error.code, BTApplePayErrorType.unsupported.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testPaymentRequest_whenAPIClientIsNil_callsBackWithError() {
        let applePayClient = BTApplePayClient(apiClient: mockClient)
        applePayClient.apiClient = nil

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.paymentRequest { (paymentRequest, error) in
            XCTAssertNil(paymentRequest)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayErrorDomain)
            XCTAssertEqual(error.code, BTApplePayErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testPaymentRequest_returnsPaymentRequestUsingConfiguration() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production",
                "countryCode": "BT",
                "currencyCode": "BTB",
                "merchantIdentifier": "merchant.com.braintree-unit-tests",
                "supportedNetworks": ["visa", "mastercard", "amex"]
            ]
        ])
        let applePayClient = BTApplePayClient(apiClient: mockClient)

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.paymentRequest { (paymentRequest, error) in
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
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        let applePayClient = BTApplePayClient(apiClient: mockClient)

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.paymentRequest { (paymentRequest, error) in
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
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "off"
            ]
        ])
        let expectation = self.expectation(description: "Unsuccessful tokenization")

        let client = BTApplePayClient(apiClient: mockClient)
        let payment = MockPKPayment()
        client.tokenizeApplePay(payment) { (tokenizedPayment, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayErrorDomain)
            XCTAssertEqual(error.code, BTApplePayErrorType.unsupported.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenConfigurationIsMissingApplePayStatus_callsBackWithError() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let expectation = self.expectation(description: "Unsuccessful tokenization")

        let client = BTApplePayClient(apiClient: mockClient)
        let payment = MockPKPayment()
        client.tokenizeApplePay(payment) { (tokenizedPayment, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayErrorDomain)
            XCTAssertEqual(error.code, BTApplePayErrorType.unsupported.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenAPIClientIsNil_callsBackWithError() {
        let client = BTApplePayClient(apiClient: mockClient)
        client.apiClient = nil

        let expectation = self.expectation(description: "Callback invoked")
        client.tokenizeApplePay(MockPKPayment()) { (tokenizedPayment, error) -> Void in
            XCTAssertNil(tokenizedPayment)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTApplePayErrorDomain)
            XCTAssertEqual(error.code, BTApplePayErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenConfigurationFetchErrorOccurs_callsBackWithError() {
        mockClient.cannedConfigurationResponseError = NSError(domain: "MyError", code: 1, userInfo: nil)
        let client = BTApplePayClient(apiClient: mockClient)
        let payment = MockPKPayment()
        let expectation = self.expectation(description: "tokenization error")

        client.tokenizeApplePay(payment) { (tokenizedPayment, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "MyError")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenTokenizationErrorOccurs_callsBackWithError() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        mockClient.cannedHTTPURLResponse = HTTPURLResponse(url: URL(string: "any")!, statusCode: 503, httpVersion: nil, headerFields: nil)
        mockClient.cannedResponseError = NSError(domain: "foo", code: 100, userInfo: nil)
        let client = BTApplePayClient(apiClient: mockClient)
        let payment = MockPKPayment()
        let expectation = self.expectation(description: "tokenization failure")

        client.tokenizeApplePay(payment) { (tokenizedPayment, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockClient.cannedResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenTokenizationFailureOccurs_callsBackWithError() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        mockClient.cannedResponseError = NSError(domain: "MyError", code: 1, userInfo: nil)
        let client = BTApplePayClient(apiClient: mockClient)
        let payment = MockPKPayment()
        let expectation = self.expectation(description: "tokenization failure")

        client.tokenizeApplePay(payment) { (tokenizedPayment, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "MyError")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenization_whenSuccessfulTokenizationInProduction_callsBackWithTokenizedPayment() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        mockClient.cannedResponseBody = BTJSON(value: [
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
            ]
        ])
        let expectation = self.expectation(description: "successful tokenization")

        let client = BTApplePayClient(apiClient: mockClient)
        let payment = MockPKPayment()
        client.tokenizeApplePay(payment) { (tokenizedPayment, error) -> Void in
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
    
    func testTokenizeApplePay_whenNetworkConnectionLost_sendsAnalytics() {
        mockClient.cannedResponseError = NSError(domain: NSURLErrorDomain, code: -1005, userInfo: [NSLocalizedDescriptionKey: "The network connection was lost."])
        
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        
        let applePayClient = BTApplePayClient(apiClient: mockClient)
        let payment = MockPKPayment()

        let expectation = self.expectation(description: "Callback invoked")
        applePayClient.tokenizeApplePay(payment) { nonce, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
        
        XCTAssertTrue(mockClient.postedAnalyticsEvents.contains("ios.apple-pay.network-connection.failure"))
    }

    // MARK: - Metadata

    func testMetaParameter_whenTokenizationIsSuccessful_isPOSTedToServer() {
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        let applePayClient = BTApplePayClient(apiClient: mockAPIClient)
        let payment = MockPKPayment()

        let expectation = self.expectation(description: "Tokenized card")
        applePayClient.tokenizeApplePay(payment) { _,_  -> Void in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/apple_payment_tokens")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let metaParameters = lastPostParameters["_meta"] as! NSDictionary
        XCTAssertEqual(metaParameters["source"] as? String, "unknown")
        XCTAssertEqual(metaParameters["integration"] as? String, "custom")
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionID)
    }

    class MockPKPaymentToken : PKPaymentToken {
        override var paymentData : Data {
            get {
                return Data()
            }
        }
        override var transactionIdentifier : String {
            get {
                return "transaction-id"
            }
        }
        override var paymentInstrumentName : String {
            get {
                return "payment-instrument-name"
            }
        }
        override var paymentNetwork : String {
            get {
                return "payment-network"
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
