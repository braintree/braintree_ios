import XCTest

class Venmo_UITests: XCTestCase {

    // swiftlint:disable implicitly_unwrapped_optional
    var demoApp: XCUIApplication!
    // swiftlint:enable implicitly_unwrapped_optional

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        demoApp = XCUIApplication(bundleIdentifier: "com.braintreepayments.Demo")
        demoApp.launchArguments.append("-EnvironmentSandbox")
        demoApp.launchArguments.append("-ClientToken")
        demoApp.launchArguments.append("-Integration:VenmoViewController")
        demoApp.launch()
    }

    // TODO: Add UI test
}
