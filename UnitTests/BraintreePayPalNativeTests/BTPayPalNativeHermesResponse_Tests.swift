import XCTest
import BraintreeCore

@testable import BraintreePayPalNative

class BTPayPalNativeHermesResponse_Tests: XCTestCase {

    func testInit_whenJSONHasRedirectURL_setsOrderID() {
        let jsonString =
            """
            {
                "paymentResource": {
                    "redirectUrl": "my-url.com?token=some-token"
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let hermesResponse = BTPayPalNativeHermesResponse(json: json)

        XCTAssertEqual(hermesResponse?.orderID, "some-token")
    }

    func testInit_whenJSONHasApprovalURL_setsOrderID() {
        let jsonString =
            """
            {
                "agreementSetup": {
                    "approvalUrl": "my-url.com?ba_token=some-token"
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let hermesResponse = BTPayPalNativeHermesResponse(json: json)

        XCTAssertEqual(hermesResponse?.orderID, "some-token")
    }

    func testInit_whenJSONHasUnexpectedStructure_returnsNil() {
        let jsonString =
            """
            {
                "unexpected": {
                    "keys": "my-url.com"
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let hermesResponse = BTPayPalNativeHermesResponse(json: json)

        XCTAssertNil(hermesResponse)
    }

    func testInit_whenRedirectURLDoesNotHaveToken_returnsNil() {
        let jsonString =
            """
            {
                "paymentResource": {
                    "redirectUrl": "my-url.com"
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let hermesResponse = BTPayPalNativeHermesResponse(json: json)

        XCTAssertNil(hermesResponse)
    }

    func testInit_whenApprovalURLDoesNotHaveToken_returnsNil() {
        let jsonString =
            """
            {
                "agreementSetup": {
                    "approvalUrl": "my-url.com"
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let hermesResponse = BTPayPalNativeHermesResponse(json: json)

        XCTAssertNil(hermesResponse)
    }
}
