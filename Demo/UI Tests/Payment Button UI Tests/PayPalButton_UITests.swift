import XCTest

final class PayPalButton_UITests: XCTestCase {

    var app = XCUIApplication()
    var springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-MockedPayPalTokenizationKey")
        app.launchArguments.append("-Integration:PaymentButtonViewController")

        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"
        app.launch()

        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    func testPayPal_button_disabledInLoadingState() {
        let button = app.buttons["Pay with PayPal"]

        XCTAssertTrue(button.isEnabled, "Button should be enabled initially")
        XCTAssertTrue(app.buttons["ready"].exists, "Button should be ready before being tapped")

        button.tap()

        XCTAssertFalse(button.isEnabled, "Button should be disabled after tap")

        XCTAssertTrue(app.buttons["loading"].waitForExistence(timeout: 2), "Loading identifier should appear when in loading state")
    }

    func testPayPalButton_tapLaunchesPayPalFlow() {
        app.buttons["Pay with PayPal"].tap()

        _ = springboard.buttons["Continue"].waitForExistence(timeout: 20.0)
        springboard.buttons["Continue"].tap()

        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 2))
    }
}
