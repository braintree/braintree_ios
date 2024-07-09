import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalEditRequest_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testBTPayPalEditRequestInitializer() {
        let expectedToken = "test-token"
        let editRequest = BTPayPalEditRequest(token: expectedToken)
        XCTAssertEqual(editRequest.token, expectedToken)
    }
}
