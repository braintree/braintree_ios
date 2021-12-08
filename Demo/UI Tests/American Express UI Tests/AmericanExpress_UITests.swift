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
        app.buttons["Valid card"].tap()
        XCTAssertTrue(app.buttons["45256433 Points, 316795.03 USD"].waitForExistence(timeout: 10))
    }

    func testInsufficientPointsCard_receivesErrorMessage() {
        app.buttons["Insufficient points card"].tap()
        sleep(2)

        XCTAssertTrue(app.buttons["INQ2003: Not sufficient points in rewards account"].waitForExistence(timeout: 10))
    }

    func testIneligibleCard_receivesErrorMessage() {
        app.buttons["Ineligible card"].tap()

        XCTAssertTrue(app.buttons["INQ2002: Card is not eligible for the Program"].waitForExistence(timeout: 10))
    }
}
