import XCTest

final class Venmo_Button_UITests: XCTestCase {

    var app = XCUIApplication()
    var springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-ClientToken")
        app.launchArguments.append("-Integration:PaymentButtonViewController")

        // Disable animations for more reliable tests
        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"
        app.launch()

        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    // loading test - starts w/ loading, then ends without

    // tests that it can onyl be tapped once - disabled after first tap

    func testVenmo_button_loadingState() {
        XCTAssertTrue(app.buttons["Pay with Venmo"].isEnabled)

        app.buttons["Pay with Venmo"].tap()

        XCTAssertFalse(app.buttons["Pay with Venmo"].isEnabled)
        // assert loading status

    }

    func testVenmo_button_tapLaunchesVenmoFlow() {
        app.buttons["Pay with Venmo"].tap()
        _ = springboard.buttons["Return to SDK Demo"].waitForExistence(timeout: 3.0)

        XCTAssertNotNil(app.webViews.element.otherElements)

        springboard.buttons["Return to SDK Demo"].tap()

        XCTAssertTrue(app.buttons["Pay with Venmo"].waitForExistence(timeout: 2))
    }
}
