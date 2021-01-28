import XCTest

class Card_UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-Integration:BraintreeDemoCardTokenizationViewController")
    }

    func testTokenizeCard_whenCardHasValidationDisabled_andCardIsInvalid_tokenizesSuccessfully() {
        app.launchArguments.append("-TokenizationKey")
        app.launch()

        waitForElementToAppear(app.buttons["Autofill Invalid Card"])
        app.buttons["Autofill Invalid Card"].tap()

        // Toggle "Validate card" off
        app.switches.firstMatch.tap()

        waitForElementToAppear(app.buttons["Submit"])
        app.buttons["Submit"].tap()

        waitForElementToAppear(app.buttons["Got a nonce. Tap to make a transaction."])
        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].exists)
    }

    func testTokenizeCard_whenCardHasValidationEnabled_andCardIsInvalid_failsWithValidationError() {
        app.launchArguments.append("-ClientToken")
        app.launch()

        waitForElementToAppear(app.buttons["Autofill Invalid Card"])
        app.buttons["Autofill Invalid Card"].tap()

        waitForElementToAppear(app.buttons["Submit"])
        app.buttons["Submit"].tap()

        waitForElementToAppear(app.buttons["Input is invalid"])
        XCTAssertTrue(app.buttons["Input is invalid"].exists)
    }
}
