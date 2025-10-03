import XCTest

// MARK: - Improved UI Test Helpers with Retry Logic

extension XCTestCase {

    /// Wait for element to appear with improved reliability
    @discardableResult
    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 30) -> Bool {
        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = expectation(for: existsPredicate, evaluatedWith: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Wait for element to be hittable with improved reliability
    @discardableResult
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 30) -> Bool {
        let predicate = NSPredicate(format: "exists == true && hittable == true && enabled == true")
        let expectation = expectation(for: predicate, evaluatedWith: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Wait for element to disappear
    @discardableResult
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 30) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = expectation(for: predicate, evaluatedWith: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Wait for element's value to change
    @discardableResult
    func waitForElementValue(_ element: XCUIElement, value: String, timeout: TimeInterval = 30) -> Bool {
        let predicate = NSPredicate(format: "value == %@", value)
        let expectation = expectation(for: predicate, evaluatedWith: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Retry an action with exponential backoff
    @discardableResult
    func retryAction(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 0.5,
        action: () throws -> Bool
    ) -> Bool {
        var delay = initialDelay

        for attempt in 1...maxAttempts {
            do {
                if try action() {
                    return true
                }
            } catch {
                print("Attempt \(attempt) failed with error: \(error)")
            }

            if attempt < maxAttempts {
                Thread.sleep(forTimeInterval: delay)
                delay *= 2 // Exponential backoff
            }
        }
        return false
    }

    /// Wait for network activity to complete
    func waitForNetworkIdle(timeout: TimeInterval = 10) {
        let app = XCUIApplication()
        let networkIndicator = app.otherElements["NetworkActivityIndicator"]

        if networkIndicator.exists {
            _ = waitForElementToDisappear(networkIndicator, timeout: timeout)
        } else {
            // If no network indicator, wait a small amount to ensure network has started
            Thread.sleep(forTimeInterval: 0.5)
        }
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

    /// Clear and type text with retry
    func clearAndTypeText(_ text: String, maxAttempts: Int = 3) -> Bool {
        for attempt in 1...maxAttempts {
            if self.tapWithRetry() {
                // Clear existing text
                if let currentValue = self.value as? String, !currentValue.isEmpty {
                    let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
                    self.typeText(deleteString)
                }

                // Type new text
                self.typeText(text)
                return true
            }

            if attempt < maxAttempts {
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        return false
    }

    /// Wait for element to be stable (not moving/animating)
    func waitForStablePosition(timeout: TimeInterval = 5) -> Bool {
        guard self.exists else { return false }

        let startFrame = self.frame
        Thread.sleep(forTimeInterval: 0.5)

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if self.frame.equalTo(startFrame) {
                return true
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        return false
    }

    /// Scroll to element if needed
    func scrollToElement(maxSwipes: Int = 5) -> Bool {
        guard self.exists else { return false }

        if self.isHittable {
            return true
        }

        let app = XCUIApplication()
        for _ in 1...maxSwipes {
            app.swipeUp()
            if self.isHittable {
                return true
            }
        }

        // Try scrolling down if up didn't work
        for _ in 1...maxSwipes {
            app.swipeDown()
            if self.isHittable {
                return true
            }
        }

        return false
    }

    /// Legacy method for backward compatibility
    func forceTapElement() {
        _ = self.tapWithRetry()
    }
}

// MARK: - 3DS Specific Helpers

extension XCTestCase {

    /// Wait for 3DS authentication frame to load
    func waitFor3DSFrame(timeout: TimeInterval = 45) -> Bool {
        let app = XCUIApplication()

        // Check for various 3DS indicators
        let indicators = [
            app.staticTexts["Purchase Authentication"],
            app.staticTexts["Merchant Authentication"],
            app.webViews.firstMatch,
            app.otherElements["Cardinal-ChallengeView"]
        ]

        for indicator in indicators {
            if waitForElementToAppear(indicator, timeout: timeout) {
                // Give the frame time to fully load
                Thread.sleep(forTimeInterval: 1)
                return true
            }
        }
        return false
    }

    /// Handle 3DS challenge with retry
    func handle3DSChallenge(otp: String, timeout: TimeInterval = 30) -> Bool {
        let app = XCUIApplication()

        // Look for OTP input field
        let otpFields = [
            app.textFields.element(boundBy: 0),
            app.secureTextFields.element(boundBy: 0),
            app.textFields["otp"],
            app.textFields["code"],
            app.textFields["passcode"]
        ]

        for field in otpFields {
            if waitForElementToBeHittable(field, timeout: timeout) {
                if field.clearAndTypeText(otp) {
                    // Look for submit button
                    let submitButtons = [
                        app.buttons["SUBMIT"],
                        app.buttons["Submit"],
                        app.buttons["Continue"],
                        app.buttons["Verify"]
                    ]

                    for button in submitButtons {
                        if button.exists && button.tapWithRetry() {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
}

// MARK: - Test Environment Setup

extension XCTestCase {

    /// Configure test environment for stability
    func configureTestEnvironment(app: XCUIApplication) {
        // Disable animations for faster, more reliable tests
        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"

        // Increase network timeouts for CI
        app.launchEnvironment["NETWORK_TIMEOUT_MULTIPLIER"] = "2"

        // Enable verbose logging for debugging
        app.launchEnvironment["UITEST_VERBOSE_LOGGING"] = "YES"

        // Disable rate limiting for tests
        app.launchEnvironment["DISABLE_RATE_LIMITING"] = "YES"
    }

    /// Clean up test state
    func cleanupTestState() {
        // Clear any cached data
        let app = XCUIApplication()
        app.terminate()

        // Clear simulator state if needed
        if ProcessInfo.processInfo.environment["CI"] != nil {
            // Running in CI, perform more aggressive cleanup
            Thread.sleep(forTimeInterval: 2)
        }
    }
}
