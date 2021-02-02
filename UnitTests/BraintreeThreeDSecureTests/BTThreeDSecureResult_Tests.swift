import XCTest
import BraintreeCore

class BTThreeDSecureResult_Tests: XCTestCase {
    func testInitWithJSON_whenLookupSucceeds() {
        let jsonString =
            """
            {
                "lookup": {
                    "acsUrl": "www.someAcsUrl.com",
                    "md": "someMd",
                    "pareq": "somePareq",
                    "termUrl": "www.someTermUrl.com",
                    "threeDSecureVersion": "2.1.0",
                    "transactionId": "someTransactionId"
                },
                "paymentMethod": {
                    "nonce": "someLookupNonce",
                    "threeDSecureInfo": {
                        "liabilityShiftPossible": true,
                        "liabilityShifted": false
                    }
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let result = BTThreeDSecureResult(json: json)
        XCTAssertEqual(result.lookup?.acsURL, URL(string: "www.someAcsUrl.com")!)
        XCTAssertEqual(result.lookup?.md, "someMd")
        XCTAssertEqual(result.lookup?.paReq, "somePareq")
        XCTAssertEqual(result.lookup?.termURL, URL(string: "www.someTermUrl.com")!)
        XCTAssertEqual(result.lookup?.threeDSecureVersion, "2.1.0")
        XCTAssertEqual(result.lookup?.transactionID, "someTransactionId")
        XCTAssertEqual(result.tokenizedCard?.nonce, "someLookupNonce")
        XCTAssertTrue(result.tokenizedCard!.threeDSecureInfo.liabilityShiftPossible)
        XCTAssertFalse(result.tokenizedCard!.threeDSecureInfo.liabilityShifted)
        XCTAssertNil(result.errorMessage)
    }

    func testInitWithJSON_whenLookupErrors() {
        let jsonString =
            """
            {
                "error": {
                    "message": "Record not found"
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let result = BTThreeDSecureResult(json: json)
        XCTAssertNil(result.lookup)
        XCTAssertNil(result.tokenizedCard)
        XCTAssertEqual(result.errorMessage, "Record not found")
    }

    func testInitWithJSON_whenAuthenticationSucceeds() {
        let jsonString =
            """
            {
                "paymentMethod": {
                    "nonce": "someLookupNonce",
                    "threeDSecureInfo": {
                        "liabilityShiftPossible": true,
                        "liabilityShifted": false
                    }
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let result = BTThreeDSecureResult(json: json)
        XCTAssertNil(result.lookup)
        XCTAssertEqual(result.tokenizedCard?.nonce, "someLookupNonce")
        XCTAssertTrue(result.tokenizedCard!.threeDSecureInfo.liabilityShiftPossible)
        XCTAssertFalse(result.tokenizedCard!.threeDSecureInfo.liabilityShifted)
        XCTAssertNil(result.errorMessage)
    }

    func testInitWithJSON_whenAuthenticationErrors_v1() {
        let jsonString =
            """
            {
                "error": {
                    "message": "An unexpected error occurred"
                }
            }
            """

        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let result = BTThreeDSecureResult(json: json)
        XCTAssertNil(result.lookup)
        XCTAssertNil(result.tokenizedCard)
        XCTAssertEqual(result.errorMessage, "An unexpected error occurred")
    }

    func testInitWithJSON_whenAuthenticationErrors_v2() {
        let jsonString =
            """
            {
                "errors": [
                    {
                        "message": "An unexpected error occurred"
                    }
                ]
            }
            """

        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let result = BTThreeDSecureResult(json: json)
        XCTAssertNil(result.lookup)
        XCTAssertNil(result.tokenizedCard)
        XCTAssertEqual(result.errorMessage, "An unexpected error occurred")
    }
}
