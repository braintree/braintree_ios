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

        waitForElementToBeHittable(demoApp.buttons["Venmo (custom button)"])
        demoApp.buttons["Venmo (custom button)"].tap()
    }
    
    func testTokenizeVenmo_whenSignInSuccessfulWithPaymentContext_returnsNonce() {
        waitForElementToBeHittable(mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"])
        mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"].tap()

        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 15))
    }
    
    func testTokenizeVenmo_whenSignInSuccessfulWithoutPaymentContext_returnsNonce() {
        waitForElementToBeHittable(mockVenmo.buttons["SUCCESS WITHOUT PAYMENT CONTEXT"])
        mockVenmo.buttons["SUCCESS WITHOUT PAYMENT CONTEXT"].tap()

        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 15))
    }

    func testTokenizeVenmo_whenErrorOccurs_returnsError() {
        waitForElementToBeHittable(mockVenmo.buttons["ERROR"])
        mockVenmo.buttons["ERROR"].tap()

        XCTAssertTrue(demoApp.buttons["An error occurred during the Venmo flow"].waitForExistence(timeout: 15))
    }

    func testTokenizeVenmo_whenUserCancels_returnsCancel() {
        waitForElementToBeHittable(mockVenmo.buttons["Cancel"])
        mockVenmo.buttons["Cancel"].tap()

        XCTAssertTrue(demoApp.buttons["Canceled 🔰"].waitForExistence(timeout: 15))
    }
}
