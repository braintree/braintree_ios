import XCTest
import BraintreeCore
import BraintreeTestShared
import PayPalCheckout

@testable import BraintreePayPalNative

class BTPayPalNativeTokenizationClient_Tests: XCTestCase {

    private var mockAPIClient: MockAPIClient!
    private var tokenizationClient: BTPayPalNativeTokenizationClient!
    private var request: BTPayPalNativeCheckoutRequest!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        tokenizationClient = BTPayPalNativeTokenizationClient(apiClient: mockAPIClient)
        request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "com.something", amount: "10")
    }

    func testTokenize_sendsRequestToGateway() {
        let expectation = self.expectation(description: "sends request to gateway")

        let expectedTokenizationRequest = BTPayPalNativeTokenizationRequest(returnURL: "www.return-url.com",
                                                                            request: request,
                                                                            correlationID: "",
                                                                            clientMetadata: mockAPIClient.metadata)

        tokenizationClient.tokenize(returnURL: "www.return-url.com", request: request) { [weak self] _ in
            XCTAssertEqual(self?.mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
            XCTAssertEqual(self?.mockAPIClient.lastPOSTParameters as NSDictionary?,
                           expectedTokenizationRequest.parameters() as NSDictionary)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenTokenizationFails_callsCompletionWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "some-domain", code: 8, userInfo: nil)

        let expectation = self.expectation(description: "calls completion with tokenization error")

        tokenizationClient.tokenize(returnURL: "www.return-url.com", request: request) { result in
            XCTAssertEqual(result, .failure(.tokenizationFailed))

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenParsingTokenizationResultFails_callsCompletionWithError() {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["something": "unexpected"])

        let expectation = self.expectation(description: "calls completion with parsing error")

        tokenizationClient.tokenize(returnURL: "www.return-url.com", request: request) { result in
            XCTAssertEqual(result, .failure(.parsingTokenizationResultFailed))

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenTokenizationSucceeds_callsCompletionWithNonce() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paypalAccounts": [
                [
                    "nonce": "some-nonce"
                ]
            ]
        ])

        let expectation = self.expectation(description: "calls completion with nonce")

        tokenizationClient.tokenize(returnURL: "www.return-url.com", request: request) { result in
            guard let payPalAccountNonce = try? result.get() else {
                XCTFail()
                return
            }

            XCTAssertEqual(payPalAccountNonce.nonce, "some-nonce")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
