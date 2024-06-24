import XCTest
@testable import BraintreeCore

class RepeatingTimerTests: XCTestCase {

    func testTimer_ResumesAndSuspend() {
        let timer = RepeatingTimer()
        
        XCTAssertFalse(isTimerRunning(timer), "Timer should not be running immediately after initialization")
        timer.resume()
        
        XCTAssertTrue(isTimerRunning(timer), "Timer should be running after resume")
        timer.suspend()
        
        XCTAssertFalse(isTimerRunning(timer), "Timer should stop running after suspend")
    }

    func testEventHandler_IsCalled() {
        let expectation = expectation(description: "EventHandler should be called")
        let timer = RepeatingTimer(timeInterval: 1)
        
        timer.eventHandler = {
            expectation.fulfill()
        }
        
        timer.resume()
        waitForExpectations(timeout: 2, handler: nil)
        timer.suspend()
    }

    func testDeinit() {
        var timer: RepeatingTimer? = RepeatingTimer(timeInterval: 1)
        timer?.resume()
        
        addTeardownBlock {
            timer?.suspend()
        }
        
        timer = nil
        XCTAssertNil(timer, "Timer should be deallocated")
    }
    
    private func isTimerRunning(_ timer: RepeatingTimer) -> Bool {
        let expectation = expectation(description: "Timer should fire")
        var didFire = false
        
        timer.eventHandler = {
            didFire = true
            expectation.fulfill()
        }
        
        timer.resume()
        waitForExpectations(timeout: 2, handler: nil)
        timer.suspend()
        
        return didFire
    }
}
