import XCTest
import BraintreeCore
import BraintreePayPal
import BraintreeTestShared

@testable import BraintreePayPalNative

class BTPayPalNativeClient_Tests: XCTestCase {

    private var mockAPIClient: MockAPIClient!
    private var payPalNativeClient: BTPayPalNativeClient!

    override func setUp() {
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "environment": "sandbox",
            "paypalEnabled": true,
            "paypal": [
                "clientId": "some-client-id"
            ]
        ])

        payPalNativeClient = BTPayPalNativeClient(apiClient: mockAPIClient)
    }

    // MARK: - tokenizePayPalAccount

    func testTokenize_whenRequestIsNotCheckoutOrVaultSubclass_returnsError() {
        let expectation = self.expectation(description: "calls completion with invalid request error")

        payPalNativeClient.tokenizePayPalAccount(with: BTPayPalRequest()) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.domain, "BraintreePayPalNative.BTPayPalNativeError")
            XCTAssertEqual(error?.code, BTPayPalNativeError.invalidRequest.rawValue)
            XCTAssertEqual(error?.localizedDescription, "Request is not of type BTPayPalNativeCheckoutRequest or BTPayPalNativeVaultRequest.")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenOrderCreationClientReturnsError_returnsError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let expectation = self.expectation(description: "calls completion with order creation error")
        let request = BTPayPalNativeVaultRequest(payPalReturnURL: "some-return-url")

        payPalNativeClient.tokenizePayPalAccount(with: request) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.domain, "BraintreePayPalNative.BTPayPalNativeError")
            XCTAssertEqual(error?.code, BTPayPalNativeError.fetchConfigurationFailed.rawValue)
            XCTAssertEqual(error?.localizedDescription, "Failed to fetch Braintree configuration.")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
