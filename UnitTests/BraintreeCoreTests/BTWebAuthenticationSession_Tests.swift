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

    func testStart_threadSafety_whenStartingSessionsFromMultipleThreads_onlyOneSessionCreated() {
        let session = BTWebAuthenticationSession()
        let url = URL(string: "https://example.com")!
        let context = MockPresentationContext()
        let duplicateExpectation = expectation(description: "sessionDidDuplicate called for all but one thread")
        duplicateExpectation.expectedFulfillmentCount = 9
        let appearExpectation = expectation(description: "sessionDidAppear called once")
        appearExpectation.expectedFulfillmentCount = 1

        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            session.start(
                url: url,
                context: context,
                sessionDidComplete: { _, _ in },
                sessionDidAppear: { _ in appearExpectation.fulfill() },
                sessionDidCancel: { },
                sessionDidDuplicate: { duplicateExpectation.fulfill() }
            )
        }

        wait(for: [duplicateExpectation, appearExpectation], timeout: 2)
    }

    func testStart_dataRace_whenRapidlyStartingAndEndingSessions_noCrashOrUnexpectedBehavior() {
        let session = BTWebAuthenticationSession()
        let url = URL(string: "https://example.com")!
        let context = MockPresentationContext()
        
        let duplicateExpectation = expectation(description: "sessionDidDuplicate called")
        duplicateExpectation.expectedFulfillmentCount = 9
        
        let appearExpectation = expectation(description: "sessionDidAppear called")
        
        let testCompletionSemaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            session.start(
                url: url,
                context: context,
                sessionDidComplete: { _, _ in
                    // Not expecting this in our test scenario
                },
                sessionDidAppear: { _ in
                    // Only one session should appear
                    appearExpectation.fulfill()
                    
                    // End the test after a brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        testCompletionSemaphore.signal()
                    }
                },
                sessionDidCancel: { },
                sessionDidDuplicate: {
                    duplicateExpectation.fulfill()
                }
            )
        }
        
        wait(for: [duplicateExpectation, appearExpectation], timeout: 2)
        _ = testCompletionSemaphore.wait(timeout: .now() + 1)
    }
}
