import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

final class BTPayPalApprovalURLParser_Tests: XCTestCase {

    func testInit_withPayPalAppApprovalUrl_setsRedirectTypeAndBAToken() {
        let payPalAppApprovalUrlJSON = BTJSON(value: [
            "agreementSetup": ["paypalAppApprovalUrl": "https://www.paypal.com?ba_token=A_FAKE_BA_TOKEN"]
        ])
        let approvalURLParser = BTPayPalApprovalURLParser(body: payPalAppApprovalUrlJSON, linkType: "universal")

        XCTAssertEqual(approvalURLParser?.redirectType, .payPalApp(url: URL(string: "https://www.paypal.com?ba_token=A_FAKE_BA_TOKEN")!))
        XCTAssertEqual(approvalURLParser?.baToken, "A_FAKE_BA_TOKEN")
        XCTAssertNil(approvalURLParser?.ecToken)
    }

    func testInit_withRedirectUrl_setsRedirectTypeAndECToken() {
        let redirectUrlJSON = BTJSON(value: [
            "paymentResource": ["redirectUrl": "https://www.paypal.com/checkout?token=A_FAKE_EC_TOKEN"]
        ])
        let approvalURLParser = BTPayPalApprovalURLParser(body: redirectUrlJSON, linkType: nil)

        XCTAssertEqual(approvalURLParser?.redirectType, .webBrowser(url: URL(string: "https://www.paypal.com/checkout?token=A_FAKE_EC_TOKEN")!))
        XCTAssertNil(approvalURLParser?.baToken)
        XCTAssertEqual(approvalURLParser?.ecToken, "A_FAKE_EC_TOKEN")
    }

    func testInit_withApprovalUrl_setsRedirectTypeAndECToken() {
        let approvalUrlJSON = BTJSON(value: [
            "agreementSetup": ["approvalUrl": "https://www.paypal.com/agreements/approve?ba_token=A_FAKE_BA_TOKEN"]
        ])
        let approvalURLParser = BTPayPalApprovalURLParser(body: approvalUrlJSON, linkType: "universal")

        XCTAssertEqual(approvalURLParser?.redirectType, .webBrowser(url: URL(string: "https://www.paypal.com/agreements/approve?ba_token=A_FAKE_BA_TOKEN")!))
        XCTAssertEqual(approvalURLParser?.baToken, "A_FAKE_BA_TOKEN")
        XCTAssertNil(approvalURLParser?.ecToken)
    }

    func testInit_withBadJSON_returnsNil() {
        let badJSON = BTJSON(value: ["bad": "not-a-url"])
        let approvalURLParser = BTPayPalApprovalURLParser(body: badJSON, linkType: nil)

        XCTAssertNil(approvalURLParser?.redirectType)
        XCTAssertNil(approvalURLParser?.baToken)
        XCTAssertNil(approvalURLParser?.ecToken)
    }
}
