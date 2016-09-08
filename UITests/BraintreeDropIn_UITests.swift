/*
 IMPORTANT
 Hardware keyboard should be disabled on simulator for tests to run reliably.
 */

import XCTest

class BraintreeDropIn_TokenizationKey_CardForm_UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:BraintreeDemoDropInViewController")
        app.launch()
        sleep(1)
        self.waitForElementToBeHittable(app.buttons["Add Payment Method"])
        app.buttons["Add Payment Method"].tap()
    }

    func testDropIn_dismessesWhenCancelled() {
        self.waitForElementToBeHittable(app.buttons["Cancel"])
        app.buttons["Cancel"].forceTapElement()
        XCTAssertTrue(app.buttons["Cancelled🎲"].exists);
    }
    
    func testDropIn_displaysPaymentOptions_applePay_card_payPal() {
        self.waitForElementToBeHittable(app.staticTexts["Credit or Debit Card"])
        sleep(1)
        XCTAssertTrue(app.staticTexts["Credit or Debit Card"].exists);
        XCTAssertTrue(app.staticTexts["PayPal"].exists);
        XCTAssertTrue(app.staticTexts["Apple Pay"].exists);
    }
    
    func testDropIn_cardInput_receivesNonce() {
        
        self.waitForElementToBeHittable(app.staticTexts["Credit or Debit Card"])
        app.staticTexts["Credit or Debit Card"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        
        self.waitForElementToBeHittable(cardNumberTextField)
        
        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText("4111111111111111")
        
        self.waitForElementToBeHittable(app.staticTexts["2019"])
        app.staticTexts["11"].forceTapElement()
        app.staticTexts["2019"].forceTapElement()
        
        let securityCodeField = elementsQuery.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")
        
        let postalCodeField = elementsQuery.textFields["65350"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")
        
        app.buttons["Add Card"].forceTapElement()
        
        self.waitForElementToAppear(app.staticTexts["ending in 11"])
        
        XCTAssertTrue(app.staticTexts["ending in 11"].exists);
    }
    
    func testDropIn_cardInput_showsInvalidState_withInvalidCardNumber() {
        
        self.waitForElementToBeHittable(app.staticTexts["Credit or Debit Card"])
        app.staticTexts["Credit or Debit Card"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        
        self.waitForElementToBeHittable(cardNumberTextField)
        
        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText("4141414141414141")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: Card Number"])
    }
    
    func testDropIn_cardInput_hidesInvalidCardNumberState_withDeletion() {
        
        self.waitForElementToBeHittable(app.staticTexts["Credit or Debit Card"])
        app.staticTexts["Credit or Debit Card"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        
        self.waitForElementToBeHittable(cardNumberTextField)
        
        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText("4141414141414141")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: Card Number"])
        
        cardNumberTextField.typeText("\u{8}")
        
        XCTAssertFalse(elementsQuery.textFields["Invalid: Card Number"].exists);
    }
}

class BraintreeDropIn_ClientToken_CardForm_UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoDropInViewController")
        app.launch()
        sleep(1)
        self.waitForElementToBeHittable(app.buttons["Add Payment Method"])
        app.buttons["Add Payment Method"].tap()
    }
    
    func testDropIn_cardInput_receivesNonce() {
        self.waitForElementToBeHittable(app.staticTexts["Credit or Debit Card"])
        app.staticTexts["Credit or Debit Card"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        
        self.waitForElementToBeHittable(cardNumberTextField)
        
        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText("4111111111111111")
        
        self.waitForElementToBeHittable(app.buttons["Next"])
        app.buttons["Next"].forceTapElement()
        
        let expiryTextField = app.scrollViews.otherElements.textFields["MM/YYYY"]
        self.waitForElementToBeHittable(expiryTextField)
        expiryTextField.forceTapElement()
        
        self.waitForElementToBeHittable(app.staticTexts["2019"])
        app.staticTexts["11"].forceTapElement()
        app.staticTexts["2019"].forceTapElement()
        
        let securityCodeField = app.scrollViews.otherElements.textFields["CVV"]
        self.waitForElementToBeHittable(securityCodeField)
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")
        
        let postalCodeField = app.scrollViews.otherElements.textFields["65350"]
        self.waitForElementToBeHittable(postalCodeField)
        postalCodeField.forceTapElement()
        postalCodeField.typeText("12345")
        
        app.buttons["Add Card"].forceTapElement()
        
        self.waitForElementToAppear(app.staticTexts["ending in 11"])
        
        XCTAssertTrue(app.staticTexts["ending in 11"].exists);
    }
    
    func testDropIn_unionPayCardNumber_receivesNonce() {
        self.waitForElementToBeHittable(app.staticTexts["Credit or Debit Card"])
        app.staticTexts["Credit or Debit Card"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        
        self.waitForElementToBeHittable(cardNumberTextField)
        
        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText("6212345678901232")
        
        self.waitForElementToBeHittable(app.buttons["Next"])
        app.buttons["Next"].forceTapElement()
        
        let expiryTextField = app.scrollViews.otherElements.textFields["MM/YYYY"]
        self.waitForElementToBeHittable(expiryTextField)
        expiryTextField.forceTapElement()
        
        self.waitForElementToBeHittable(app.staticTexts["2019"])
        app.staticTexts["11"].forceTapElement()
        app.staticTexts["2019"].forceTapElement()
        
        app.staticTexts["Security Code"].forceTapElement()
        app.typeText("565")

        app.staticTexts["Mobile Country Code"].forceTapElement()
        app.typeText("65")
        
        app.staticTexts["Mobile Number"].forceTapElement()
        app.typeText("1235566543")
        
        app.buttons["Add Card"].forceTapElement()
        
        self.waitForElementToBeHittable(app.alerts.buttons["OK"])
        app.alerts.buttons["OK"].tap()
        
        self.waitForElementToBeHittable(app.textFields["SMS Code"])
        app.textFields["SMS Code"].forceTapElement()
        app.typeText("12345")
        
        self.waitForElementToBeHittable(app.buttons["Confirm"])
        app.buttons["Confirm"].forceTapElement()
        
        self.waitForElementToAppear(app.staticTexts["ending in 32"])
        
        XCTAssertTrue(app.staticTexts["ending in 32"].exists);
        
    }
}


class BraintreeDropIn_PayPal_UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:BraintreeDemoDropInViewController")
        app.launch()
        sleep(1)
        self.waitForElementToBeHittable(app.buttons["Add Payment Method"])
        app.buttons["Add Payment Method"].tap()
    }
    
    func testDropIn_paypal_receivesNonce() {
        self.waitForElementToBeHittable(app.staticTexts["PayPal"])
        app.staticTexts["PayPal"].tap()
        sleep(3)
        
        let webviewElementsQuery = app.webViews.element.otherElements
        
        self.waitForElementToBeHittable(webviewElementsQuery.links["Proceed with Sandbox Purchase"])
        
        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()
        
        self.waitForElementToAppear(app.staticTexts["bt_buyer_us@paypal.com"])
        
        XCTAssertTrue(app.staticTexts["bt_buyer_us@paypal.com"].exists);
    }
}