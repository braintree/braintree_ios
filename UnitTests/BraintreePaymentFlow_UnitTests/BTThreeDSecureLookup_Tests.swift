import XCTest

class BTThreeDSecureLookup_Tests: XCTestCase {
    func testLookup_initializesAllProperties() {
        let lookupBody = [
                "acsUrl": "http://acsUrl.com",
                "pareq": "paReqField",
                "md": "mdField",
                "termUrl": "http://termUrl.com"
            ] as [String : Any]
        let lookupJSON = BTJSON(value: lookupBody)

        let lookup = BTThreeDSecureLookup.init(json: lookupJSON)
        XCTAssertEqual(lookup!.paReq, "paReqField")
        XCTAssertEqual(lookup!.acsURL, URL.init(string: "http://acsUrl.com"))
        XCTAssertEqual(lookup!.md, "mdField")
        XCTAssertEqual(lookup!.termURL, URL.init(string: "http://termUrl.com"))
    }
}
