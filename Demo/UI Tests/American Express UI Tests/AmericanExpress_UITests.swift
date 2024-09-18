import XCTest

class AmericanExpress_UITests: XCTestCase {

    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-UITestHardcodedClientToken")
        app.launchArguments.append("-Integration:AmexViewController")
        app.launch()
    }

    func testValidCard_receivesRewardsBalance() {
        waitForElementToBeHittable(app.buttons["Valid card"])
        app.buttons["Valid card"].tap()
        sleep(2)

        XCTAssertTrue(app.buttons["45256433 Points, 316795.03 USD"].waitForExistence(timeout: 20))
    }

    func testInsufficientPointsCard_receivesErrorMessage() {
        waitForElementToBeHittable(app.buttons["Insufficient points card"])
        app.buttons["Insufficient points card"].tap()
        sleep(2)

        XCTAssertTrue(app.buttons["INQ2003: Not sufficient points in rewards account"].waitForExistence(timeout: 10))
    }

    func testIneligibleCard_receivesErrorMessage() {
        waitForElementToBeHittable(app.buttons["Ineligible card"])
        app.buttons["Ineligible card"].tap()
        sleep(2)

        XCTAssertTrue(app.buttons["INQ2002: Card is not eligible for the Program"].waitForExistence(timeout: 10))
    }
}
