import XCTest

class Venmo_UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:BraintreeDemoCustomVenmoButtonViewController")
        app.launch()

        waitForElementToAppear(app.buttons["Venmo (custom button)"])
    }

    func testTokenizeVenmo_returnsErrorWhenVenmoAppNotInstalled() {
        app.buttons["Venmo (custom button)"].tap()
        sleep(2)

        XCTAssertTrue(app.buttons["The Venmo app is not installed on this device, or it is not configured or available for app switch."].exists);
    }
}
