import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeShopperInsights

class BTUpdateCustomerSessionApi_Test: XCTestCase {
    
    var mockAPIClient: MockAPIClient!
    var sut: BTUpdateCustomerSessionAPI!
    
    let clientToken = TestClientTokenFactory.token(withVersion: 2)
    let sessionID = "shopper-session-id"
    
    let updateCustomerSessionRequest = BTCustomerSessionRequest(
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
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        sut = BTUpdateCustomerSessionAPI(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockAPIClient = nil
    }
    
    func testExecute_whenUpdateCustomerSessionResponseIsValid_returnsSessionID() async throws {
        let expectedSessionID = "session-id"
        let mockUpdateCustomerSessionResponse = BTJSON(
            value: [
                "data": [
                    "updateCustomerSession": [
                        "sessionId": "session-id"
                    ]
                ]
            ]
        )
        mockAPIClient.cannedResponseBody = mockUpdateCustomerSessionResponse
        
        let sessionID = try await sut.execute(updateCustomerSessionRequest, sessionID: sessionID)
        XCTAssertEqual(sessionID, expectedSessionID)
    }
    
    func testExecute_whenUpdateCustomerSessionResponseIsInValid_throwsBTHTTPError() async {
        let mockUpdateCustomerSessionResponse = BTJSON(
            value: [
                "data": [
                    "updateCustomerSession": [
                        "random-session-id": "invalid-session-id"
                    ]
                ]
            ]
        )
        mockAPIClient.cannedResponseBody = mockUpdateCustomerSessionResponse
        
        do {
            let _ = try await sut.execute(updateCustomerSessionRequest, sessionID: sessionID)
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
            _ = try await sut.execute(updateCustomerSessionRequest, sessionID: sessionID)
            XCTFail("Expected an error")
        } catch let error as BTShopperInsightsError {
            XCTAssertEqual((error as NSError).domain, BTShopperInsightsError.errorDomain)
            XCTAssertEqual(error.errorCode, BTShopperInsightsError.emptyBodyReturned.errorCode)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExceute_whenCreateCustomerSessionAPIFails_throwsNSError() async {
        let mockError = NSError(domain: "update-customer-session-error", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError
        
        do {
            _ = try await sut.execute(updateCustomerSessionRequest, sessionID: sessionID)
            XCTFail("Expected an error")
        } catch let error as NSError {
            XCTAssertEqual(error, mockError)
        }
    }
}
