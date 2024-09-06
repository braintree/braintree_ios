import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalVaultErrorHandlingEditRequest_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_returnsAllParams() {
        let expectedEditPayPalVaultID = "fake-edit-paypal-vault-id"
        let expectedRiskCorrelationID = "test-errorHandling-1"
        let editRequest = BTPayPalVaultErrorHandlingEditRequest(editPayPalVaultID: expectedEditPayPalVaultID, riskCorrelationID: expectedRiskCorrelationID)

        let parameters = editRequest.parameters()

        XCTAssertEqual(parameters["edit_paypal_vault_id"] as? String, expectedEditPayPalVaultID)
        XCTAssertEqual(parameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(parameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
        XCTAssertEqual(parameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
        XCTAssertEqual(parameters["risk_correlation_id"] as? String, expectedRiskCorrelationID)
    }
}
