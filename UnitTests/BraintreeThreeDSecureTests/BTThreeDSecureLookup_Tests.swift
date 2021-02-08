import XCTest

class BTThreeDSecureLookup_Tests: XCTestCase {
    func testInitWithJSON_whenFieldsArePresent() {
        let jsonString =
            """
            {
                "acsUrl": "www.someAcsUrl.com",
                "md": "someMd",
                "pareq": "somePareq",
                "termUrl": "www.someTermUrl.com",
                "threeDSecureVersion": "2.1.0",
                "transactionId": "someTransactionId"
            }
            """

        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let lookup = BTThreeDSecureLookup(json: json)

        XCTAssertEqual(lookup.acsURL, URL(string: "www.someAcsUrl.com"))
        XCTAssertEqual(lookup.md, "someMd")
        XCTAssertEqual(lookup.paReq, "somePareq")
        XCTAssertEqual(lookup.termURL, URL(string: "www.someTermUrl.com"))
        XCTAssertEqual(lookup.threeDSecureVersion, "2.1.0")
        XCTAssertEqual(lookup.transactionID, "someTransactionId")
        XCTAssertTrue(lookup.isThreeDSecureVersion2)
        XCTAssertTrue(lookup.requiresUserAuthentication)
    }

    func testInitWithJSON_whenFieldsAreMissing() {
        let jsonString = "{ }"

        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let lookup = BTThreeDSecureLookup(json: json)

        XCTAssertNil(lookup.acsURL)
        XCTAssertNil(lookup.md)
        XCTAssertNil(lookup.paReq)
        XCTAssertNil(lookup.termURL)
        XCTAssertNil(lookup.threeDSecureVersion)
        XCTAssertNil(lookup.transactionID)
        XCTAssertFalse(lookup.isThreeDSecureVersion2)
        XCTAssertFalse(lookup.requiresUserAuthentication)
    }
}
