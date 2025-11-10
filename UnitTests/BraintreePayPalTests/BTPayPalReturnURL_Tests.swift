import XCTest
@testable import BraintreePayPal

final class BTPayPalReturnURL_Tests: XCTestCase {

    func testInitWithURL_whenSuccessReturnURL_setsSuccessState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "https://www.merchant-app.com/merchant-path/success?token=A_FAKE_EC_TOKEN&ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!))
        XCTAssertEqual(returnURL?.state, .succeeded)
    }

    func testInitWithURL_whenSuccessReturnURLWithoutToken_setsSuccessState() {
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

    func testInitWithSchemeURL_whenSuccessReturnURL_setsSuccessState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "bar://onetouch/v1/success?token=hermes_token")!))
        XCTAssertEqual(returnURL?.state, .succeeded)
    }

    func testInitWithSchemeURL_whenCancelURLWithoutToken_setsCancelState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "bar://onetouch/v1/cancel?token=hermes_token")!))
        XCTAssertEqual(returnURL?.state, .canceled)
    }

    func testInitWithSchemeURL_whenUnknownURLWithoutToken_setsUnknownState() {
        let returnURL = BTPayPalReturnURL(.payPalApp(url: URL(string: "bar://onetouch/v1/invalid")!))
        XCTAssertEqual(returnURL?.state, .unknownPath)
    }
    
    // MARK: - isValid with fallbackURLScheme Tests
    
    func testIsValid_withHTTPSScheme_andAppSwitchPath_returnsTrue() {
        let url = URL(string: "https://example.com/braintreeAppSwitchPayPal/success?token=test")!
        XCTAssertTrue(BTPayPalReturnURL.isValid(url, fallbackURLScheme: nil))
    }
    
    func testIsValid_withHTTPSScheme_withoutAppSwitchPath_returnsFalse() {
        let url = URL(string: "https://example.com/other-path/success?token=test")!
        XCTAssertFalse(BTPayPalReturnURL.isValid(url, fallbackURLScheme: nil))
    }
    
    func testIsValid_withCustomScheme_andFallbackURLScheme_returnsTrue() {
        let url = URL(string: "myapp://braintreeAppSwitchPayPal/success?token=test")!
        XCTAssertTrue(BTPayPalReturnURL.isValid(url, fallbackURLScheme: "myapp"))
    }
    
    func testIsValid_withCustomScheme_withoutFallbackURLScheme_returnsFalse() {
        let url = URL(string: "myapp://success?token=test")!
        XCTAssertFalse(BTPayPalReturnURL.isValid(url, fallbackURLScheme: nil))
    }
    
    func testIsValid_withCustomScheme_andDifferentFallbackURLScheme_returnsFalse() {
        let url = URL(string: "myapp://success?token=test")!
        XCTAssertFalse(BTPayPalReturnURL.isValid(url, fallbackURLScheme: "otherapp"))
    }
    
    func testIsValid_withCustomScheme_andAppSwitchPath_andFallbackURLScheme_returnsTrue() {
        let url = URL(string: "myapp://braintreeAppSwitchPayPal/success?token=test")!
        XCTAssertTrue(BTPayPalReturnURL.isValid(url, fallbackURLScheme: "myapp"))
    }
    
    func testIsValid_withHTTPSScheme_andFallbackURLSchemeProvided_stillAcceptsHTTPS() {
        let url = URL(string: "https://example.com/braintreeAppSwitchPayPal/success?token=test")!
        XCTAssertTrue(BTPayPalReturnURL.isValid(url, fallbackURLScheme: "myapp"))
    }
    
    func testIsValid_withCustomScheme_withoutSuccessOrCancelPath_returnsFalse() {
        let url = URL(string: "myapp://other?token=test")!
        XCTAssertFalse(BTPayPalReturnURL.isValid(url, fallbackURLScheme: "myapp"))
    }
    
    func testIsValid_withCustomScheme_withCancelPath_returnsTrue() {
        let url = URL(string: "myapp://braintreeAppSwitchPayPal/cancel?token=test")!
        XCTAssertTrue(BTPayPalReturnURL.isValid(url, fallbackURLScheme: "myapp"))
    }
    
    func testIsValid_withInvalidScheme_returnsFalse() {
        let url = URL(string: "http://example.com/braintreeAppSwitchPayPal/success?token=test")!
        XCTAssertFalse(BTPayPalReturnURL.isValid(url, fallbackURLScheme: nil))
    }
}
