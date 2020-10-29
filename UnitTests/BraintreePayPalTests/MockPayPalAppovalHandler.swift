import XCTest

class MockPayPalApprovalHandler: BTPayPalApprovalHandler {

    let expectation: XCTestExpectation
    var request: BTPayPalApprovalRequest?

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func handleApproval(_ request: BTPayPalApprovalRequest, paypalApprovalDelegate delegate: BTPayPalApprovalDelegate) {
        self.request = request
        self.expectation.fulfill()
    }
}
