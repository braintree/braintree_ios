import XCTest

class BraintreeVisaCheckout_UITests: XCTestCase {

    var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:VisaCheckoutViewController")
        app.launch()
        sleep(2)
    }

    func testVisaCheckout_whenNewCardAndBillingAddressAddedSuccessfully_returnToApp() {
        let visaButton = app.buttons["visaCheckoutButton"]
        let continueButton = app.buttons["CONTINUE"]
        let expirationDate = UITestDateGenerator.sharedInstance.futureDate()

        XCTAssertTrue(visaButton.waitForExistence(timeout: 60))
        visaButton.forceTapElement()

        XCTAssertTrue(app.webViews.buttons["New user?"].waitForExistence(timeout: 10))
        app.webViews.buttons["New user?"].forceTapElement()

        app.enterVisaCardDetailsWith(cardNumber: "4012000033330026", expirationDate: expirationDate)
 
        XCTAssertTrue(continueButton.waitForExistence(timeout: 60))
        continueButton.forceTapElement()

        app.enterBillingAddress(
            firstName: "Joe",
            lastName: "Doe",
            addressLine1: "123 Main Street",
            state: "CA",
            zipCode: "94533",
            mobileNumber: "8642752333",
            emailAddress: "joedoe@example.com"
        )
    
        XCTAssertTrue(app.buttons["CONTINUE"].waitForExistence(timeout: 10))
        continueButton.forceTapElement()
        sleep(5)

        handleNewUserScenerios(continueButton: continueButton)

        app.staticTexts["ADD DELIVERY ADDRESS"].waitForExistence(timeout: 30)
        app.enterBillingAddress(addressLine1: "123 Main Street", state: "CA", zipCode: "94533", mobileNumber: "8642752333")
        XCTAssertTrue(app.buttons["CONTINUE"].waitForExistence(timeout: 30))
        continueButton.forceTapElement()

        XCTAssertTrue(app.buttons["CONTINUE AS GUEST"].waitForExistence(timeout: 10))
        app.buttons["CONTINUE AS GUEST"].forceTapElement()

        XCTAssertTrue(visaButton.waitForExistence(timeout: 60))
    }

    func testVisaCheckout_whenCanceled_returnToApp() {
        let visaButton = app.buttons["visaCheckoutButton"]

        XCTAssertTrue(visaButton.waitForExistence(timeout: 60))
        visaButton.forceTapElement()

        XCTAssertTrue(app.buttons["Cancel and return to My App"].waitForExistence(timeout: 30))

        /// Taps the middle of the cancel button to avoid issues where the "X" is not tappable
        let closeButtonCoordinate = app.buttons["Cancel and return to My App"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        closeButtonCoordinate.doubleTap()

        XCTAssertTrue(visaButton.waitForExistence(timeout: 30))
    }

    // MARK: - Helper Function

    /// This function handles the different flows that can occur for new users
    private func handleNewUserScenerios(continueButton: XCUIElement) {
        if app.staticTexts["VERIFY YOUR ADDRESS"].waitForExistence(timeout: 30) {
            let recommendedButton = app.buttons["USE RECOMMENDED ADDRESS"]
            XCTAssertTrue(recommendedButton.waitForExistence(timeout: 10))
            recommendedButton.forceTapElement()
        }

        let welcomeBackText = app.staticTexts["Welcome Back"]
        if welcomeBackText.waitForExistence(timeout: 30) {
            let continueAsGuest = app.buttons["CONTINUE AS GUEST"]
            XCTAssertTrue(continueAsGuest.waitForExistence(timeout: 10))
            continueAsGuest.forceTapElement()
        }
    }
}
