/*
 IMPORTRANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class PayPal_FuturePayment_UITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:BraintreeDemoPayPalForceFuturePaymentViewController")
        app.launch()
        sleep(1)
        self.waitForElementToBeHittable(app.buttons["PayPal (future payment button)"])
        app.buttons["PayPal (future payment button)"].tap()
        sleep(2)
    }
    
    func testPayPal_futurePayment_receivesNonce() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = app.webViews.element.otherElements
        let emailTextField = webviewElementsQuery.textFields["Email"]
        
        self.waitForElementToAppear(emailTextField)
        emailTextField.forceTapElement()
        emailTextField.typeText("test@paypal.com")
        
        let passwordTextField = webviewElementsQuery.secureTextFields["Password"]
        passwordTextField.forceTapElement()
        passwordTextField.typeText("1234")
        
        webviewElementsQuery.buttons["Log In"].forceTapElement()
        
        self.waitForElementToAppear(webviewElementsQuery.buttons["Agree"])
        
        webviewElementsQuery.buttons["Agree"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
    
    func testPayPal_futurePayment_cancelsSuccessfully() {
        if #available(iOS 11.0, *) {
            // SFSafariAuthenticationSession flow cannot be fully automated, so returning early
            return
        }

        let webviewElementsQuery = app.webViews.element.otherElements
        let emailTextField = webviewElementsQuery.textFields["Email"]
        
        self.waitForElementToAppear(emailTextField)
        
        // Close button has no accessibility helper
        // Purposely don't use the webviewElementsQuery variable
        // Reevaluate the elements query after the page load to get the close button
        app.webViews.buttons.element(boundBy: 0).forceTapElement()
        
        self.waitForElementToAppear(app.buttons["PayPal (future payment button)"])
        
        XCTAssertTrue(app.buttons["Canceled 🔰"].exists);
    }
}
