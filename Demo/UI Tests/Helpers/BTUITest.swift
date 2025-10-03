import XCTest

extension XCTestCase {
    
    /// Wait for element to appear
    @discardableResult
    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 30) -> Bool {
        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = expectation(for: existsPredicate, evaluatedWith: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Wait for element to be hittable
    @discardableResult
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 30) -> Bool {
        let predicate = NSPredicate(format: "exists == true && hittable == true && enabled == true")
        let expectation = expectation(for: predicate, evaluatedWith: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {

    /// Improved tap with retry logic
    func tapWithRetry(maxAttempts: Int = 3) -> Bool {
        for attempt in 1...maxAttempts {
            if self.waitForExistence(timeout: 2) {
                if self.isHittable {
                    self.tap()
                    return true
                } else {
                    // Try coordinate-based tap if element exists but not hittable
                    self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                    return true
                }
            }

            if attempt < maxAttempts {
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        return false
    }

    func forceTapElement() {
        _ = self.tapWithRetry()
    }
}
