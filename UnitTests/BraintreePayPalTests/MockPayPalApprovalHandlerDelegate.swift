import XCTest

class MockPayPalApprovalHandlerDelegate: NSObject, BTPayPalApprovalHandler {
    var handleApprovalExpectation: XCTestExpectation?
    var url: URL?
    var cancel = false

    func handleApproval(_ request: BTPayPalApprovalRequest, paypalApprovalDelegate delegate: BTPayPalApprovalDelegate) {
        if (cancel) {
            delegate.onApprovalCancel()
        } else {
            delegate.onApprovalComplete(url!) // TODO - maybe don't force-unwrap this?
        }
        handleApprovalExpectation?.fulfill()
    }
}
