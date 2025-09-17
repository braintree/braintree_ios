import XCTest
import BraintreeCore

class BTWebAuthenticationSession_Tests: XCTestCase {

    private let threadCount = 50

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
        
        let successCount = 1
        let duplicateCount = threadCount - successCount
        
        let duplicateExpectation = expectation(description: "sessionDidDuplicate called for all but one thread")
        duplicateExpectation.expectedFulfillmentCount = duplicateCount
        let appearExpectation = expectation(description: "sessionDidAppear called once")
        appearExpectation.expectedFulfillmentCount = successCount

        DispatchQueue.concurrentPerform(iterations: threadCount) { _ in
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

    func testStart_concurrentAccess_whenCallingFromMultipleThreadsSimultaneously_onlyOneSessionSucceeds() {
        let session = BTWebAuthenticationSession()
        let url = URL(string: "https://example.com")!
        let context = MockPresentationContext()
        
        let successCount = 1
        let duplicateCount = threadCount - successCount
        
        let successExpectation = expectation(description: "One session successfully started")
        successExpectation.expectedFulfillmentCount = successCount
        
        let duplicateExpectation = expectation(description: "Duplicate sessions rejected")
        duplicateExpectation.expectedFulfillmentCount = duplicateCount
        
        let group = DispatchGroup()
        let startBarrier = DispatchSemaphore(value: 0)
        
        for _ in 0..<threadCount {
            DispatchQueue.global().async(group: group) {
                // Wait until all threads are ready
                startBarrier.wait()
                
                session.start(
                    url: url,
                    context: context,
                    sessionDidComplete: { _, _ in },
                    sessionDidAppear: { _ in successExpectation.fulfill() },
                    sessionDidCancel: { },
                    sessionDidDuplicate: { duplicateExpectation.fulfill() }
                )
            }
        }
        
        // Release all threads at exactly the same time
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            for _ in 0..<self.threadCount {
                startBarrier.signal()
            }
        }
        
        wait(for: [successExpectation, duplicateExpectation], timeout: 5)
    }
    
    func testStart_dataRace_whenRapidlyStartingAndEndingSessions_noCrashOrUnexpectedBehavior() {
        let session = BTWebAuthenticationSession()
        let url = URL(string: "https://example.com")!
        let context = MockPresentationContext()
        
        let successCount = 1
        let duplicateCount = threadCount - successCount
        
        let duplicateExpectation = expectation(description: "sessionDidDuplicate called")
        duplicateExpectation.expectedFulfillmentCount = duplicateCount
        
        let appearExpectation = expectation(description: "sessionDidAppear called")
        appearExpectation.expectedFulfillmentCount = successCount
        
        let testCompletionSemaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.concurrentPerform(iterations: threadCount) { _ in
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
