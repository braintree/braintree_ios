import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalEditRequest_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_returnsAllParams() {
        let expectedEditPayPalVaultID = "fake-edit-paypal-vault-id"
        let editRequest = BTPayPalVaultEditRequest(editPayPalVaultID: expectedEditPayPalVaultID)

        // TODO: implement checking expected params returned
    }
}
