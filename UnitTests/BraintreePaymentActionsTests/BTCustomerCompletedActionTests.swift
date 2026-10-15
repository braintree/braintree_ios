import XCTest
@testable import BraintreeTestShared
@testable import BraintreePaymentActions

class BTCustomerCompletedAction_Tests: XCTestCase {

    func testEncode_deviceDataCollection_encodesSingleKey() throws {
        let action = BTCustomerCompletedAction.deviceDataCollection(dfReferenceId: "df-reference-id")

        let dictionary = try action.toDictionary()

        XCTAssertEqual(dictionary.keys.count, 1)
        let deviceDataCollection = dictionary["deviceDataCollection"] as? [String: Any]
        XCTAssertEqual(deviceDataCollection?["dfReferenceId"] as? String, "df-reference-id")
        XCTAssertNil(dictionary["challenge"])
    }

    func testEncode_challenge_encodesSingleKey() throws {
        let action = BTCustomerCompletedAction.challenge(cardinalAuthenticationJWT: "jwt-value")

        let dictionary = try action.toDictionary()

        XCTAssertEqual(dictionary.keys.count, 1)
        let challenge = dictionary["challenge"] as? [String: Any]
        XCTAssertEqual(challenge?["cardinalAuthenticationJWT"] as? String, "jwt-value")
        XCTAssertNil(dictionary["deviceDataCollection"])
    }
}
