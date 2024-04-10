import XCTest
@testable import BraintreePayPal

final class BTPayPalReturnURL_Tests: XCTestCase {

    func testInitWithURL_whenSuccessReturnURL_createsValuesAndSetsSuccessState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "https://www.merchant-app.com/merchant-path/success?token=A_FAKE_EC_TOKEN&ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!))
        XCTAssertEqual(returnURL?.state, .succeeded)
    }

    func testInitWithURL_whenSuccessReturnURLWithoutToken_createsValuesAndSetsSuccessState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "https://www.merchant-app.com/merchant-path/success?ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!))
        XCTAssertEqual(returnURL?.state, .succeeded)
    }

    func testInitWithURL_whenCancelURLWithoutToken_setsCancelState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "https://www.merchant-app.com/merchant-path/cancel?ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!))
        XCTAssertEqual(returnURL?.state, .canceled)
    }

    func testInitWithURL_whenUnknownURLWithoutToken_setsUnknownState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "https://www.merchant-app.com/merchant-path/garbage-url")!))
        XCTAssertEqual(returnURL?.state, .unknownPath)
    }

    // TODO: add init for web based flow
}
