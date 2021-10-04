/*
 IMPORTANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class PayPal_Vault_UITests: XCTestCase {
    var app: XCUIApplication!
    var springboard: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:BraintreeDemoPayPalVaultViewController")
        app.launch()
        
        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        
        _ = app.buttons["PayPal Vault"].waitForExistence(timeout: 10)
        app.buttons["PayPal Vault"].tap()
        
        waitForAuthDialogAndTapButton(named: "Continue")
        app.coordinate(withNormalizedOffset: CGVector.zero).tap()
        sleep(1)
    }
    
    private func waitForAuthDialogAndTapButton(named buttonName: String) {
        _ = springboard.buttons[buttonName].waitForExistence(timeout: .threeDSecureTimeout)
        springboard.buttons[buttonName].tap()
    }

    func testPayPal_vault_receivesNonce() {
        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }

    func testPayPal_vault_cancelsSuccessfully_whenTappingCancelButtonOnPayPalSite() {
        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Cancel Sandbox Purchase"], timeout: 20)

        webviewElementsQuery.links["Cancel Sandbox Purchase"].forceTapElement()

        self.waitForElementToAppear(app.buttons["PayPal Vault"])

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].exists)
    }

    func testPayPal_vault_cancelsSuccessfully_whenTappingAuthenticationSessionCancelButton() {
        self.waitForElementToAppear(app.buttons["Cancel"])

        app.buttons["Cancel"].forceTapElement()

        self.waitForElementToAppear(app.buttons["PayPal Vault"])

        XCTAssertTrue(app.buttons["PayPal flow was canceled by the user."].exists);
    }
}
