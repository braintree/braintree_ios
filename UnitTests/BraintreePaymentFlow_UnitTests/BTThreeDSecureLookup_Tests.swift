import XCTest

class BTThreeDSecureLookup_Tests: XCTestCase {
    func testLookup_initializesAllProperties() {
        let lookupBody = [
                "acsUrl": "http://acsUrl.com",
                "pareq": "paReqField",
                "md": "mdField",
                "termUrl": "http://termUrl.com",
                "threeDSecureVersion": "2.1.0",
                "transactionId": "transactionIdField"
            ] as [String : Any]
        let lookupJSON = BTJSON(value: lookupBody)

        guard let lookup = BTThreeDSecureLookup(json: lookupJSON) else {
            XCTFail()
            return
        }
        XCTAssertEqual(lookup.paReq, "paReqField")
        XCTAssertEqual(lookup.acsURL, URL(string: "http://acsUrl.com"))
        XCTAssertEqual(lookup.md, "mdField")
        XCTAssertEqual(lookup.termURL, URL(string: "http://termUrl.com"))
        XCTAssertEqual(lookup.threeDSecureVersion, "2.1.0")
        XCTAssertEqual(lookup.transactionId, "transactionIdField")
        XCTAssertTrue(lookup.isThreeDSecureVersion2)
    }

    func testLookup_initializesWithNilProperties() {
        let lookupBody = [
            "pareq": "paReqField",
            "md": "mdField",
            "termUrl": "http://termUrl.com",
            "transactionId": "transactionIdField",
            ] as [String : Any]
        let lookupJSON = BTJSON(value: lookupBody)

        guard let lookup = BTThreeDSecureLookup(json: lookupJSON) else {
            XCTFail()
            return
        }
        XCTAssertEqual(lookup.paReq, "paReqField")
        XCTAssertNil(lookup.acsURL)
        XCTAssertEqual(lookup.md, "mdField")
        XCTAssertEqual(lookup.termURL, URL(string: "http://termUrl.com"))
        XCTAssertNil(lookup.threeDSecureVersion)
        XCTAssertEqual(lookup.transactionId, "transactionIdField")
    }
}
