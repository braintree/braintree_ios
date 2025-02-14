import XCTest
@testable import BraintreePayPal

final class BTPayPalReturnURL_Tests: XCTestCase {

    func testInitWithURL_whenSuccessReturnURL_setsSuccessState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "https://www.merchant-app.com/merchant-path/success?token=A_FAKE_EC_TOKEN&ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!, fallbackUrl: nil))
        XCTAssertEqual(returnURL?.state, .succeeded)
    }

    func testInitWithURL_whenSuccessReturnURLWithoutToken_setsSuccessState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "https://www.merchant-app.com/merchant-path/success?ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!, fallbackUrl: nil))
        XCTAssertEqual(returnURL?.state, .succeeded)
    }

    func testInitWithURL_whenCancelURLWithoutToken_setsCancelState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "https://www.merchant-app.com/merchant-path/cancel?ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!, fallbackUrl: nil))
        XCTAssertEqual(returnURL?.state, .canceled)
    }

    func testInitWithURL_whenUnknownURLWithoutToken_setsUnknownState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "https://www.merchant-app.com/merchant-path/garbage-url")!, fallbackUrl: nil))
        XCTAssertEqual(returnURL?.state, .unknownPath)
    }

    func testInitWithSchemeURL_whenSuccessReturnURL_setsSuccessState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "bar://onetouch/v1/success?token=hermes_token")!, fallbackUrl: nil))
        XCTAssertEqual(returnURL?.state, .succeeded)
    }

    func testInitWithSchemeURL_whenCancelURLWithoutToken_setsCancelState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "bar://onetouch/v1/cancel?token=hermes_token")!, fallbackUrl: nil))
        XCTAssertEqual(returnURL?.state, .canceled)
    }

    func testInitWithSchemeURL_whenUnknownURLWithoutToken_setsUnknownState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "bar://onetouch/v1/invalid")!, fallbackUrl: nil))
        XCTAssertEqual(returnURL?.state, .unknownPath)
    }
}
