import XCTest
@testable import BraintreeTestShared
@testable import BraintreePaymentActions

class SignalCustomerActionCompleteGraphQLBody_Tests: XCTestCase {

    func testQuery_requestsSharedPaymentActionFields() {
        let body = SignalCustomerActionCompleteGraphQLBody(
            completedAction: .deviceDataCollection(dfReferenceId: "df-reference-id")
        )

        XCTAssertTrue(body.query.contains("mutation SignalCustomerActionComplete"))
        XCTAssertTrue(body.query.contains("signalCustomerActionComplete(input: $input)"))
        XCTAssertTrue(body.query.contains("id"))
        XCTAssertTrue(body.query.contains("status"))
        XCTAssertTrue(body.query.contains("nextAction"))
    }

    func testToDictionary_deviceDataCollection_omitsPaymentActionID() throws {
        let body = SignalCustomerActionCompleteGraphQLBody(
            completedAction: .deviceDataCollection(dfReferenceId: "df-reference-id")
        )

        let dictionary = try body.toDictionary()
        let variables = dictionary["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]

        XCTAssertNil(input?["paymentActionId"])

        let customerActionComplete = input?["customerActionComplete"] as? [String: Any]
        let deviceDataCollection = customerActionComplete?["deviceDataCollection"] as? [String: Any]
        XCTAssertEqual(deviceDataCollection?["dfReferenceId"] as? String, "df-reference-id")
        XCTAssertNil(customerActionComplete?["challenge"])
    }

    func testToDictionary_challenge_encodesOnlyChallengeVariant() throws {
        let body = SignalCustomerActionCompleteGraphQLBody(
            completedAction: .challenge(cardinalAuthenticationJWT: "jwt-value")
        )

        let dictionary = try body.toDictionary()
        let variables = dictionary["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customerActionComplete = input?["customerActionComplete"] as? [String: Any]

        let challenge = customerActionComplete?["challenge"] as? [String: Any]
        XCTAssertEqual(challenge?["cardinalAuthenticationJWT"] as? String, "jwt-value")
        XCTAssertNil(customerActionComplete?["deviceDataCollection"])
    }
}
