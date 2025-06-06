import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights

class UpdateCustomerSessionMutationGraphQLBody_Tests: XCTestCase {
    
    let sessionID = "shopper-session-id"
    let request = BTCustomerSessionRequest(
        hashedEmail: "test-hashed-email.com",
        hashedPhoneNumber: "test-hashed-phone-number",
        payPalAppInstalled: true,
        venmoAppInstalled: false,
        purchaseUnits: [
            BTPurchaseUnit(
                amount: "4.50",
                currencyCode: "USD"
            ),
            BTPurchaseUnit(
                amount: "12.00",
                currencyCode: "USD"
            )
        ]
    )
    let expectedQuery = """
            mutation UpdateCustomerSession($input: UpdateCustomerSessionInput!) {
                updateCustomerSession(input: $input) {
                    sessionId
                }
            }
            """
    
    func testEncodingUpdateCustomerSessionGraphQLBodyWithFullData() {
        let body = UpdateCustomerSessionMutationGraphQLBody(request: request, sessionID: sessionID)
        
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        let amount = purchaseUnits?.first?["amount"] as? [String: Any]
        
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(customer?["hashedEmail"] as? String, "test-hashed-email.com")
        XCTAssertEqual(customer?["paypalAppInstalled"] as? Bool, true)
        XCTAssertEqual(amount?["value"] as? String, "4.50")
    }
    
    func testEncodingUpdateCustomerSessionGraphQLBodyWithNilData() {
        let request = BTCustomerSessionRequest(
            hashedEmail: nil,
            hashedPhoneNumber: nil,
            payPalAppInstalled: nil,
            venmoAppInstalled: nil,
            purchaseUnits: nil
        )
        
        let body = UpdateCustomerSessionMutationGraphQLBody(request: request, sessionID: sessionID)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        
        XCTAssertNotNil(customer)
        XCTAssertNil(purchaseUnits)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
    }
    
    func testEncodingUpdateCustomerSessionGraphQLBodyWithEmptyData() {
        let request = BTCustomerSessionRequest(
            hashedEmail: nil,
            hashedPhoneNumber: nil,
            payPalAppInstalled: nil,
            venmoAppInstalled: nil,
            purchaseUnits: []
        )
        
        let body = UpdateCustomerSessionMutationGraphQLBody(request: request, sessionID: sessionID)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        
        XCTAssertNotNil(customer)
        XCTAssertEqual(purchaseUnits?.count, 0)
        XCTAssertEqual(input?["sessionId"] as? String, sessionID)
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
    }
}
