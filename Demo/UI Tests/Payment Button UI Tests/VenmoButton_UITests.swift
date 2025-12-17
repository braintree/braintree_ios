import XCTest

final class VenmoButton_UITests: XCTestCase {

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

    func testVenmo_button_disabledInLoadingState() {
        let button = app.buttons["Pay with Venmo"]

        XCTAssertTrue(button.isEnabled, "Button should be enabled initially")
        XCTAssertTrue(app.buttons["ready"].exists, "Button should be ready before being tapped")

        button.tap()

        XCTAssertFalse(button.isEnabled, "Button should be disabled after tap")

        XCTAssertTrue(app.buttons["loading"].waitForExistence(timeout: 2), "Loading identifier should appear when in loading state")
    }

    func testVenmo_button_tapLaunchesVenmoFlow() {
        app.buttons["Pay with Venmo"].tap()
        _ = springboard.buttons["Return to SDK Demo"].waitForExistence(timeout: 3.0)

        XCTAssertNotNil(app.webViews.element.otherElements)

        springboard.buttons["Return to SDK Demo"].tap()

        XCTAssertTrue(app.buttons["Pay with Venmo"].waitForExistence(timeout: 2))
    }
}
