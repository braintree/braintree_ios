/*
 IMPORTRANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class PayPal_SinglePayment_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:BraintreeDemoPayPalOneTimePaymentViewController")
        app.launch()
        sleep(1)
        self.waitForElementToBeHittable(app.buttons["PayPal one-time payment"])
        app.buttons["PayPal one-time payment"].tap()
        sleep(2)
    }

    func testPayPal_singlePayment_receivesNonce() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }

    func testPayPal_singlePayment_cancelsSuccessfully() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"])

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["PayPal one-time payment"])

        XCTAssertTrue(app.buttons["Cancelled"].exists);
    }
}
