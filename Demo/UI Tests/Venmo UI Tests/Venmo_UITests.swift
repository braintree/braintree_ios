import XCTest

class Venmo_UITests: XCTestCase {

    // swiftlint:disable implicitly_unwrapped_optional
    var demoApp: XCUIApplication!
    var mockVenmo: XCUIApplication!
    // swiftlint:enable implicitly_unwrapped_optional

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        mockVenmo = XCUIApplication(bundleIdentifier: "com.braintreepayments.MockVenmo")
        mockVenmo.activate()

        demoApp = XCUIApplication(bundleIdentifier: "com.braintreepayments.Demo")
        demoApp.launchArguments.append("-EnvironmentSandbox")
        demoApp.launchArguments.append("-ClientToken")
        demoApp.launchArguments.append("-Integration:VenmoViewController")
        demoApp.launch()
    }
    
    func testTokenizeVenmo_whenSignInSuccessfulWithPaymentContext_returnsNonce() {
        waitForElementToBeHittable(demoApp.buttons["Venmo"])
        demoApp.buttons["Venmo"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"])
        mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"].tap()

        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 30))
    }
    
    func testTokenizeVenmo_withECDOptions_whenSignInSuccessfulWithPaymentContext_returnsNonce() {
        waitForElementToBeHittable(demoApp.buttons["Venmo (with ECD options)"])
        demoApp.buttons["Venmo (with ECD options)"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"])
        mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"].tap()

        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 30))
    }
    
    func testTokenizeVenmo_whenSignInSuccessfulWithoutPaymentContext_returnsNonce() {
        waitForElementToBeHittable(demoApp.buttons["Venmo"])
        demoApp.buttons["Venmo"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["SUCCESS WITHOUT PAYMENT CONTEXT"])
        mockVenmo.buttons["SUCCESS WITHOUT PAYMENT CONTEXT"].tap()

        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 30))
    }

    func testTokenizeVenmo_whenErrorOccurs_returnsError() {
        waitForElementToBeHittable(demoApp.buttons["Venmo"])
        demoApp.buttons["Venmo"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["ERROR"])
        mockVenmo.buttons["ERROR"].tap()

        XCTAssertTrue(demoApp.buttons["An error occurred during the Venmo flow"].waitForExistence(timeout: 30))
    }

    func testTokenizeVenmo_whenUserCancels_returnsCancel() {
        waitForElementToBeHittable(demoApp.buttons["Venmo"])
        demoApp.buttons["Venmo"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["Cancel"])
        mockVenmo.buttons["Cancel"].tap()

        XCTAssertTrue(demoApp.buttons["Canceled 🔰"].waitForExistence(timeout: 30))
    }
}
