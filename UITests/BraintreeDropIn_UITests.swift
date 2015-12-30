/*
IMPORTRANT
Hardware keyboard should be disabled on simulator for tests to run reliably.
*/

import XCTest

class BraintreeDropIn_TokenizationKey_CardForm_UITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:BraintreeDemoDropInViewController")
        app.launch()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDropIn_cardInput_receivesNonce() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        cardNumberTextField.forceTapElement()
        sleep(1)
        cardNumberTextField.typeText("4111111111111111")
        
        elementsQuery.staticTexts["Pay with a card"].forceTapElement()
        sleep(1)
        
        elementsQuery.textFields["MM/YY"].forceTapElement()
        sleep(1)
        elementsQuery.textFields["MM/YY"].typeText("1119")

        elementsQuery.buttons["$19 - Subscribe Now"].forceTapElement()

        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
    
    func testDropIn_cardInput_showsInvalidState_withInvalidCardNumber() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        cardNumberTextField.forceTapElement()
        sleep(1)
        cardNumberTextField.typeText("4141414141414141")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: Card Number"])
    }
    
    func testDropIn_cardInput_showsInvalidState_withInvalidExpirationDate() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.textFields["MM/YY"].forceTapElement()
        sleep(1)
        elementsQuery.textFields["MM/YY"].typeText("1111")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: MM/YY"])
    }
    
    func testDropIn_cardInput_hidesInvalidCardNumberState_withDeletion() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        cardNumberTextField.forceTapElement()
        sleep(1)
        cardNumberTextField.typeText("4141414141414141")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: Card Number"])
        
        cardNumberTextField.typeText("\u{8}")
        
        XCTAssertFalse(elementsQuery.textFields["Invalid: Card Number"].exists);
    }
    
    func testDropIn_cardInput_hidesInvalidExpirationState_withDeletion() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        let expirationField = elementsQuery.textFields["MM/YY"]
        expirationField.forceTapElement()
        sleep(1)
        expirationField.typeText("1111")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: MM/YY"])
        
        expirationField.typeText("\u{8}")
        
        XCTAssertFalse(elementsQuery.textFields["Invalid: MM/YY"].exists);
    }
}

class BraintreeDropIn_ClientToken_CardForm_UITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoDropInViewController")
        app.launch()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDropIn_cardInput_displaysErrorForFailedValidation() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.scrollViews.otherElements
        
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        cardNumberTextField.forceTapElement()
        sleep(1)
        cardNumberTextField.typeText("5105105105105100")
        
        elementsQuery.staticTexts["Pay with a card"].forceTapElement()
        sleep(1)
        
        elementsQuery.textFields["MM/YY"].forceTapElement()
        sleep(1)
        elementsQuery.textFields["MM/YY"].typeText("1119")
        
        elementsQuery.buttons["$19 - Subscribe Now"].forceTapElement()
        
        self.waitForElementToAppear(app.alerts.staticTexts["Credit card verification failed"])
        
        XCTAssertTrue(app.alerts.staticTexts["Credit card verification failed"].exists);
    }
    
   
}


class BraintreeDropIn_PayPal_UITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:BraintreeDemoDropInViewController")
        app.launch()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDropIn_paypal_receivesNonce() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].forceTapElement()
        
        let elementsQuery = app.collectionViews["Payment Options"].cells.elementBoundByIndex(0)
        elementsQuery.forceTapElement()
        sleep(2)
        
        let webviewElementsQuery = app.webViews.element.otherElements
        let emailTextField = webviewElementsQuery.textFields["Email"]
        
        self.waitForElementToAppear(emailTextField)
        emailTextField.forceTapElement()
        sleep(1)
        emailTextField.typeText("test@paypal.com")
        
        let passwordTextField = webviewElementsQuery.secureTextFields["Password"]
        passwordTextField.forceTapElement()
        sleep(1)
        passwordTextField.typeText("1234")
        
        webviewElementsQuery.buttons["Log In"].forceTapElement()
        
        self.waitForElementToAppear(webviewElementsQuery.buttons["Agree"])
        
        webviewElementsQuery.buttons["Agree"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
}