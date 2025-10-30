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

        let paypalButton = app.buttons["PayPal Vault"]
        _ = paypalButton.waitForExistence(timeout: 30)
        paypalButton.tap()

        // Tap "Continue" on ASWebAuthenticationSession alert if it appears
        // On CI, this dialog may be auto-dismissed or cached from previous runs
        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let continueButton = springboard.buttons["Continue"]
        if continueButton.waitForExistence(timeout: 5) {
            continueButton.tap()
        } else {
            print("Continue button did not appear - may be auto-approved on CI")
        }
    }

    func testPayPal_vault_receivesNonce() {
        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 2))
    }

    func testPayPal_vault_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"], timeout: 20)

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 2))
    }

    func testPayPal_vault_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        app.buttons["Cancel"].forceTapElement()

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 2))
    }
}
