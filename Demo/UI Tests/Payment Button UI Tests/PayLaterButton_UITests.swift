import XCTest

final class PayLaterButton_UITests: XCTestCase {

    var app = XCUIApplication()
    var springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    // Must match the on-screen order of the buttons in the demo
    enum Variant: Int, CaseIterable {
        case blue = 0, black, white
    }

    private let payLaterLabel = "PayPal Pay Later"

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-MockedPayPalTokenizationKey")
        app.launchArguments.append("-Integration:UIComponentsViewController")

        app.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"
        app.launch()

        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    private var payLaterButtons: XCUIElementQuery {
        app.buttons.matching(NSPredicate(format: "label == %@", payLaterLabel))
    }

    private func payLaterButton(_ variant: Variant) -> XCUIElement {
        payLaterButtons.element(boundBy: variant.rawValue)
    }

    // MARK: - Rendering

    func testPayLaterButton_allVariantsRender() {
        XCTAssertTrue(payLaterButton(.blue).waitForExistence(timeout: 5))
        XCTAssertEqual(
            payLaterButtons.count,
            Variant.allCases.count,
            "Expected one Pay Later button per color variant"
        )

        for variant in Variant.allCases {
            let button = payLaterButton(variant)
            XCTAssertTrue(button.exists, "\(variant) should exist")
            XCTAssertTrue(button.isHittable, "\(variant) should be hittable")
            XCTAssertTrue(button.isEnabled, "\(variant) should be enabled initially")
            XCTAssertEqual(button.identifier, "ready", "\(variant) should be in ready state")
        }
    }

    // MARK: - Loading state on tap

    func testPayLaterButton_blue_disabledInLoadingState()  { assertDisabledInLoadingState(.blue) }
    func testPayLaterButton_black_disabledInLoadingState() { assertDisabledInLoadingState(.black) }
    func testPayLaterButton_white_disabledInLoadingState() { assertDisabledInLoadingState(.white) }

    private func assertDisabledInLoadingState(_ variant: Variant) {
        let button = payLaterButton(variant)
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertTrue(button.isEnabled, "\(variant) should be enabled before tap")

        button.tap()

        XCTAssertFalse(button.isEnabled, "\(variant) should be disabled after tap")
        XCTAssertEqual(button.identifier, "loading", "\(variant) should be in loading state after tap")
    }

    // MARK: - Tap launches PayPal flow

    func testPayLaterButton_blue_tapLaunchesPayPalFlow()  { assertTapLaunchesFlow(.blue) }
    func testPayLaterButton_black_tapLaunchesPayPalFlow() { assertTapLaunchesFlow(.black) }
    func testPayLaterButton_white_tapLaunchesPayPalFlow() { assertTapLaunchesFlow(.white) }

    private func assertTapLaunchesFlow(_ variant: Variant) {
        let button = payLaterButton(variant)
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()

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
