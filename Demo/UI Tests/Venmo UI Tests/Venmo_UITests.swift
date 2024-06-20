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
        demoApp.launchArguments.append("-Integration:VenmoViewController")
        demoApp.launch()
        
        waitForElementToBeHittable(demoApp.buttons["Venmo"])
        waitForElementToBeHittable(demoApp.buttons["Venmo (with ECD options)"])
    }
    
    func testTokenizeVenmo_whenSignInSuccessfulWithPaymentContext_returnsNonce() {
        demoApp.buttons["Venmo"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"])
        mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"].tap()

        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 15))
    }
    
    func testTokenizeVenmo_withECDOptions_whenSignInSuccessfulWithPaymentContext_returnsNonce() {
        demoApp.buttons["Venmo (with ECD options)"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"])
        mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"].tap()

        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 15))
    }
    
    func testTokenizeVenmo_whenSignInSuccessfulWithoutPaymentContext_returnsNonce() {
        demoApp.buttons["Venmo"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["SUCCESS WITHOUT PAYMENT CONTEXT"])
        mockVenmo.buttons["SUCCESS WITHOUT PAYMENT CONTEXT"].tap()

        XCTAssertTrue(demoApp.buttons["Got a nonce. Tap to make a transaction."].waitForExistence(timeout: 15))
    }

    func testTokenizeVenmo_whenErrorOccurs_returnsError() {
        demoApp.buttons["Venmo"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["ERROR"])
        mockVenmo.buttons["ERROR"].tap()

        XCTAssertTrue(demoApp.buttons["An error occurred during the Venmo flow"].waitForExistence(timeout: 15))
    }

    func testTokenizeVenmo_whenUserCancels_returnsCancel() {
        demoApp.buttons["Venmo"].tap()
        
        waitForElementToBeHittable(mockVenmo.buttons["Cancel"])
        mockVenmo.buttons["Cancel"].tap()

        XCTAssertTrue(demoApp.buttons["Canceled 🔰"].waitForExistence(timeout: 15))
    }
}
