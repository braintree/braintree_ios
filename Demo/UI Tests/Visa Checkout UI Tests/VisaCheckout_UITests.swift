import XCTest

class BraintreeVisaCheckout_UITests: XCTestCase {
        
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:VisaCheckoutViewController")
        app.launch()
        sleep(2)
    }

    // TODO: - Get new account credentials for this UI test / manual testing.
    func testPendVisaCheckout_withSuccess_recievesNonceNew() {
        let visaButton = app.buttons["Visa Checkout"]
        self.waitForElementToAppear(visaButton)
        self.waitForElementToBeHittable(visaButton)
        sleep(2)
        visaButton.doubleTap()
        
        // Long delay to ensure animation completes to check signed in status
        sleep(3)

        app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Sign in to visa checkout")).forceTapElement()
        sleep(2)

        app.staticTexts["Email or Mobile Number"].forceTapElement()
        sleep(2)

        app.webViews.otherElements["main"].textFields.element(boundBy: 0).typeText("no-reply-visa-checkout@getbraintree.com")
        app.buttons["Done"].tap()
        sleep(2)

        app.staticTexts["Password"].forceTapElement()
        sleep(2)

        app.webViews.otherElements["main"].secureTextFields.element(boundBy: 0).typeText("12345678")
        app.buttons["Done"].tap()
        sleep(2)

        app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Sign in to visa checkout")).forceTapElement()
        sleep(2)

        app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Continue")).forceTapElement()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists)
    }

    func testVisaCheckout_returnToApp_whenCanceled() {
        let visaButton = app.otherElements[]
        self.waitForElementToAppear(visaButton)
        self.waitForElementToBeHittable(visaButton)
        sleep(2)
        visaButton.doubleTap()

        sleep(2)
        self.waitForElementToAppear(app.buttons["Cancel and return to My App"])
        app.buttons["Cancel and return to My App"].forceTapElement()

        self.waitForElementToAppear(app.buttons["User canceled."])
        XCTAssertTrue(app.buttons["User canceled."].exists)
    }
}
