/*
 IMPORTRANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class PayPal_BillingAgreement_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:BraintreeDemoPayPalBillingAgreementViewController")
        app.launch()
        sleep(1)
        self.waitForElementToBeHittable(app.buttons["Billing Agreement with PayPal"])
        app.buttons["Billing Agreement with PayPal"].tap()
        sleep(2)
    }

    func testPayPal_billingAgreement_receivesNonce() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])

        XCTAssertTrue(app.textViews["DismissalOfViewController Called"].exists);
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }

    func testPayPal_billingAgreement_cancelsSuccessfully() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"])

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Billing Agreement with PayPal"])

        XCTAssertTrue(app.textViews["DismissalOfViewController Called"].exists);
        XCTAssertTrue(app.buttons["Cancelled"].exists);
    }

    func testPayPal_billingAgreement_cancelsSuccessfully_whenTappingSFSafariViewControllerDoneButton() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        self.waitForElementToAppear(app.buttons["Done"])

        app.buttons["Done"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Billing Agreement with PayPal"])

        XCTAssertTrue(app.textViews["DismissalOfViewController Called"].exists);
        XCTAssertTrue(app.buttons["Cancelled"].exists);
    }
}
