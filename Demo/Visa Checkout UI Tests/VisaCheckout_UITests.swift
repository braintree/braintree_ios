import XCTest

class BraintreeVisaCheckout_UITests: XCTestCase {

    // swiftlint:disable implicitly_unwrapped_optional
    var app: XCUIApplication!
    // swiftlint:enable implicitly_unwrapped_optional
    
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

    func testVisaCheckout_withSuccess_recievesNonce() {
        let visaButton = app.buttons["visaCheckoutButton"]
        let expirationDate = UITestDateGenerator.sharedInstance.futureDate()
        self.waitForElementToAppear(visaButton)
        self.waitForElementToBeHittable(visaButton)
        sleep(3)
        visaButton.tap()
        
        // Long delay to ensure animation completes to check signed in status
        sleep(3)

        app.webViews.buttons["New user?"].forceTapElement()
        sleep(2)

        // Enter in Visa card information
        let cardNumberField = app.textFields["Card Number 15 to 16 digits Enter your card number here."]
        cardNumberField.forceTapElement()
        cardNumberField.typeText("4500600000000061")

        let expirationDateField = app.textFields["Expires M M / Y Y expiration date formats as you type"]
        expirationDateField.forceTapElement()
        expirationDateField.typeText(expirationDate)

        let securityCodeField = app.textFields.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Security Code"))
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

        let mobileNumber = app.textFields.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Mobile Number"))
        mobileNumber.forceTapElement()
        mobileNumber.typeText("864-275-2333")

        let emailAddressField = app.textFields["Email Address"]
        emailAddressField.forceTapElement()
        emailAddressField.typeText("joedoe@example.com")

        app.buttons["CONTINUE"].forceTapElement()
        sleep(2)

        app.buttons["USE RECOMMENDED ADDRESS"].forceTapElement()
        sleep(2)

        app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Continue")).forceTapElement()
        sleep(2)
        
        self.waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists)
    }

    func testVisaCheckout_returnToApp_whenCanceled() {
        let visaButton = app.buttons["visaCheckoutButton"]
        self.waitForElementToAppear(visaButton)
        self.waitForElementToBeHittable(visaButton)
        sleep(2)
        visaButton.doubleTap()

        sleep(2)
        self.waitForElementToAppear(app.buttons["Cancel and return to My App"])
        app.buttons["Cancel and return to My App"].forceTapElement()
    }
}
