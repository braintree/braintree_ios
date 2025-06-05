import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeShopperInsights

class BTCreateCustomerSessionAPI_Tests: XCTestCase {
    
    var mockAPIClient: MockAPIClient!
    var sut: BTCreateCustomerSessionAPI!
    
    let clientToken = TestClientTokenFactory.token(withVersion: 3)
    
    let createCustomerSessionRequest = BTCustomerSessionRequest(
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
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        sut = BTCreateCustomerSessionAPI(apiClient: mockAPIClient)
    }
    
    func testExecute_whenCreateCustomerSessionResponseIsValid_returnsSessionID() async throws {
        let expectedSessionID = "session-id"
        let mockCreateCustomerSessionResponse = BTJSON(
            value: [
                "data": [
                    "createCustomerSession": [
                        "sessionId": "session-id"
                    ]
                ]
            ]
        )
        mockAPIClient.cannedResponseBody = mockCreateCustomerSessionResponse
        
        let sessionID = try await sut.execute(createCustomerSessionRequest)
        
        XCTAssertEqual(sessionID, expectedSessionID)
    }
    
    func testExecute_whenInvalidResponseAndCannotParseSessionId_throwsBTHTTPError() async {
        let mockCreateCustomerSessionResponse = BTJSON(
            value: [
                "data": [
                    "createCustomerSession": [
                        "random": "random"
                    ]
                ]
            ]
        )
        mockAPIClient.cannedResponseBody = mockCreateCustomerSessionResponse
        
        do {
            _ = try await sut.execute(createCustomerSessionRequest)
            XCTFail("Expected an error")
        } catch let error as BTHTTPError {
            XCTAssertEqual(error.errorCode, BTHTTPError.httpResponseInvalid.errorCode)
            XCTAssertEqual(error.localizedDescription, "Unable to create HTTPURLResponse from response data.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExecute_whenEmptyResponseBodyReturned_throwsBTShopperInsightsError() async {
        mockAPIClient.cannedResponseBody = nil
        
        do {
            _ = try await sut.execute(createCustomerSessionRequest)
            XCTFail("Expected an error")
        } catch let error as BTShopperInsightsError {
            XCTAssertEqual((error as NSError).domain, BTShopperInsightsError.errorDomain)
            XCTAssertEqual(error.errorCode, BTShopperInsightsError.emptyBodyReturned.errorCode)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExceute_whenCreateCustomerSessionAPIFails_throwsNSError() async {
        let mockError = NSError(domain: "create-customer-sessionerror", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError
        
        do {
            _ = try await sut.execute(createCustomerSessionRequest)
            XCTFail("Expected an error")
        } catch let error as NSError {
            XCTAssertEqual(error, mockError)
        }
    }
    
    func testEncodingCreateCustomerSessionGraphQLBodyWithFullData() {
        let body = CreateCustomerSessionMutationGraphQLBody(request: createCustomerSessionRequest)
        
        guard let jsonObject = try? body.toDictionary() else {
            XCTFail()
            return
        }
        
        let variables = jsonObject["variables"] as? [String: Any]
        let input = variables?["input"] as? [String: Any]
        let customer = input?["customer"] as? [String: Any]
        let purchaseUnits = input?["purchaseUnits"] as? [[String: Any]]
        let amount = purchaseUnits?.first?["amount"] as? [String: Any]
        
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
        
        XCTAssertNotNil(customer)
        XCTAssertEqual(purchaseUnits?.count, 0)
    }
}
