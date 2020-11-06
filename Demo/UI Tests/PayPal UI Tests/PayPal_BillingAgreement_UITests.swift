/*
 IMPORTANT
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

        // Tap "Continue" on alert
        addUIInterruptionMonitor(withDescription: "Alert prompting user that the app wants to use PayPal.com to sign in.") { (alert) -> Bool in
            let continueButton = alert.buttons["Continue"]
            if (alert.buttons["Continue"].exists) {
                continueButton.tap()
            }
            return true
        }
        app.tap()
        sleep(1)
    }

    func testPayPal_billingAgreement_receivesNonce() {
        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }

    func testPayPal_billingAgreement_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"])

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Billing Agreement with PayPal"])

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].exists)
    }

    func testPayPal_billingAgreement_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        self.waitForElementToAppear(app.buttons["Cancel"])

        app.buttons["Cancel"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Billing Agreement with PayPal"])

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].exists);
    }
}
