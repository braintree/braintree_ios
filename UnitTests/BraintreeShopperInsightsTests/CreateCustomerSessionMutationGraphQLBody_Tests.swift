import XCTest
@testable import BraintreeTestShared
@testable import BraintreeShopperInsights

class CreateCustomerSessionMutationGraphQLBody_Tests: XCTestCase {
    
    let request = BTCustomerSessionRequest(
        hashedEmail: "test-hashed-email.com",
        hashedPhoneNumber: "test-hashed-phone-number",
        payPalAppInstalled: true,
        venmoAppInstalled: false,
        purchaseUnits: [
            BTPurchaseUnit(
                amount: "10.00",
                currencyCode: "USD"
            ),
            BTPurchaseUnit(
                amount: "20.00",
                currencyCode: "USD"
            )
        ]
    )
    let expectedQuery = """
            mutation CreateCustomerSession($input: CreateCustomerSessionInput!) {
                createCustomerSession(input: $input) {
                    sessionId
                }
            }
            """
    
    func testEncodingCreateCustomerSessionGraphQLBodyWithFullData() {
        let body = CreateCustomerSessionMutationGraphQLBody(request: request)
        
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
        XCTAssertEqual(customer?["hashedEmail"] as? String, "test-hashed-email.com")
        XCTAssertEqual(customer?["paypalAppInstalled"] as? Bool, true)
        XCTAssertEqual(amount?["value"] as? String, "10.00")
    }
    
    func testEncodingCreateCustomerSessionGraphQLBodyWithNilData() {
        let request = BTCustomerSessionRequest(
            hashedEmail: nil,
            hashedPhoneNumber: nil,
            payPalAppInstalled: nil,
            venmoAppInstalled: nil,
            purchaseUnits: nil
        )
        
        let body = CreateCustomerSessionMutationGraphQLBody(request: request)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
        XCTAssertNotNil(customer)
        XCTAssertNil(purchaseUnits)
    }
    
    func testEncodingCreateCustomerSessionGraphQLBodyWithEmptyData() {
        let request = BTCustomerSessionRequest(
            hashedEmail: nil,
            hashedPhoneNumber: nil,
            payPalAppInstalled: nil,
            venmoAppInstalled: nil,
            purchaseUnits: []
        )
        
        let body = CreateCustomerSessionMutationGraphQLBody(request: request)
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        
        XCTAssertEqual(jsonObject["query"] as? String, expectedQuery)
        XCTAssertNotNil(customer)
        XCTAssertEqual(purchaseUnits?.count, 0)
    }
}
