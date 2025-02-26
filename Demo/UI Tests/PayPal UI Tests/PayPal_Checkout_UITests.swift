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
        app.launch()

        XCTAssertTrue(app.staticTexts["SandboxEnvironmentLabel"].waitForExistence(timeout: 5))

        app.buttons["PayPal Checkout"].tap()

        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        waitForAuthDialogAndTapButton(named: "Continue")
    }

    private func waitForAuthDialogAndTapButton(named buttonName: String) {
        let button = springboard.buttons[buttonName]
        XCTAssertTrue(button.waitForExistence(timeout: 20.0),
                      "The \(buttonName) button did not appear within 20 seconds.")
        button.tap()
    }

    func testPayPal_checkout_receivesNonce() {
        let webviewElementsQuery = app.webViews.element.otherElements
        let proceedLink = webviewElementsQuery.links["Proceed with Sandbox Purchase"]

        XCTAssertTrue(proceedLink.waitForExistence(timeout: 10),
                  "The 'Proceed with Sandbox Purchase' link did not appear in time.")
        XCTAssertTrue(proceedLink.isHittable,
                  "The 'Proceed with Sandbox Purchase' link is not hittable.")
        proceedLink.tap()

        let nonceButton = app.buttons["Got a nonce. Tap to make a transaction."]
        XCTAssertTrue(nonceButton.waitForExistence(timeout: 10),
                  "The 'Got a nonce. Tap to make a transaction.' button did not appear in time.")
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        let cancelLink = app.webViews.element.otherElements.links["Cancel Sandbox Purchase"]
        XCTAssertTrue(cancelLink.waitForExistence(timeout: 10))
        XCTAssertTrue(cancelLink.isHittable)
        cancelLink.tap()
        
        let canceledMessageButton = app.buttons["PayPal flow was canceled by the user."]
        XCTAssertTrue(canceledMessageButton.waitForExistence(timeout: 10))
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 10))
        XCTAssertTrue(cancelButton.isHittable)
        cancelButton.tap()
        
        let canceledMessageButton = app.buttons["PayPal flow was canceled by the user."]
        XCTAssertTrue(canceledMessageButton.waitForExistence(timeout: 10))
    }
}
