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

        app.buttons["PayPal Checkout"].tap()
        
        // Tap "Continue" on alert
        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        waitForAuthDialogAndTapButton(named: "Continue")
    }
    
    private func waitForAuthDialogAndTapButton(named buttonName: String) {
        let button = springboard.buttons[buttonName]
        // Wait for button to appear - it may not appear on all iOS versions
        guard button.waitForExistence(timeout: 5.0) else {
            // Button didn't appear - this might be expected on some iOS versions
            // where the permission dialog is not shown
            print("ASWebAuthenticationSession '\(buttonName)' button not found - may not be required on this iOS version")
            return
        }
        button.tap()
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
