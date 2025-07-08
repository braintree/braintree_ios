import XCTest
import BraintreeCore

class BTWebAuthenticationSession_Tests: XCTestCase {

    func testStart_whenSessionAlreadyExists_callsSessionDidDuplicate() {
        let session = BTWebAuthenticationSession()
        let url = URL(string: "https://example.com")!
        let context = MockPresentationContext()
        let duplicateExpectation = expectation(description: "sessionDidDuplicate called")

        session.start(
            url: url,
            context: context,
            sessionDidComplete: { _, _ in },
            sessionDidAppear: { _ in },
            sessionDidCancel: { }
        )

        session.start(
            url: url,
            context: context,
            sessionDidComplete: { _, _ in },
            sessionDidAppear: { _ in },
            sessionDidCancel: { },
            sessionDidDuplicate: {
                duplicateExpectation.fulfill()
            }
        )

        waitForExpectations(timeout: 1)
    }
}
