import XCTest

final class PayLaterButton_UITests: XCTestCase {

    var app = XCUIApplication()
    var springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-MockedPayPalTokenizationKey")
        app.launchArguments.append("-Integration:UIComponentsViewController")

        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"
        app.launch()

        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    func testPayLaterButton_allVariantsRender() {
        let button = app.buttons["PayPal Pay Later"]
        // Pickers appear in demo order: Venmo (0), PayPal (1), Pay Later (2)
        let colorPicker = app.segmentedControls.element(boundBy: 2)

        XCTAssertTrue(button.waitForExistence(timeout: 5), "Pay Later button should exist")

        for color in ["Blue", "Black", "White"] {
            colorPicker.buttons[color].tap()

            XCTAssertTrue(colorPicker.buttons[color].isSelected, "\(color) should be selected")
            XCTAssertTrue(button.exists, "Pay Later button should render in \(color)")
            XCTAssertTrue(button.isHittable, "Pay Later button should be hittable in \(color)")
        }
    }

    func testPayLaterButton_disabledInLoadingState() {
        let button = app.buttons["PayPal Pay Later"]

        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertTrue(button.isEnabled, "Button should be enabled initially")
        XCTAssertEqual(button.identifier, "ready", "Button should be ready before being tapped")

        button.tap()

        XCTAssertFalse(button.isEnabled, "Button should be disabled after tap")
        XCTAssertEqual(button.identifier, "loading", "Loading identifier should appear when in loading state")
    }

    func testPayLaterButton_tapLaunchesPayPalFlow() {
        app.buttons["PayPal Pay Later"].tap()

        XCTAssertTrue(
            springboard.buttons["Continue"].waitForExistence(timeout: 20.0),
            "Auth dialog 'Continue' button did not appear"
        )
        springboard.buttons["Continue"].tap()

        let webviewElementsQuery = app.webViews.element.otherElements

        self.waitForElementToAppear(webviewElementsQuery.links["Proceed with Sandbox Purchase"])

        webviewElementsQuery.links["Proceed with Sandbox Purchase"].forceTapElement()

        XCTAssertTrue(app.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 2))
    }
}
