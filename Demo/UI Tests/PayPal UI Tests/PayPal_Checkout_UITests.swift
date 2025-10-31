import XCTest

/// IMPORTANT: Hardware keyboard should be disabled on simulator for tests to run reliably.
class PayPal_Checkout_UITests: XCTestCase {

    var app = XCUIApplication()
    var springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-MockedPayPalTokenizationKey")
        app.launchArguments.append("-Integration:PayPalWebCheckoutViewController")

        // Disable animations for more reliable tests
        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"

        // Add UI interruption monitor to automatically handle ASWebAuthenticationSession alert
        addUIInterruptionMonitor(withDescription: "ASWebAuthenticationSession Alert") { alert in
            // Tap "Continue" button on the authentication session alert
            if alert.buttons["Continue"].exists {
                alert.buttons["Continue"].tap()
                return true
            }
            return false
        }

        app.launch()

        // Wait for app to be ready
        _ = app.wait(for: .runningForeground, timeout: 10)

        let paypalButton = app.buttons["PayPal Checkout"]
        _ = paypalButton.waitForExistence(timeout: 30)
        paypalButton.tap()

        // Give time for ASWebAuthenticationSession alert to appear
        sleep(2)
    }

    func testPayPal_checkout_receivesNonce() {
        // Trigger the interruption monitor to handle "Continue" button
        app.tap()

        // Wait for web view to confirm alert was handled and browser session started
        _ = app.webViews.element.waitForExistence(timeout: 10)

        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 2))
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        // Trigger the interruption monitor to handle "Continue" button
        app.tap()

        // Wait for web view to confirm alert was handled and browser session started
        _ = app.webViews.element.waitForExistence(timeout: 10)

        let webviewElementsQuery = app.webViews.element.otherElements
        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"])

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 2))
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        // Don't trigger the interruption monitor - manually tap Cancel instead
        // The Cancel button is on the ASWebAuthenticationSession alert in springboard
        let cancelButton = springboard.buttons["Cancel"]
        _ = cancelButton.waitForExistence(timeout: 10)
        cancelButton.tap()

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 2))
    }
}
