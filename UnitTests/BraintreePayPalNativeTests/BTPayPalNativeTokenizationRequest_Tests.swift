import XCTest
import BraintreeCore

@testable import BraintreePayPalNative

class BTPayPalNativeTokenizationRequest_Tests: XCTestCase {

    class MockClientMetadata: BTClientMetadata {
        override var sessionID: String {
            "mock-session-id"
        }
    }

    func testParameters_whenUsingCheckoutRequest_containsAllValues() {
        let expected: [String : Any] = [
            "_meta": [
                "source": "unknown",
                "integration": "custom",
                "sessionId": "mock-session-id",
            ],
            "paypal_account": [
                "client": [
                    "platform": "iOS",
                    "product_name": "PayPal",
                    "paypal_sdk_version": "version"
                ],
                "response_type": "web",
                "response": [
                    "webURL": "some-url"
                ],
                "options": [
                    "validate": false
                ],
                "intent": "order",
                "correlation_id": "some-correlation-id",
            ]
        ]

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "return-url", amount: "5")
        request.intent = .order
        let clientMetadata = MockClientMetadata()
        let tokenizationRequest = BTPayPalNativeTokenizationRequest(returnURL: "some-url",
                                                                    request: request,
                                                                    correlationID: "some-correlation-id",
                                                                    clientMetadata: clientMetadata)

        XCTAssertEqual(tokenizationRequest.parameters() as NSDictionary, expected as NSDictionary)
    }

    func testParameters_whenUsingVaultRequest_containsAllValues() {
        let expected: [String : Any] = [
            "_meta": [
                "source": "unknown",
                "integration": "custom",
                "sessionId": "mock-session-id",
            ],
            "paypal_account": [
                "client": [
                    "platform": "iOS",
                    "product_name": "PayPal",
                    "paypal_sdk_version": "version"
                ],
                "response_type": "web",
                "response": [
                    "webURL": "some-url"
                ],
                "correlation_id": "some-correlation-id"
            ]
        ]

        let request = BTPayPalNativeVaultRequest(payPalReturnURL: "return-url")
        let clientMetadata = MockClientMetadata()
        let tokenizationRequest = BTPayPalNativeTokenizationRequest(returnURL: "some-url",
                                                                    request: request,
                                                                    correlationID: "some-correlation-id",
                                                                    clientMetadata: clientMetadata)

        XCTAssertEqual(tokenizationRequest.parameters() as NSDictionary, expected as NSDictionary)
    }
}
