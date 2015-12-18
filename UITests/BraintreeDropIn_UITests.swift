import XCTest

class BraintreeDropIn_CardForm_UITests: BTUITest {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-Integration:BraintreeDemoDropInViewController")
        app.launch()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDropIn_cardInput_receivesNonce() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.textFields["MM/YY"].tap()
        elementsQuery.textFields["MM/YY"].typeText("1119")
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4111111111111111")
        elementsQuery.buttons["$19 - Subscribe Now"].tap()
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
    
    func testDropIn_cardInput_showsInvalidState_withInvalidCardNumber() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4141414141414141")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: Card Number"])
    }
    
    func testDropIn_cardInput_showsInvalidState_withInvalidExpirationDate() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.textFields["MM/YY"].tap()
        elementsQuery.textFields["MM/YY"].typeText("1111")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: MM/YY"])
    }
    
    func testDropIn_cardInput_hidesInvalidCardNumberState_withDeletion() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let cardNumberTextField = elementsQuery.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4141414141414141")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: Card Number"])
        
        cardNumberTextField.typeText("\u{8}")
        
        XCTAssertFalse(elementsQuery.textFields["Invalid: Card Number"].exists);
    }
    
    func testDropIn_cardInput_hidesInvalidExpirationState_withDeletion() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let expirationField = elementsQuery.textFields["MM/YY"]
        expirationField.tap()
        expirationField.typeText("1111")
        
        self.waitForElementToAppear(elementsQuery.textFields["Invalid: MM/YY"])
        
        expirationField.typeText("\u{8}")
        
        XCTAssertFalse(elementsQuery.textFields["Invalid: MM/YY"].exists);
    }
    
    func testDropIn_paypalIntegration() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].tap()
        
        let elementsQuery = app.collectionViews["Payment Options"].cells.elementAtIndex(0)
        elementsQuery.tap()
        sleep(2)
        
        self.waitForElementToAppear(app.webViews.textFields["Email"])
        
        app.webViews.textFields["Email"].forceTapElement()
        sleep(1)
        app.webViews.textFields["Email"].typeText("test@paypal.com")
        
        app.webViews.secureTextFields["Password"].forceTapElement()
        sleep(1)
        app.webViews.secureTextFields["Password"].typeText("1234")
        
        app.webViews.buttons["Log In"].forceTapElement()
        
        self.waitForElementToAppear(app.webViews.buttons["Agree"])
        
        app.webViews.buttons["Agree"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
}

class BraintreeDropIn_PayPal_UITests: BTUITest {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-Integration:BraintreeDemoDropInViewController")
        app.launch()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDropIn_paypal_receivesNonce() {
        let app = XCUIApplication()
        
        app.buttons["Buy Now"].tap()
        
        let elementsQuery = app.collectionViews["Payment Options"].cells.elementBoundByIndex(0)
        elementsQuery.tap()
        sleep(2)
        
        self.waitForElementToAppear(app.webViews.textFields["Email"])
        
        app.webViews.textFields["Email"].forceTapElement()
        sleep(1)
        app.webViews.textFields["Email"].typeText("test@paypal.com")
        
        app.webViews.secureTextFields["Password"].forceTapElement()
        sleep(1)
        app.webViews.secureTextFields["Password"].typeText("1234")
        
        app.webViews.buttons["Log In"].forceTapElement()
        
        self.waitForElementToAppear(app.webViews.buttons["Agree"])
        
        app.webViews.buttons["Agree"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
}