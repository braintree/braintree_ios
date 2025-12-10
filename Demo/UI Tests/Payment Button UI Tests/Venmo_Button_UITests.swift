import XCTest

final class Venmo_Button_UITests: XCTestCase {


    var app = XCUIApplication()
    var springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:PaymentButtonsViewController")

        // Disable animations for more reliable tests
        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"
        app.launch()

        app.buttons["Pay with Venmo"].tap()

        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    func testVenmo_button_tapDirectsToVenmo() {
        _ = springboard.buttons["Return to SDK Demo"].waitForExistence(timeout: 3.0)
        springboard.buttons["Return to SDK Demo"].tap()

        XCTAssertTrue(app.buttons["Pay with Venmo"].waitForExistence(timeout: 2))
    }
}
