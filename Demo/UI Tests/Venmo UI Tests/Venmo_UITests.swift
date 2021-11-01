import XCTest

class Venmo_UITests: XCTestCase {

    var demoApp: XCUIApplication!
    var mockVenmo: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        mockVenmo = XCUIApplication(bundleIdentifier: "com.braintreepayments.MockVenmo")
        mockVenmo.activate()

        demoApp = XCUIApplication(bundleIdentifier: "com.braintreepayments.Demo")
        demoApp.launchArguments.append("-EnvironmentSandbox")
        demoApp.launchArguments.append("-ClientToken")
        demoApp.launchArguments.append("-Integration:BraintreeDemoCustomVenmoButtonViewController")
        demoApp.launch()

        demoApp.buttons["Venmo (custom button)"].tap()
    }

    func testTokenizeVenmo_whenSignInSuccessful_returnsNonce() {
        mockVenmo.buttons["SUCCESS"].tap()

        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 2))
    }

    func testTokenizeVenmo_whenErrorOccurs_returnsError() {
        mockVenmo.buttons["ERROR"].tap()

        XCTAssertTrue(demoApp.buttons["An error occurred during the Venmo flow"].waitForExistence(timeout: 2))
    }

    func testTokenizeVenmo_whenUserCancels_returnsCancel() {
        mockVenmo.buttons["Cancel"].tap()

        XCTAssertTrue(demoApp.buttons["Canceled 🔰"].exists)
    }
}
