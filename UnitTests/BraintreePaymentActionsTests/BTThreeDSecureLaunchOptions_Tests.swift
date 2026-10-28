import XCTest
@testable import BraintreePaymentActions

class BTThreeDSecureLaunchOptions_Tests: XCTestCase {

    func testInit_defaultsMatchLegacyEquivalentDefaults() {
        let options = BTThreeDSecureLaunchOptions()

        XCTAssertEqual(options.uiType, .both)
        XCTAssertNil(options.renderTypes)
        XCTAssertNil(options.uiCustomization)
        XCTAssertNil(options.requestorAppURL)
    }

    func testProperties_areSettable() {
        let options = BTThreeDSecureLaunchOptions()
        let url = URL(string: "https://example.com/return")!

        options.uiType = .native
        options.renderTypes = [.otp, .html]
        options.uiCustomization = BTThreeDSecureLaunchUICustomization()
        options.requestorAppURL = url

        XCTAssertEqual(options.uiType, .native)
        XCTAssertEqual(options.renderTypes, [.otp, .html])
        XCTAssertNotNil(options.uiCustomization)
        XCTAssertEqual(options.requestorAppURL, url)
    }
}
