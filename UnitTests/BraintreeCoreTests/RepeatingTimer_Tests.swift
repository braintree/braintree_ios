import XCTest
@testable import BraintreeCore

class RepeatingTimerTests: XCTestCase {
    
    func testResume_callsEventHandler() {
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
    }
    
    func testSuspend_preventsEventHandler() {
        let sut = RepeatingTimer(timeInterval: 2)
        let expectation = expectation(description: "Timer should not fire after suspension")
        var handlerCalled = false

        sut.eventHandler = {
            handlerCalled = true
        }
        
        sut.resume()
        sut.suspend()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 4, handler: nil)
        XCTAssertFalse(handlerCalled, "Event handler should not be called after timer is suspended")
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
