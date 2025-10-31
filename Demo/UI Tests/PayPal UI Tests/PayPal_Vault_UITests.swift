import XCTest

/// IMPORTANT: Hardware keyboard should be disabled on simulator for tests to run reliably.
class PayPal_Vault_UITests: XCTestCase {

    var app = XCUIApplication()
    var springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        // Reset the app state to ensure ASWebAuthenticationSession alert appears fresh
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-MockedPayPalTokenizationKey")
        app.launchArguments.append("-Integration:PayPalWebCheckoutViewController")

        // Disable animations for more reliable tests
        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"

        app.launch()

        // Wait for app to be ready
        _ = app.wait(for: .runningForeground, timeout: 10)

        let paypalButton = app.buttons["PayPal Vault"]
        _ = paypalButton.waitForExistence(timeout: 30)
        paypalButton.tap()

        // Give time for ASWebAuthenticationSession alert to appear
        sleep(1)
    }

    func testPayPal_vault_receivesNonce() {
        // Check if Continue button appears, or if web view appears directly (session auto-continued)
        let continueButton = springboard.buttons["Continue"]

        if continueButton.waitForExistence(timeout: 5) {
            continueButton.tap()
        } else {
            // Continue button didn't appear - check if web view loaded directly
            // This can happen if iOS cached the permission from a previous session
            print("Continue button did not appear, checking if web view loaded anyway")
        }

        // Wait for web view to appear
        XCTAssertTrue(app.webViews.element.waitForExistence(timeout: 30), "Web view did not appear")

        let webviewElementsQuery = app.webViews.element.otherElements

        XCTAssertTrue(
            self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"], timeout: 30),
            "Proceed with Sandbox Purchase link did not appear"
        )

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 10))
    }

    func testPayPal_vault_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        // Check if Continue button appears, or if web view appears directly (session auto-continued)
        let continueButton = springboard.buttons["Continue"]

        if continueButton.waitForExistence(timeout: 5) {
            continueButton.tap()
        } else {
            // Continue button didn't appear - check if web view loaded directly
            print("Continue button did not appear, checking if web view loaded anyway")
        }

        // Wait for web view to appear
        XCTAssertTrue(app.webViews.element.waitForExistence(timeout: 30), "Web view did not appear")

        let webviewElementsQuery = app.webViews.element.otherElements

        XCTAssertTrue(
            self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"], timeout: 30),
            "Cancel Sandbox Purchase link did not appear"
        )

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 10))
    }

    func testPayPal_vault_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        // Don't trigger the interruption monitor - manually tap Cancel instead
        // The Cancel button is on the ASWebAuthenticationSession alert in springboard
        let cancelButton = springboard.buttons["Cancel"]
        _ = cancelButton.waitForExistence(timeout: 10)
        cancelButton.tap()

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 2))
    }
}
