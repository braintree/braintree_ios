import XCTest

class UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPayPalFuturePayment() {
        let app = XCUIApplication()
        app.navigationBars.elementBoundByIndex(0).buttons["Settings"].tap()
        app.tables.staticTexts["Integration"].tap()
        app.tables.staticTexts["PayPal - Custom Button"].tap()
        app.navigationBars["Integration"].buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["Done"].tap()
        app.buttons["PayPal (custom button)"].tap()
        
        sleep(5)
        
        app.webViews.secureTextFields["Password"].tap()
        app.webViews.secureTextFields["Password"].typeText("1234")
        app.tap()
        
        sleep(2)
        
        app.webViews.textFields["Email"].tap()
        app.webViews.textFields["Email"].typeText("test@paypal.com")
        app.tap()
        
        sleep(2)
        
        app.webViews.buttons["Log In"].tap()
        
        sleep(5)
        
        app.webViews.buttons["Agree"].tap()
        
        sleep(2)
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }

}
