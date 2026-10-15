import XCTest
@testable import BraintreeTestShared
@testable import BraintreePaymentActions

class GetPaymentActionGraphQLBody_Tests: XCTestCase {

    func testQuery_isSelfFetch_withNoIDArgument() {
        let body = GetPaymentActionGraphQLBody()

        XCTAssertTrue(body.query.contains("query GetPaymentAction"))
        XCTAssertTrue(body.query.contains("paymentAction {"))
        XCTAssertFalse(body.query.contains("$id"))
    }

    func testQuery_requestsSharedPaymentActionFields() {
        let body = GetPaymentActionGraphQLBody()

        XCTAssertTrue(body.query.contains("id"))
        XCTAssertTrue(body.query.contains("status"))
        XCTAssertTrue(body.query.contains("nextAction"))
        XCTAssertTrue(body.query.contains("__typename"))
    }

    func testToDictionary_hasNoVariables() throws {
        let body = GetPaymentActionGraphQLBody()

        let dictionary = try body.toDictionary()
        let variables = dictionary["variables"] as? [String: Any]

        XCTAssertEqual(variables?.count, 0)
    }
}
