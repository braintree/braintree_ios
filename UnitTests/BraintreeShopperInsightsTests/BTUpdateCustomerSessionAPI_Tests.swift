import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeShopperInsights

class BTUpdateCustomerSessionApi_Test: XCTestCase {
    
    var mockAPIClient: MockAPIClient!
    var sut: BTUpdateCustomerSessionAPI!
    
    let clientToken = TestClientTokenFactory.token(withVersion: 2)
    let sessionID = "shopper-session-id"
    
    let customerSessionRequest = BTCustomerSessionRequest(
        hashedEmail: "test-hashed-email.com",
        hashedPhoneNumber: "test-hashed-phone-number",
        paypalAppInstalled: true,
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
    
    func testExecute_whenUpdateCustomerSessionResponseIsValid_returnsSessionId() async {
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
        
        do {
            let sessionID = try await sut.execute(customerSessionRequest, sessionID: sessionID)
            XCTAssertEqual(sessionID, expectedSessionID)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExecute_whenUpdateCustomerSessionResponseIsInValid_returnsError() async {
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
            let _ = try await sut.execute(customerSessionRequest, sessionID: sessionID)
            XCTFail("Expected error was not thrown")
        } catch let error as BTHTTPError {
            XCTAssertEqual(error.errorCode, BTHTTPError.httpResponseInvalid.errorCode)
            XCTAssertEqual(error.localizedDescription, "Unable to create HTTPURLResponse from response data.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
