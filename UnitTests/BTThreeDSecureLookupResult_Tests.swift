import XCTest

class BTThreeDSecureLookupResult_Tests: XCTestCase {
    
    func testRequiresUserAuthentication_whenAcsUrlIsPresent_returnsTrue() {
        let lookup = BTThreeDSecureLookupResult()
        lookup.acsURL = NSURL(string: "http://example.com")
        lookup.termURL = NSURL(string: "http://example.com")
        lookup.MD = "an-md"
        lookup.PAReq = "a-PAReq"

        XCTAssertTrue(lookup.requiresUserAuthentication())
    }

    func testRequiresUserAuthentication_whenAcsUrlIsNotPresent_returnsFalse() {
        let lookup = BTThreeDSecureLookupResult()
        lookup.acsURL = nil
        lookup.termURL = NSURL(string: "http://example.com")
        lookup.MD = "an-md"
        lookup.PAReq = "a-PAReq"

        XCTAssertFalse(lookup.requiresUserAuthentication())
    }
}
