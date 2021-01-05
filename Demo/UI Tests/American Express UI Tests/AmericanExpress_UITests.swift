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

        waitForElementToAppear(app.buttons["Get rewards balance"])
    }

    func testGetRewardsBalance_receivesRewardsBalance() {
        app.buttons["Get rewards balance"].tap()
        sleep(2)

        XCTAssertTrue(app.buttons["Amex - received rewards balance"].exists);
    }
}
