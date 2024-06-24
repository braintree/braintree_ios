import XCTest
@testable import BraintreeCore

class RepeatingTimerTests: XCTestCase {

    func testTimer_resumesAndSuspends() {
        let sut = RepeatingTimer(timeInterval: 2)
        let expectation = expectation(description: "Timer should fire")
        var handlerCalled = false
        
        sut.eventHandler = {
            handlerCalled = true
            expectation.fulfill()
        }
        
        sut.resume()
        waitForExpectations(timeout: 3, handler: nil)
        XCTAssertTrue(handlerCalled, "Event handler should be called after timer resumes")
        
        handlerCalled = false
        sut.suspend()
        
        let suspensionExpectation = self.expectation(description: "Timer should not fire after suspension")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            suspensionExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertFalse(handlerCalled, "Event handler should not be called after timer is suspended")
    }

    func testEventHandler_isCalled() {
        let expectation = expectation(description: "EventHandler should be called")
        let sut = RepeatingTimer(timeInterval: 1)
        
        sut.eventHandler = {
            expectation.fulfill()
        }
        
        sut.resume()
        waitForExpectations(timeout: 2, handler: nil)
        sut.suspend()
    }

    func testDeinit() {
        var sut: RepeatingTimer? = RepeatingTimer(timeInterval: 1)
        sut?.resume()
        
        addTeardownBlock {
            sut?.suspend()
        }
        
        sut = nil
        XCTAssertNil(sut, "Timer should be deallocated")
    }
}
