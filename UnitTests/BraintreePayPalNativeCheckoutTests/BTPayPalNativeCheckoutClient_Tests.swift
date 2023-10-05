import XCTest
@testable import BraintreeTestShared
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalNativeCheckoutClient_Tests: XCTestCase {
    var apiClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient(authorization: "development_client_key")
    }

    func testInvalidConfiguration_ReturnsCorrectError() {
        let environment = "sandbox"
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": environment,
            "paypal": ["clientId": nil] as [String: Any?]
        ] as [String: Any])

        let nativeCheckoutRequest = BTPayPalNativeCheckoutRequest(amount: "4.30")
        let checkoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
        checkoutClient.tokenize(nativeCheckoutRequest) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertEqual(error as? BTPayPalNativeCheckoutError, .payPalClientIDNotFound)
            XCTAssertEqual(self.apiClient.postedAnalyticsEvents.last, BTPayPalNativeCheckoutAnalytics.tokenizeFailed)
        }
    }
    
    // TODO: - Add remaining unit tests DTBTSDK-3076
}
