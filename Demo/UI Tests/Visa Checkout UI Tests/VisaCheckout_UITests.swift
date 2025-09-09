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
    }

    func testVisaCheckout_whenAddCardAndBillingAddressSuccessful_recievesNonce() {
        let visaButton = app.buttons["visaCheckoutButton"]
        let continueButton = app.buttons["CONTINUE"]
        let expirationDate = UITestDateGenerator.sharedInstance.futureDate()

        XCTAssertTrue(visaButton.waitForExistence(timeout: 10))
        visaButton.forceTapElement()

        XCTAssertTrue(app.webViews.buttons["New user?"].waitForExistence(timeout: 10))
        app.webViews.buttons["New user?"].forceTapElement()

        app.enterVisaCardDetailsWith(cardNumber: "4012000033330026", expirationDate: expirationDate)
 
        waitForElementToAppear(continueButton)
        continueButton.forceTapElement()

        app.enterBillingAddress(
            firstName: "Joe",
            lastName: "Doe",
            addressLine1: "123 Main Street",
            city: "Pleasanton",
            state: "CA",
            zipCode: "94533",
            mobileNumber: "8642752333",
            emailAddress: "joedoe@example.com"
        )

        waitForElementToAppear(continueButton)
        continueButton.forceTapElement()

        handleVerifyYourAddress()
        handleContinueAsGuest()
        handleAddDeliveryAddress(continueButton: continueButton)

        XCTAssertTrue(app.buttons["CONTINUE AS GUEST"].waitForExistence(timeout: 10))
        app.buttons["CONTINUE AS GUEST"].forceTapElement()

        XCTAssertTrue(visaButton.waitForExistence(timeout: 30))
    }

    func testVisaCheckout_whenCanceled_returnToApp() {
        let visaButton = app.buttons["visaCheckoutButton"]
        waitForElementToAppear(visaButton)
        visaButton.forceTapElement()

        XCTAssertTrue(app.buttons["Cancel and return to My App"].waitForExistence(timeout: 30))

        /// Taps the middle of the cancel button to avoid issues where the "X" is not tappable
        let closeButtonCoordinate = app.buttons["Cancel and return to My App"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        closeButtonCoordinate.tap()

        XCTAssertTrue(visaButton.waitForExistence(timeout: 30))
    }

    // MARK: - Helper Functions

    private func handleVerifyYourAddress() {
        if app.staticTexts["VERIFY YOUR ADDRESS"].waitForExistence(timeout: 5) {
            let recommendedButton = app.buttons["USE RECOMMENDED ADDRESS"]
            XCTAssertTrue(recommendedButton.waitForExistence(timeout: 10))
            recommendedButton.forceTapElement()
        }
    }

    private func handleContinueAsGuest() {
        let welcomeBack = app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", "Welcome Back")).firstMatch
        if welcomeBack.exists {
            let continueAsGuest = app.buttons["CONTINUE AS GUEST"]
            XCTAssertTrue(continueAsGuest.waitForExistence(timeout: 10))
            continueAsGuest.forceTapElement()
        }
    }

    private func handleAddDeliveryAddress(continueButton: XCUIElement) {
        if app.staticTexts["ADD DELIVERY ADDRESS"].waitForExistence(timeout: 5) {
            app.enterBillingAddress(addressLine1: "123 Main Street", city: "Pleasanton", state: "CA", zipCode: "94533")
            continueButton.forceTapElement()
        }
    }
}
