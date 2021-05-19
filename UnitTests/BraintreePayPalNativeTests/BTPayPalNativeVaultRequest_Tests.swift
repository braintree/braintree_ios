import XCTest
@testable import BraintreePayPalNative

class BTPayPalNativeVaultRequest_Tests: XCTestCase {

    // MARK: - hermesPath

    func testHermesPath_returnCorrectPath() {
        let request = BTPayPalNativeVaultRequest(payPalReturnURL: "returnURL")
        XCTAssertEqual(request.hermesPath, "v1/paypal_hermes/setup_billing_agreement")
    }
}
