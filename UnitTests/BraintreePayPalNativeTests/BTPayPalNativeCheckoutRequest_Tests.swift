import XCTest
@testable import BraintreePayPalNative

class BTPayPalNativeCheckoutRequest_Tests: XCTestCase {

    // MARK: - hermesPath

    func testHermesPath_returnCorrectPath() {
        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        XCTAssertEqual(request.hermesPath, "v1/paypal_hermes/create_payment_resource")
    }
}
