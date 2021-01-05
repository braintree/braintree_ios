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

        waitForElementToAppear(app.buttons["Valid card"])
    }

    func testValidCard_receivesRewardsBalance() {
        app.buttons["Valid card"].tap()
        waitForElementToAppear(app.buttons["45256433 Points, 316795.03 USD"], timeout: 10)
    }

    func testInsufficientPointsCard_receivesErrorMessage() {
        app.buttons["Insufficient points card"].tap()
        sleep(2)

        waitForElementToAppear(app.buttons["INQ2003: Not sufficient points in rewards account"], timeout: 10)
    }

    func testIneligibleCard_receivesErrorMessage() {
        app.buttons["Ineligible card"].tap()
        waitForElementToAppear(app.buttons["INQ2002: Card is not eligible for the Program"], timeout: 10)
    }
}
