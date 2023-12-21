import XCTest
import BraintreePayPalMessaging

final class PayPalMessaging_Success_UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-UITestHardcodedClientToken")
        app.launchArguments.append("-Integration:PayPalMessagingViewController")
        app.launch()
    }

    func testStart_withValidRequest_firesDelegates() {
        XCTAssertTrue(app.buttons["DELEGATE: didAppear fired"].waitForExistence(timeout: 10))

        let expectedButtonText = "PayPal - Pay monthly for purchases of $199.00-$10,000.00. Learn more"
        waitForElementToBeHittable(app.buttons[expectedButtonText])
        app.buttons[expectedButtonText].tap()
        sleep(2)

        app.buttons["PayPal Learn More Modal Close"].tap()
        sleep(2)

        XCTAssertTrue(app.buttons["DELEGATE: didSelect fired"].waitForExistence(timeout: 10))
    }
}

final class PayPalMessaging_Failure_UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-MockedPayPalTokenizationKey")
        app.launchArguments.append("-Integration:PayPalMessagingViewController")
        app.launch()
    }

    func testStart_withInvalidTokenizationKey_firesErrorDelegate() {
        let expectedErrorText = "DELEGATE: onError fired with Could not find PayPal client ID in Braintree configuration."
        XCTAssertTrue(app.buttons[expectedErrorText].waitForExistence(timeout: 10))
    }
}
