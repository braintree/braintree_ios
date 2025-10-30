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
        app.launch()

        // Wait for app to be ready
        _ = app.wait(for: .runningForeground, timeout: 10)

        let paypalButton = app.buttons["PayPal Checkout"]
        _ = paypalButton.waitForExistence(timeout: 30)
        paypalButton.tap()

        // Tap "Continue" on ASWebAuthenticationSession alert
        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let continueButton = springboard.buttons["Continue"]
        _ = continueButton.waitForExistence(timeout: 30)
        continueButton.tap()
    }

    func testPayPal_checkout_receivesNonce() {
        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 2))
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        let webviewElementsQuery = app.webViews.element.otherElements
        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"])

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 2))
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        self.waitForElementToAppear(app.buttons["Cancel"])

        app.buttons["Cancel"].forceTapElement()

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].waitForExistence(timeout: 2))
    }
}
