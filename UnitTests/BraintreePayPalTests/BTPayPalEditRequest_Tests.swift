import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalEditRequest_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_returnsAllParams() {
        let expectedEncryptedBillingAgreementID = "test-encryped-billing-agreement-id"
        let editRequest = BTPayPalVaultEditRequest(encryptedBillingAgreementID: expectedEncryptedBillingAgreementID)

        // TODO: implement checking expected params returned
    }
}
