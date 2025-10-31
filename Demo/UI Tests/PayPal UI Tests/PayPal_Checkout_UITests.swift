import XCTest

/// IMPORTANT: Hardware keyboard should be disabled on simulator for tests to run reliably.
class PayPal_Checkout_UITests: XCTestCase {

    static var app = XCUIApplication()
    static var springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    // Launch app once for all tests
    override class func setUp() {

        super.setUp()

        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-MockedPayPalTokenizationKey")
        app.launchArguments.append("-Integration:PayPalWebCheckoutViewController")

        // Disable animations for more reliable tests
        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"

        app.launch()

        // Wait for app to be ready
        _ = app.wait(for: .runningForeground, timeout: 10)
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        // Add UI interruption monitor for each test
        addUIInterruptionMonitor(withDescription: "ASWebAuthenticationSession Alert") { alert in
            // Tap "Continue" button on the authentication session alert
            if alert.buttons["Continue"].exists {
                alert.buttons["Continue"].tap()
                return true
            }
            return false
        }

        // Navigate to PayPal Checkout for this test
        let paypalButton = PayPal_Checkout_UITests.app.buttons["PayPal Checkout"]
        if paypalButton.waitForExistence(timeout: 5) {
            paypalButton.tap()
            // Give time for ASWebAuthenticationSession alert to appear
            sleep(2)
        }
    }

    func testPayPal_checkout_receivesNonce() {
        // Trigger the interruption monitor to handle "Continue" button
        // Tap a specific element to ensure the monitor fires
        PayPal_Checkout_UITests.app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        // Give more time for the alert to be handled and web view to load
        sleep(3)

        // Wait for web view to confirm alert was handled and browser session started
        XCTAssertTrue(PayPal_Checkout_UITests.app.webViews.element.waitForExistence(timeout: 20), "Web view did not appear")

        let webviewElementsQuery = PayPal_Checkout_UITests.app.webViews.element.otherElements

        XCTAssertTrue(
            self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"], timeout: 30),
            "Proceed with Sandbox Purchase link did not appear"
        )

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(PayPal_Checkout_UITests.app.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 10))
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        // Trigger the interruption monitor to handle "Continue" button
        PayPal_Checkout_UITests.app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        // Give more time for the alert to be handled and web view to load
        sleep(3)

        // Wait for web view to confirm alert was handled and browser session started
        XCTAssertTrue(PayPal_Checkout_UITests.app.webViews.element.waitForExistence(timeout: 20), "Web view did not appear")

        let webviewElementsQuery = PayPal_Checkout_UITests.app.webViews.element.otherElements
        XCTAssertTrue(
            self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"], timeout: 30),
            "Cancel Sandbox Purchase link did not appear"
        )

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(PayPal_Checkout_UITests.app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 10))
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        // Don't trigger the interruption monitor - manually tap Cancel instead
        // The Cancel button is on the ASWebAuthenticationSession alert in springboard
        let cancelButton = PayPal_Checkout_UITests.springboard.buttons["Cancel"]
        _ = cancelButton.waitForExistence(timeout: 10)
        cancelButton.tap()

        XCTAssertTrue(PayPal_Checkout_UITests.app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 2))
    }
}
