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
    }

    func testDropIn_cardInput_receivesNonce() {
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        let expiryTextField = elementsQuery.textFields["MM/YY"]

        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText("4111111111111111")
        expiryTextField.typeText("1119")

        elementsQuery.buttons["$19 - Subscribe Now"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
    
    func testDropIn_cardInput_showsInvalidState_withInvalidCardNumber() {
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]

        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText("4141414141414141")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: Card Number"])
    }
    
    func testDropIn_cardInput_showsInvalidState_withInvalidExpirationDate() {
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let expiryTextField = elementsQuery.textFields["MM/YY"]
        expiryTextField.forceTapElement()
        expiryTextField.typeText("1111")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: MM/YY"])
    }
    
    func testDropIn_cardInput_hidesInvalidCardNumberState_withDeletion() {
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText("4141414141414141")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: Card Number"])
        
        cardNumberTextField.typeText("\u{8}")
        
        XCTAssertFalse(elementsQuery.textFields["Invalid: Card Number"].exists);
    }
    
    func testDropIn_cardInput_hidesInvalidExpirationState_withDeletion() {
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let expirationField = elementsQuery.textFields["MM/YY"]
        expirationField.forceTapElement()
        expirationField.typeText("1111")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: MM/YY"])
        
        expirationField.typeText("\u{8}")
        
        XCTAssertFalse(elementsQuery.textFields["Invalid: MM/YY"].exists);
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
    }
    
    func testDropIn_cardInput_displaysErrorForFailedValidation() {
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        let expirationField = elementsQuery.textFields["MM/YY"]

        cardNumberTextField.forceTapElement()
        cardNumberTextField.typeText("5105105105105100")
        expirationField.typeText("1119")

        elementsQuery.buttons["$19 - Subscribe Now"].forceTapElement()
        
        self.waitForElementToAppear(app.alerts.staticTexts["Credit card verification failed"])
        
        XCTAssertTrue(app.alerts.staticTexts["Credit card verification failed"].exists);
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
    }
    
    func testDropIn_paypal_receivesNonce() {
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.collectionViews["Payment Options"].cells
        let paypalButton = elementsQuery.elementBoundByIndex(0)
        paypalButton.forceTapElement()
        sleep(2)
        
        let webviewElementsQuery = app.webViews.element.otherElements
        
        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])
        
        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
}