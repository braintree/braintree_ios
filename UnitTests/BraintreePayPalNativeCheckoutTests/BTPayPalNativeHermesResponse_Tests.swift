import XCTest
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore

class BTPayPalNativeHermesResponse_Tests: XCTestCase {

    func testHermesResponseCreation() throws {
        let expectedECToken = "EC-4RW94683SG8462403"

        let jsonData = try XCTUnwrap("""
        {
            "paymentResource": {
                "authenticateUrl": null,
                "intent": "authorize",
                "paymentToken": "PAYID-MK5WKWI5LX430173F5705007",
                "redirectUrl": "https://www.sandbox.paypal.com/checkoutnow?nolegacy=1&token=\(expectedECToken)"
            }
        }
        """.data(using: .utf8))
        let json = BTJSON(data: jsonData)

        let hermesResponse = BTPayPalNativeHermesResponse(json: json)
        XCTAssertNotNil(hermesResponse)

        XCTAssertEqual(hermesResponse?.orderID, expectedECToken)
    }
}
