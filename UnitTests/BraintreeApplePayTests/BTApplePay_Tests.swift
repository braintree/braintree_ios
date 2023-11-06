import XCTest
import PassKit
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreeApplePay

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
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [AnyHashable: Any?])
        let applePayClient = BTApplePayClient(apiClient: mockClient)

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
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production",
                "countryCode": "BT",
                "currencyCode": "BTB",
                "merchantIdentifier": "merchant.com.braintree-unit-tests",
                "supportedNetworks": ["visa", "mastercard", "amex"]
            ] as [String: Any]
        ])
        let applePayClient = BTApplePayClient(apiClient: mockClient)

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
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        let applePayClient = BTApplePayClient(apiClient: mockClient)

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
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "off"
            ]
        ])
        let expectation = self.expectation(description: "Unsuccessful tokenization")

        let client = BTApplePayClient(apiClient: mockClient)
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
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [AnyHashable: Any])
        let expectation = self.expectation(description: "Unsuccessful tokenization")

        let client = BTApplePayClient(apiClient: mockClient)
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
        mockClient.cannedConfigurationResponseError = NSError(domain: "MyError", code: 1, userInfo: nil)
        let client = BTApplePayClient(apiClient: mockClient)
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

        client.tokenize(payment) { (tokenizedPayment, error) -> Void in
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

        client.tokenize(payment) { (tokenizedPayment, error) -> Void in
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
        let expectation = self.expectation(description: "successful tokenization")

        let client = BTApplePayClient(apiClient: mockClient)
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
        mockClient.cannedConfigurationResponseBody = BTJSON(value: ["applePay" : ["status" : "production"]])
        mockClient.cannedResponseBody = nil

        let applePayClient = BTApplePayClient(apiClient: mockClient)
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
        mockClient.cannedConfigurationResponseBody = BTJSON(value: ["applePay" : ["status" : "production"]])
        mockClient.cannedResponseBody = BTJSON(value: ["notApplePayCards": "badData"])

        let applePayClient = BTApplePayClient(apiClient: mockClient)
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
        let mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        let applePayClient = BTApplePayClient(apiClient: mockAPIClient)
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
