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

        waitForElementToAppear(demoApp.buttons["Venmo (custom button)"])
    }

    func testTokenizeVenmo_whenSignInSuccessful_returnsNonce() {
        demoApp.buttons["Venmo (custom button)"].tap()

        waitForElementToAppear(mockVenmo.buttons["SUCCESS"])
        mockVenmo.buttons["SUCCESS"].tap()

        waitForElementToAppear(demoApp.buttons["Got a nonce. Tap to make a transaction."])
        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].exists);
    }

    func testTokenizeVenmo_whenErrorOccurs_returnsError() {
        demoApp.buttons["Venmo (custom button)"].tap()

        waitForElementToAppear(mockVenmo.buttons["ERROR"])
        mockVenmo.buttons["ERROR"].tap()

        // Add check for Settings button to debug error message not being found in CI
        waitForElementToAppear(demoApp.buttons["Settings"])

        waitForElementToAppear(demoApp.buttons["An error occurred during the Venmo flow"])
        XCTAssertTrue(demoApp.buttons["An error occurred during the Venmo flow"].exists);
    }

    func testTokenizeVenmo_whenUserCancels_returnsCancel() {
        demoApp.buttons["Venmo (custom button)"].tap()

        waitForElementToAppear(mockVenmo.buttons["Cancel"])
        mockVenmo.buttons["Cancel"].tap()

        waitForElementToAppear(demoApp.buttons["Canceled 🔰"])
        XCTAssertTrue(demoApp.buttons["Canceled 🔰"].exists);
    }
}
