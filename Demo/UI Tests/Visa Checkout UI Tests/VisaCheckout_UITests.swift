import XCTest

class VisaCheckout_UITests: XCTestCase {

    var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments.append("-EnvironmentSandbox")
        app.launchArguments.append("-TokenizationKey")
        app.launchArguments.append("-Integration:VisaCheckoutViewController")
        app.launch()
    }

    func testVisaCheckout_whenCanceled_returnToApp() {
        let visaButton = app.buttons["visaCheckoutButton"]

        XCTAssertTrue(visaButton.waitForExistence(timeout: 60))
        visaButton.forceTapElement()

        XCTAssertTrue(app.buttons["Cancel and return to My App"].waitForExistence(timeout: 30))

        /// Taps the middle of the cancel button to avoid issues where the "X" is not tappable
        let closeButtonCoordinate = app.buttons["Cancel and return to My App"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        closeButtonCoordinate.doubleTap()

        XCTAssertTrue(visaButton.waitForExistence(timeout: 30))
    }
}
