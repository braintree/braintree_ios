import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalEditRequest_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_returnsAllParams() {
        let expectedToken = "test-token"
        let editRequest = BTPayPalEditRequest(token: expectedToken)

        // TODO: implement checking expected params returned
    }
}
