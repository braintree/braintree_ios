import XCTest

/// IMPORTANT: Hardware keyboard should be disabled on simulator for tests to run reliably.
class PayPal_Vault_UITests: XCTestCase {

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
        app.launch()

        // Wait for app to be ready
        _ = app.wait(for: .runningForeground, timeout: 10)

        let vaultButton = app.buttons["PayPal Vault"]
        XCTAssertTrue(
            waitForElementToBeHittable(vaultButton, timeout: 30),
            "PayPal Vault button did not appear"
        )
        XCTAssertTrue(vaultButton.tapWithRetry(), "Failed to tap PayPal Vault button")

        // Tap "Continue" on alert
        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        waitForAuthDialogAndTapButton(named: "Continue")
    }

    private func waitForAuthDialogAndTapButton(named buttonName: String) {
        let button = springboard.buttons[buttonName]
        XCTAssertTrue(
            button.waitForExistence(timeout: 20.0),
            "Auth dialog button '\(buttonName)' did not appear"
        )
        XCTAssertTrue(button.tapWithRetry(), "Failed to tap auth dialog button '\(buttonName)'")
    }

    func testPayPal_vault_receivesNonce() {
        let webviewElementsQuery = app.webViews.element.otherElements
        let proceedLink = webviewElementsQuery.links["Proceed with Sandbox Purchase"]

        XCTAssertTrue(
            waitForElementToAppear(proceedLink, timeout: 30),
            "PayPal 'Proceed with Sandbox Purchase' link did not appear"
        )
        XCTAssertTrue(proceedLink.tapWithRetry(), "Failed to tap 'Proceed with Sandbox Purchase' link")

        let nonceButton = app.buttons["Got a nonce. Tap to make a transaction."]
        XCTAssertTrue(
            waitForElementToAppear(nonceButton, timeout: 30),
            "Nonce button did not appear"
        )
    }

    func testPayPal_vault_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        let webviewElementsQuery = app.webViews.element.otherElements
        let cancelLink = webviewElementsQuery.links["Cancel Sandbox Purchase"]

        XCTAssertTrue(
            waitForElementToAppear(cancelLink, timeout: 30),
            "PayPal 'Cancel Sandbox Purchase' link did not appear"
        )
        XCTAssertTrue(cancelLink.tapWithRetry(), "Failed to tap 'Cancel Sandbox Purchase' link")

        let canceledButton = app.buttons["PayPal flow was canceled by the user."]
        XCTAssertTrue(
            waitForElementToAppear(canceledButton, timeout: 30),
            "Canceled message did not appear"
        )
    }

    func testPayPal_vault_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        let cancelButton = app.buttons["Cancel"]

        XCTAssertTrue(
            waitForElementToAppear(cancelButton, timeout: 30),
            "Cancel button did not appear"
        )
        XCTAssertTrue(cancelButton.tapWithRetry(), "Failed to tap Cancel button")

        let canceledButton = app.buttons["PayPal flow was canceled by the user."]
        XCTAssertTrue(
            waitForElementToAppear(canceledButton, timeout: 30),
            "Canceled message did not appear"
        )
    }
}
