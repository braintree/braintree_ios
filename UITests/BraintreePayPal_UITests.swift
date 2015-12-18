import XCTest

class BraintreePayPal_FuturePayment_UITests: BTUITest {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-Integration:BraintreeDemoCustomPayPalButtonViewController")
        app.launch()
        app.buttons["PayPal (custom button)"].forceTapElement()
        sleep(2)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPayPal_futurePayment_receivesNonce() {
        let app = XCUIApplication()

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
    
    func testPayPal_futurePayment_cancelsSuccessfully() {
        let app = XCUIApplication()
        
        self.waitForElementToAppear(app.webViews.textFields["Email"])

        // Close button has no accessibility helper
        app.webViews.buttons.elementBoundByIndex(0).forceTapElement()
        
        self.waitForElementToAppear(app.buttons["PayPal (custom button)"])
        
        XCTAssertTrue(app.buttons["Canceled 🔰"].exists);
    }
}

class BraintreePayPal_SinglePayment_UITests: BTUITest {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-Integration:BraintreeDemoPayPalOneTimePaymentViewController")
        app.launch()
        app.buttons["PayPal one-time payment"].forceTapElement()
        sleep(2)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPayPal_singlePayment_receivesNonce() {
        let app = XCUIApplication()
        
        self.waitForElementToAppear(app.webViews.links["Proceed with Sandbox Purchase"])
        
        app.webViews.links["Proceed with Sandbox Purchase"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
    
    func testPayPal_singlePayment_cancelsSuccessfully() {
        let app = XCUIApplication()
        
        self.waitForElementToAppear(app.webViews.links["Cancel Sandbox Purchase"])
        
        app.webViews.links["Cancel Sandbox Purchase"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["PayPal one-time payment"])
        
        XCTAssertTrue(app.buttons["Cancelled"].exists);
    }
}

class BraintreePayPal_BillingAgreement_UITests: BTUITest {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-Integration:BraintreeDemoPayPalBillingAgreementViewController")
        app.launch()
        app.buttons["Billing Agreement with PayPal"].forceTapElement()
        sleep(2)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPayPal_billingAgreement_receivesNonce() {
        let app = XCUIApplication()
        
        self.waitForElementToAppear(app.webViews.links["Proceed with Sandbox Purchase"])
        
        app.webViews.links["Proceed with Sandbox Purchase"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists);
    }
    
    func testPayPal_billingAgreement_cancelsSuccessfully() {
        let app = XCUIApplication()
        
        self.waitForElementToAppear(app.webViews.links["Cancel Sandbox Purchase"])
        
        app.webViews.links["Cancel Sandbox Purchase"].forceTapElement()
        
        self.waitForElementToAppear(app.buttons["Billing Agreement with PayPal"])
        
        XCTAssertTrue(app.buttons["Cancelled"].exists);
    }
}
