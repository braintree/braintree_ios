import XCTest
import BraintreePayPalMessaging

final class PayPalMessaging_Success_UITests: XCTestCase {

    // swiftlint:disable:next implicitly_unwrapped_optional
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
        XCTAssertTrue(app.buttons["DELEGATE: didAppear fired"].waitForExistence(timeout: 30))

        let expectedButtonText = "PayPal - Pay monthly for purchases of $199-$10,000. Learn more"
        waitForElementToBeHittable(app.buttons[expectedButtonText])
        app.buttons[expectedButtonText].tap()
        sleep(2)

        app.buttons["PayPal learn more modal close"].tap()
        sleep(2)

        XCTAssertTrue(app.buttons["DELEGATE: didSelect fired"].waitForExistence(timeout: 30))
    }
}

final class PayPalMessaging_Failure_UITests: XCTestCase {

    // swiftlint:disable:next implicitly_unwrapped_optional
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

        XCTAssertTrue(app.buttons[expectedErrorText].waitForExistence(timeout: 20))
    }
}
