import XCTest
@testable import BraintreePayPal

final class BTPayPalAppSwitchReturnURL_Tests: XCTestCase {

    func testInitWithURL_whenSuccessReturnURL_createsValuesAndSetsSuccessState() {
        let returnURL = BTPayPalAppSwitchReturnURL(url: URL(string: "https://www.merchant-app.com/merchant-path/success?token=A_FAKE_EC_TOKEN&ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890.1234")!)
        XCTAssertEqual(returnURL?.baToken, "A_FAKE_BA_TOKEN")
        XCTAssertEqual(returnURL?.ecToken, "A_FAKE_EC_TOKEN")
        XCTAssertEqual(returnURL?.timestamp, "1234567890.1234")
        XCTAssertEqual(returnURL?.state, .succeeded)
    }

    func testInitWithURL_whenSuccessReturnURLWithoutToken_createsValuesAndSetsSuccessState() {
        let returnURL = BTPayPalAppSwitchReturnURL(url: URL(string: "https://www.merchant-app.com/merchant-path/success?ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!)
        XCTAssertEqual(returnURL?.baToken, "A_FAKE_BA_TOKEN")
        XCTAssertNil(returnURL?.ecToken)
        XCTAssertEqual(returnURL?.timestamp, "1234567890")
        XCTAssertEqual(returnURL?.state, .succeeded)
    }

    func testInitWithURL_whenCancelURL_setsCancelState() {
        let returnURL = BTPayPalAppSwitchReturnURL(url: URL(string: "https://www.merchant-app.com/merchant-path/cancel?ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!)
        XCTAssertEqual(returnURL?.state, .canceled)
    }

    func testInitWithURL_whenUnknownURL_setsUnknownState() {
        let returnURL = BTPayPalAppSwitchReturnURL(url: URL(string: "https://www.merchant-app.com/merchant-path/garbage-url")!)
        XCTAssertEqual(returnURL?.state, .unknown)
    }
}
