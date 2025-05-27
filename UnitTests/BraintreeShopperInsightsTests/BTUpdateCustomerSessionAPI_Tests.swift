import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeShopperInsights

class BTUpdateCustomerSessionApi_Test: XCTestCase {
    
    var mockAPIClient: MockAPIClient!
    var sut: BTUpdateCustomerSessionApi!
    
    let clientToken = TestClientTokenFactory.token(withVersion: 2)
    let sessionId = "shopper-session-id"
    
    let customerSessionRequest = BTCustomerSessionRequest(
        customer: BTCustomerSessionRequest.Customer(
            hashedEmail: "test-hashed-email.com",
            hashedPhoneNumber: "test-hashed-phone-number",
            paypalAppInstalled: true,
            venmoAppInstalled: false
        )
        ,
        purchaseUnits: [
            BTCustomerSessionRequest.BTPurchaseUnit(
                amount: .init(value: "4.50", currencyCode: "USD")
            ),
            BTCustomerSessionRequest.BTPurchaseUnit(
                amount: .init(value: "12.00", currencyCode: "USD")
            )
        ]
    )
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        sut = BTUpdateCustomerSessionApi(apiClient: mockAPIClient)
    }
    
    func testExecute_whenUpdateCustomerSessionResponseIsValid_returnsSessionId() {
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
        
        sut.execute(customerSessionRequest, sessionId: sessionId) { sessionId, error in
            if error != nil {
                XCTFail("Unexpected error: \(String(describing: error))")
            } else if sessionId != nil {
                XCTAssertEqual(sessionId, expectedSessionID)
            }
        }
    }
    
    func testExecute_whenUpdateCustomerSessionResponseIsInValid_returnsError() {
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
        
        let expectation = expectation(description: "error callback invoked")
        sut.execute(customerSessionRequest, sessionId: sessionId) { sessionId, error in
           XCTAssertNil(sessionId)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.code, BTHTTPError.httpResponseInvalid.errorCode)
            XCTAssertEqual(error.localizedDescription, "Unable to create HTTPURLResponse from response data.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    
}


