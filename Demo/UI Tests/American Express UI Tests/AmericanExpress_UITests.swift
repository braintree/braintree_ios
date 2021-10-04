import XCTest

class AmericanExpress_UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoAmexViewController")
        app.launch()
    }

    func testValidCard_receivesRewardsBalance() {
        _ = app.buttons["Valid card"].waitForExistence(timeout: 20)
        app.buttons["Valid card"].tap()
        waitForElementToAppear(app.buttons["45256433 Points, 316795.03 USD"], timeout: 20)
    }

    func testInsufficientPointsCard_receivesErrorMessage() {
        _ = app.buttons["Insufficient points card"].waitForExistence(timeout: 20)
        app.buttons["Insufficient points card"].tap()
        sleep(2)

        waitForElementToAppear(app.buttons["INQ2003: Not sufficient points in rewards account"], timeout: 20)
    }

    func testIneligibleCard_receivesErrorMessage() {
        _ = app.buttons["Ineligible card"].waitForExistence(timeout: 20)
        app.buttons["Ineligible card"].tap()
        waitForElementToAppear(app.buttons["INQ2002: Card is not eligible for the Program"], timeout: 20)
    }
}
