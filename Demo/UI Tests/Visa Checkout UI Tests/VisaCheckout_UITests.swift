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
<<<<<<< Updated upstream
        let visaButton = app.buttons["Visa Checkout"]
        self.waitForElementToAppear(visaButton)
        self.waitForElementToBeHittable(visaButton)
        sleep(2)
        visaButton.doubleTap()
=======
        let visaButton = app.buttons["visaCheckoutButton"]
        let expirationDate = UITestDateGenerator.sharedInstance.futureDate()
        self.waitForElementToAppear(visaButton)
        self.waitForElementToBeHittable(visaButton)
        sleep(3)
        visaButton.tap()
>>>>>>> Stashed changes
        
        // Long delay to ensure animation completes to check signed in status
        sleep(3)

<<<<<<< Updated upstream
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
=======
        app.webViews.buttons["New user?"].forceTapElement()
        sleep(2)

        // Enter in Visa card information
        let cardNumberField = app.textFields["Card Number 15 to 16 digits Enter your card number here."]
        cardNumberField.forceTapElement()
        cardNumberField.typeText("4500600000000061")

        let expirationDateField = app.textFields["Expires M M / Y Y expiration date formats as you type"]
        expirationDateField.forceTapElement()

        let securityCodeField = app.textFields["Security Code Enter your card's security code here. The 3-digit code on the back of your card."]
        securityCodeField.forceTapElement()
        securityCodeField.typeText("123")
 
        app.buttons["CONTINUE"].forceTapElement()
        sleep(2)

        // Enter billing address
        let firstNameField = app.textFields["First Name"]
        firstNameField.forceTapElement()
        firstNameField.typeText("Joe")

        let lastNameField = app.textFields["Last Name"]
        lastNameField.forceTapElement()
        lastNameField.typeText("Doe")

        let addressLine1Field = app.textFields["Address Line 1 uses Google Autofill"]
        addressLine1Field.forceTapElement()
        addressLine1Field.typeText("123 Main Street")

        let cityField = app.textFields["City"]
        cityField.forceTapElement()
        cityField.typeText("Pleasanton")

        let stateField = app.textFields["State"]
        stateField.forceTapElement()
        stateField.typeText("CA")

        let zipCodeField = app.textFields["Zip Code"]
        zipCodeField.forceTapElement()
        zipCodeField.typeText("94566")

        let mobileNumber = app.textFields["Mobile Number We may send a one-time code to this number to verify it's you. Message and data rates may apply."]
        mobileNumber.forceTapElement()
        mobileNumber.typeText("864-275-2333")

        let emailAddressField = app.textFields["Email Address"]
        emailAddressField.forceTapElement()
        emailAddressField.typeText("joedoe@example.com")

        app.buttons["CONTINUE"].forceTapElement()
        sleep(2)

        app.buttons["USE RECOMMENDED ADDRESS"].forceTapElement()
>>>>>>> Stashed changes
        sleep(2)

        app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Sign in to visa checkout")).forceTapElement()
        sleep(2)

<<<<<<< Updated upstream
        app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Continue")).forceTapElement()
        sleep(2)
        
=======
>>>>>>> Stashed changes
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists)
    }

    func testVisaCheckout_returnToApp_whenCanceled() {
<<<<<<< Updated upstream
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
=======
        let visaButton = app.buttons["visaCheckoutButton"]
        self.waitForElementToAppear(visaButton)
        self.waitForElementToBeHittable(visaButton)
        sleep(2)
        visaButton.tap()

        let cancel = app.webViews.buttons["Cancel and return to My App"]
        cancel.forceTapElement()
        XCTAssertTrue(cancel.waitForExistence(timeout: 10))
        sleep(2)

        let canceled = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Error tokenizing Visa Checkout card"))

        XCTAssertTrue(canceled.waitForExistence(timeout: 10))
        self.waitForElementToAppear(app.staticTexts["Error tokenizing Visa Checkout card"])
        XCTAssertTrue(app.staticTexts["Error tokenizing Visa Checkout card"].exists)
>>>>>>> Stashed changes
    }
}
