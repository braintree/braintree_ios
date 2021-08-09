/*
 IMPORTANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class PayPal_Checkout_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:BraintreeDemoPayPalCheckoutViewController")
        app.launch()
        _ = app.buttons["PayPal Checkout"].waitForExistence(timeout: 2)
        app.buttons["PayPal Checkout"].tap()
        
        // Tap "Continue" on alert
        app.tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let continueButton = springboard.buttons["Continue"]
        if continueButton.waitForExistence(timeout: 2) {
            continueButton.tap()
        }
        app.coordinate(withNormalizedOffset: CGVector.zero).tap()
        sleep(1)
    }

    func testPayPal_checkout_receivesNonce() {
        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        let webviewElementsQuery = app.webViews.element.otherElements
        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"], timeout: 20)

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["PayPal Checkout"])

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].exists);
    }

    func testPayPal_checkout_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        self.waitForElementToAppear(app.buttons["Cancel"])

        app.buttons["Cancel"].forceTapElement()

        self.waitForElementToAppear(app.buttons["PayPal Checkout"])

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].exists);
    }
}
