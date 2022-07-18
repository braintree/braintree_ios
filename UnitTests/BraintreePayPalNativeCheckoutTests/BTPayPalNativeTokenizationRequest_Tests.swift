import XCTest
@testable import BraintreePayPalNativeCheckout

class BTPayPalNativeTokenizationRequest_Tests: XCTestCase {

    func testTokenizationRequestParameters() throws {
        let correlationId = "12345"
        let checkoutRequest = BTPayPalNativeCheckoutRequest(amount: "10.00")
        checkoutRequest.intent = .order

        let request = BTPayPalNativeTokenizationRequest(
            request: checkoutRequest,
            correlationID: correlationId
        )

        let account = try XCTUnwrap(request.parameters(returnURL: "a-fake-return-url")["paypal_account"] as? [String: Any])

        let client = account["client"] as? [String: String]
        let response = account["response"] as? [String: String]

        XCTAssertEqual(client?["platform"], "iOS")
        XCTAssertEqual(client?["product_name"], "PayPal")
        XCTAssertEqual(client?["paypal_sdk_version"], "version")
        XCTAssertEqual(account["response_type"] as? String, "web")
        XCTAssertEqual(account["correlation_id"] as? String, correlationId)
        XCTAssertEqual(account["options"] as? [String: Bool], ["validate": false])
        XCTAssertEqual(account["intent"] as? String, checkoutRequest.intentAsString)
        XCTAssertEqual(response?["webURL"], "a-fake-return-url")
    }
}
