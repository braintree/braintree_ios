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

        sleep(3)

        let webView = app.webViews.firstMatch
        XCTAssertTrue(webView.waitForExistence(timeout: 10), "WebView did not appear")

        let newUserTab = app.webViews.buttons["New user?"]
        newUserTab.forceTapElement()
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

        let stateField = app.textFields["State"]
        stateField.forceTapElement()
        stateField.typeText("CA")

        let zipCodeField = app.textFields["Zip Code"]
        zipCodeField.forceTapElement()
        zipCodeField.typeText("94588")

        let countryField = app.textFields["Country/Region, filters as you type, 219 items"]
        countryField.forceTapElement()
        countryField.typeText("United States of America")
        sleep(2)

//        let mobileNumber = app.textFields["Mobile Number We may send a one-time code to this number to verify it's you. Message and data rates may apply."]
        
//        let mobileNumber = app.textFields.containing(NSPredicate(format: "label CONTAINS[c] %@", "Mobile Number")).firstMatch
//        print(XCUIApplication().debugDescription)
//        mobileNumber.forceTapElement()
//        mobileNumber.typeText("864-275-2333")
//        sleep(2)

        let byContainsLabel = webView.textFields.containing(NSPredicate(format: "label CONTAINS[c] %@", "Mobile Number")).firstMatch

        let byExactLongLabel = webView.textFields["Mobile Number We may send a one-time code to this number to verify it's you. Message and data rates may apply."]

        // The placeholder often shows up as `value` when empty. Try that too.
        let byPlaceholderValue = webView.textFields.containing(
            NSPredicate(format: "value CONTAINS[c] %@", "Mobile Number")
        ).firstMatch

        // 4) Pick the first that exists
        let mobileFieldCandidates: [XCUIElement] = [byContainsLabel, byExactLongLabel, byPlaceholderValue]
        guard let mobileField = mobileFieldCandidates.first(where: { $0.exists }) else {
            XCTFail("Could not find Mobile Number field with any strategy")
            return
        }

        // 5) Ensure it’s visible/hittable. Scroll the webView if needed.
        func scrollIntoViewIfNeeded(_ element: XCUIElement, in scrollable: XCUIElement) {
            var attempts = 0
            while !element.isHittable && attempts < 6 {
                scrollable.swipeUp()
                attempts += 1
            }
        }

        scrollIntoViewIfNeeded(mobileField, in: webView)
        XCTAssertTrue(mobileField.waitForExistence(timeout: 5), "Mobile Number field never existed")
        mobileField.forceTapElement()
        mobileField.typeText("864-275-2333")

        // Dismiss keyboard if necessary
        if app.keyboards.keys["Done"].exists {
            app.keyboards.keys["Done"].tap()
        }

        app.keyboards.keys["Done"].tap()
        sleep(2)

        let emailAddressField = app.textFields["Email Address"]
        emailAddressField.forceTapElement()
        emailAddressField.typeText("joedoe@example.com")

        app.buttons["CONTINUE"].forceTapElement()
        sleep(2)

        app.buttons["USE RECOMMENDED ADDRESS"].forceTapElement()
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
//        self.waitForElementToAppear(app.buttons["Cancel and return to My App"])
//        app.buttons["Cancel and return to My App"].forceTapElement()
        let cancel = app.buttons.containing(NSPredicate(format: "label BEGINSWITH %@", "Cancel and return"))
        XCTAssertTrue(cancel.firstMatch.exists)
        cancel.firstMatch.forceTapElement()
        
        sleep(5)
        let canceled = app.buttons["User canceled."]
        XCTAssertTrue(canceled.waitForExistence(timeout: 10))
//        let errorTokenizingText = app.staticTexts["Error tokenizing Visa Checkout card: Visa Checkout flow was canceled by the user."]
//        XCTAssertTrue(errorTokenizingText.exists)
    }
}
