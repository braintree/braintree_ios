import XCTest

class BraintreePayPal_FuturePayment_UITests: BTUITest {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        app.navigationBars.elementBoundByIndex(0).buttons["Settings"].tap()
        app.tables.staticTexts["Environment"].tap()
        app.tables.staticTexts["Sandbox (braintree-sample-merchant)"].tap()
        app.navigationBars["Environment"].buttons["Settings"].tap()
        app.tables.staticTexts["Integration"].tap()
        app.tables.staticTexts["PayPal - Custom Button"].tap()
        app.navigationBars["Integration"].buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["Done"].tap()
        app.buttons["PayPal (custom button)"].tap()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPayPal_futurePayment_receivesNonce() {
        let app = XCUIApplication()
        
        self.waitForElementToAppear(app.webViews.textFields["Email"])
        
        app.webViews.textFields["Email"].tap()
        app.webViews.textFields["Email"].typeText("test@paypal.com")
        app.webViews.staticTexts["Log In to PayPal"].tap()
        
        self.waitForElementToAppear(app.webViews.secureTextFields["Password"])
        
        app.webViews.secureTextFields["Password"].tap()
        app.webViews.secureTextFields["Password"].typeText("1234")
        app.webViews.staticTexts["Log In to PayPal"].tap()
        
        self.waitForElementToAppear(app.webViews.buttons["Log In"])
        
        app.webViews.buttons["Log In"].tap()
        
        self.waitForElementToAppear(app.webViews.buttons["Agree"])
        
        app.webViews.buttons["Agree"].tap()
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
    
    func testPayPal_futurePayment_cancelsSuccessfully() {
        let app = XCUIApplication()
        
        self.waitForElementToAppear(app.webViews.textFields["Email"])
        
        // This could be brittle, but the button has no accessibility helper
        app.webViews.buttons.elementBoundByIndex(0).tap()
        
        self.waitForElementToAppear(app.buttons["PayPal (custom button)"])
        
        XCTAssertTrue(app.buttons["Canceled 🔰"].exists);
    }
}
