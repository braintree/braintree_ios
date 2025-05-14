import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeShopperInsights

class BTCreateCustomerSessionApi_Tests: XCTestCase {
    
    var mockApiClient: MockAPIClient!
    var sut: BTCreateCustomerSessionApi!
    
    let clientToken = TestClientTokenFactory.token(withVersion: 3)
    
    let createCustomerSessionRequest = BTCustomerSessionRequest(
        hashedEmail: "test-hashed-email.com",
        hashedPhoneNumber: "test-hashed-phone-number",
        paypalAppInstalled: true,
        venmoAppInstalled: false,
        purchaseUnits: [
            BTCustomerSessionRequest.BTPurchaseUnit(amount: "4.50", currencyCode: "USD"),
            BTCustomerSessionRequest.BTPurchaseUnit(amount: "12.00", currencyCode: "USD")
        ]
    )
    
    override func setUp() {
        super.setUp()
        mockApiClient = MockAPIClient(authorization: clientToken)
        sut = BTCreateCustomerSessionApi(apiClient: mockApiClient)
    }
    
    func testExecute_whenCreateCustomerSessionResponseIsValid_returnsSessionId() {
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
        mockApiClient.cannedResponseBody = mockCreateCustomerSessionResponse
        
        sut.execute(createCustomerSessionRequest) { sessionId, error in
            if error != nil {
                XCTFail("Unexpected error: \(String(describing: error))")
            } else if sessionId != nil {
                XCTAssertEqual(sessionId, expectedSessionID)
            }
        }
    }
    
    func testExecute_whenCannotParseSessionId_returnsError() {
        let mockCreateCustomerSessionResponse = BTJSON(
            value: [
                "data": [
                    "createCustomerSession": [
                        "random": "random"
                    ]
                ]
            ]
        )
        mockApiClient.cannedResponseBody = mockCreateCustomerSessionResponse
        
        let expectation = expectation(description: "error callback invoked")
        sut.execute(createCustomerSessionRequest) { sessionId, error in
            XCTAssertNil(sessionId)
            guard let error = error as NSError? else { return }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}

