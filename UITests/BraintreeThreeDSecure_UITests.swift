/*
 IMPORTRANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class BraintreeThreeDSecurePaymentFlow_UITests: XCTestCase {
    var app: XCUIApplication!
    let timeout: TimeInterval = 20
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoThreeDSecurePaymentFlowViewController")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(app.textFields["Card Number"])
        sleep(2)
    }

    func getPasswordFieldQuery() -> XCUIElementQuery {
        return app.webViews.element.otherElements.children(matching: .other).children(matching: .secureTextField)
    }

    func getSubmitButton() -> XCUIElement {
        return app.webViews.element.otherElements.children(matching: .other).children(matching: .other).buttons["Submit"]
    }

    func testThreeDSecurePaymentFlow_completesAuthentication_receivesNonce() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000002")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        
        self.waitForElementToAppear(getPasswordFieldQuery().element, timeout: timeout)
        let passwordTextField = getPasswordFieldQuery().element

        passwordTextField.forceTapElement()
        sleep(2)
        passwordTextField.typeText("1234")
        
        getSubmitButton().tap()
        
        self.waitForElementToAppear(app.buttons["Liability shift possible and liability shifted"])
    }
    
    func testThreeDSecurePaymentFlow_failsAuthentication() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000010")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(getPasswordFieldQuery().element, timeout: timeout)
        let passwordTextField = getPasswordFieldQuery().element
        
        passwordTextField.forceTapElement()
        sleep(1)
        passwordTextField.typeText("1234")
        
        getSubmitButton().tap()
        
        self.waitForElementToAppear(app.buttons["Failed to authenticate, please try a different form of payment."])
    }
    
    func testThreeDSecurePaymentFlow_bypassesAuthentication_notEnrolled() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000051")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
    }
    
    func testThreeDSecurePaymentFlow_bypassesAuthentication_lookupFailed() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000077")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
    }
    
    func testThreeDSecurePaymentFlow_incorrectPassword_callsBackWithError_exactlyOnce() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000028")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(getPasswordFieldQuery().element, timeout: timeout)
        let passwordTextField = getPasswordFieldQuery().element
        
        passwordTextField.forceTapElement()
        sleep(1)
        passwordTextField.typeText("1234")
        
        getSubmitButton().tap()
        
        self.waitForElementToAppear(app.buttons["Failed to authenticate, please try a different form of payment."])
        
        sleep(2)
        
        self.waitForElementToAppear(app.staticTexts["Callback Count: 1"])
    }
    
    func testThreeDSecurePaymentFlow_passiveAuthentication_notPromptedForAuthentication() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000101")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["Liability shift possible and liability shifted"])
    }
    
    func testThreeDSecurePaymentFlow_returnsNonce_whenIssuerDown() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000036")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(getPasswordFieldQuery().element, timeout: timeout)
        let passwordTextField = getPasswordFieldQuery().element
        
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("1234")
        
        getSubmitButton().tap()
        
        self.waitForElementToAppear(app.buttons["An unexpected error occurred"])
    }
    
    func testThreeDSecurePaymentFlow_acceptsPassword_failsToAuthenticateNonce_dueToCardinalError() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000093")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(getPasswordFieldQuery().element, timeout: timeout)
        let passwordTextField = getPasswordFieldQuery().element

        passwordTextField.forceTapElement()
        sleep(2)
        passwordTextField.typeText("1234")

        getSubmitButton().tap()

        self.waitForElementToAppear(app.buttons["An unexpected error occurred"])
    }
    
    func testThreeDSecurePaymentFlow_returnsToApp_whenCancelTapped() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000002")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(app.buttons["Done"])

        app.buttons["Done"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Cancelled🎲"])

        XCTAssertTrue(app.buttons["Cancelled🎲"].exists);
    }
    
    func testThreeDSecurePaymentFlow_bypassedAuthentication() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000990000000004")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
    }
    
    func testThreeDSecurePaymentFlow_lookupError() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000085")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
    }
    
    func testThreeDSecurePaymentFlow_unavailable() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000069")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
    }
    
    func testThreeDSecurePaymentFlow_timeout() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000044")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(5)
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
    }
}


class BraintreeThreeDSecure_UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoThreeDSecureViewController")
        self.app.launch()
        sleep(1)
        self.waitForElementToBeHittable(app.textFields["Card Number"])
        sleep(2)
    }

    func getPasswordFieldQuery() -> XCUIElementQuery {
        return app.webViews.element.otherElements.children(matching: .other).children(matching: .secureTextField)
    }

    func getSubmitButton() -> XCUIElement {
        return app.webViews.element.otherElements.children(matching: .other).children(matching: .other).buttons["Submit"]
    }

    func testThreeDSecure_completesAuthentication_receivesNonce() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000002")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(getPasswordFieldQuery().element)
        let passwordTextField = getPasswordFieldQuery().element

        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("1234")

        getSubmitButton().tap()

        self.waitForElementToAppear(app.buttons["Liability shift possible and liability shifted"])

        XCTAssertTrue(app.buttons["Liability shift possible and liability shifted"].exists);
    }

    func testThreeDSecure_failsAuthentication() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000010")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(getPasswordFieldQuery().element)
        let passwordTextField = getPasswordFieldQuery().element

        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("1234")

        getSubmitButton().tap()

        self.waitForElementToAppear(app.buttons["Failed to authenticate, please try a different form of payment."])

        XCTAssertTrue(app.buttons["Failed to authenticate, please try a different form of payment."].exists);
    }

    func testThreeDSecure_bypassesAuthentication_notEnrolled() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000051")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])
        
        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }

    func testThreeDSecure_bypassesAuthentication_lookupFailed() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000077")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)

        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])

        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }

    func testThreeDSecure_incorrectPassword_callsBackWithError_exactlyOnce() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000028")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(getPasswordFieldQuery().element)
        let passwordTextField = getPasswordFieldQuery().element

        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("1234")

        getSubmitButton().tap()

        self.waitForElementToAppear(app.buttons["Failed to authenticate, please try a different form of payment."])

        XCTAssertTrue(app.buttons["Failed to authenticate, please try a different form of payment."].exists);

        sleep(2)

        self.waitForElementToAppear(app.staticTexts["Callback Count: 1"])

        XCTAssertTrue(app.staticTexts["Callback Count: 1"].exists);
    }

    func testThreeDSecure_passiveAuthentication_notPromptedForAuthentication() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000101")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)

        self.waitForElementToAppear(app.buttons["Liability shift possible and liability shifted"])

        XCTAssertTrue(app.buttons["Liability shift possible and liability shifted"].exists);
    }

    func testThreeDSecure_returnsNonce_whenIssuerDown() {
        let app = XCUIApplication()
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000036")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(getPasswordFieldQuery().element)
        let passwordTextField = getPasswordFieldQuery().element

        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("1234")

        getSubmitButton().tap()

        self.waitForElementToAppear(app.buttons["An unexpected error occurred"])

        XCTAssertTrue(app.buttons["An unexpected error occurred"].exists);
    }

    func testThreeDSecure_acceptsPassword_failsToAuthenticateNonce_dueToCardinalError() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000093")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()

        self.waitForElementToAppear(getPasswordFieldQuery().element)
        let passwordTextField = getPasswordFieldQuery().element

        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("1234")

        getSubmitButton().tap()

        self.waitForElementToAppear(app.buttons["An unexpected error occurred"])

        XCTAssertTrue(app.buttons["An unexpected error occurred"].exists);
    }

    func testThreeDSecure_returnsToApp_whenCancelTapped() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000002")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)

        self.waitForElementToBeHittable(app.buttons["Cancel"])

        app.buttons["Cancel"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Cancelled🎲"])

        XCTAssertTrue(app.buttons["Cancelled🎲"].exists);
    }

    func testThreeDSecure_bypassedAuthentication() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000990000000004")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)

        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])

        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }

    func testThreeDSecure_lookupError() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000085")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)

        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])

        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }

    func testThreeDSecure_unavailable() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000069")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(2)

        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])

        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }

    func testThreeDSecure_timeout() {
        self.waitForElementToAppear(app.textFields["Card Number"])
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4000000000000044")
        app.textFields["MM/YY"].typeText(Helpers.sharedInstance.futureDate())
        app.buttons["Tokenize and Verify New Card"].tap()
        sleep(5)

        self.waitForElementToAppear(app.buttons["3D Secure authentication was attempted but liability shift is not possible"])

        XCTAssertTrue(app.buttons["3D Secure authentication was attempted but liability shift is not possible"].exists);
    }

}
