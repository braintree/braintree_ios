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

        // Disable animations for more reliable tests
        demoApp.launchEnvironment["UITEST_DISABLE_ANIMATIONS"] = "YES"
        demoApp.launch()

        // Wait for app to be ready
        _ = demoApp.wait(for: .runningForeground, timeout: 10)
    }

    func testTokenizeVenmo_whenSignInSuccessfulWithPaymentContext_returnsNonce() {
        // Wait for Venmo button and tap with retry
        let venmoButton = demoApp.buttons["Venmo"]
        XCTAssertTrue(
            waitForElementToBeHittable(venmoButton, timeout: 30),
            "Venmo button did not appear"
        )
        XCTAssertTrue(venmoButton.tapWithRetry(), "Failed to tap Venmo button")

        // Wait for app switch to MockVenmo
        waitForAppSwitch(to: mockVenmo)

        // Wait for success button in MockVenmo and tap with retry
        let successButton = mockVenmo.buttons["SUCCESS WITH PAYMENT CONTEXT"]
        XCTAssertTrue(
            waitForElementToBeHittable(successButton, timeout: 30),
            "Success button did not appear in MockVenmo"
        )
        XCTAssertTrue(successButton.tapWithRetry(), "Failed to tap success button")

        // Wait for app switch back to Demo app
        waitForAppSwitch(to: demoApp)

        // Verify nonce received
        let nonceButton = demoApp.buttons["Got a nonce. Tap to make a transaction."]
        XCTAssertTrue(
            waitForElementToAppear(nonceButton, timeout: 30),
            "Nonce button did not appear"
        )
    }

    func testTokenizeVenmo_whenSignInSuccessfulWithoutPaymentContext_returnsNonce() {
        let venmoButton = demoApp.buttons["Venmo"]
        XCTAssertTrue(
            waitForElementToBeHittable(venmoButton, timeout: 30),
            "Venmo button did not appear"
        )
        XCTAssertTrue(venmoButton.tapWithRetry(), "Failed to tap Venmo button")

        waitForAppSwitch(to: mockVenmo)

        let successButton = mockVenmo.buttons["SUCCESS WITHOUT PAYMENT CONTEXT"]
        XCTAssertTrue(
            waitForElementToBeHittable(successButton, timeout: 30),
            "Success button did not appear in MockVenmo"
        )
        XCTAssertTrue(successButton.tapWithRetry(), "Failed to tap success button")

        waitForAppSwitch(to: demoApp)

        let nonceButton = demoApp.buttons["Got a nonce. Tap to make a transaction."]
        XCTAssertTrue(
            waitForElementToAppear(nonceButton, timeout: 30),
            "Nonce button did not appear"
        )
    }

    func testTokenizeVenmo_whenErrorOccurs_returnsError() {
        let venmoButton = demoApp.buttons["Venmo"]
        XCTAssertTrue(
            waitForElementToBeHittable(venmoButton, timeout: 30),
            "Venmo button did not appear"
        )
        XCTAssertTrue(venmoButton.tapWithRetry(), "Failed to tap Venmo button")

        waitForAppSwitch(to: mockVenmo)

        let errorButton = mockVenmo.buttons["ERROR"]
        XCTAssertTrue(
            waitForElementToBeHittable(errorButton, timeout: 30),
            "Error button did not appear in MockVenmo"
        )
        XCTAssertTrue(errorButton.tapWithRetry(), "Failed to tap error button")

        waitForAppSwitch(to: demoApp)

        let errorMessage = demoApp.buttons["An error occurred during the Venmo flow"]
        XCTAssertTrue(
            waitForElementToAppear(errorMessage, timeout: 30),
            "Error message did not appear"
        )
    }

    func testTokenizeVenmo_whenUserCancels_returnsCancel() {
        let venmoButton = demoApp.buttons["Venmo"]
        XCTAssertTrue(
            waitForElementToBeHittable(venmoButton, timeout: 30),
            "Venmo button did not appear"
        )
        XCTAssertTrue(venmoButton.tapWithRetry(), "Failed to tap Venmo button")

        waitForAppSwitch(to: mockVenmo)

        let cancelButton = mockVenmo.buttons["Cancel"]
        XCTAssertTrue(
            waitForElementToBeHittable(cancelButton, timeout: 30),
            "Cancel button did not appear in MockVenmo"
        )
        XCTAssertTrue(cancelButton.tapWithRetry(), "Failed to tap cancel button")

        waitForAppSwitch(to: demoApp)

        let canceledButton = demoApp.buttons["Canceled 🔰"]
        XCTAssertTrue(
            waitForElementToAppear(canceledButton, timeout: 30),
            "Canceled button did not appear"
        )
    }

    // MARK: - Helper Methods

    /// Wait for app switch with proper timing
    private func waitForAppSwitch(to app: XCUIApplication, timeout: TimeInterval = 10) {
        // Wait for app to become active
        _ = app.wait(for: .runningForeground, timeout: timeout)

        // Give the app a moment to fully render UI after switch
        Thread.sleep(forTimeInterval: 0.5)
    }
}
