import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeShopperInsights

class BTCreateCustomerSessionAPI_Tests: XCTestCase {
    
    var mockAPIClient: MockAPIClient!
    var sut: BTCreateCustomerSessionAPI!
    
    let clientToken = TestClientTokenFactory.token(withVersion: 3)
    
    let createCustomerSessionRequest = BTCustomerSessionRequest(
        customer: BTCustomerSessionRequest.Customer(
            hashedEmail: "test-hashed-email.com",
            hashedPhoneNumber: "test-hashed-phone-number",
            paypalAppInstalled: true,
            venmoAppInstalled: false
        )
        ,
        purchaseUnits: [
            BTCustomerSessionRequest.BTPurchaseUnit(amount: "4.50", currencyCode: "USD"),
            BTCustomerSessionRequest.BTPurchaseUnit(amount: "12.00", currencyCode: "USD")
        ]
    )
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        sut = BTCreateCustomerSessionAPI(apiClient: mockAPIClient)
    }
    
    func testExecute_whenCreateCustomerSessionResponseIsValid_callsBackWithsessionID() {
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
        
        sut.execute(createCustomerSessionRequest) { sessionID, error in
            if error != nil {
                XCTFail("Unexpected error: \(String(describing: error))")
            } else if sessionID != nil {
                XCTAssertEqual(sessionID, expectedSessionID)
            }
        }
    }
    
    func testExecute_whenInvalidResponseAndCannotParseSessionId_callsBackWithError() {
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
        
        let expectation = expectation(description: "error callback invoked")
        sut.execute(createCustomerSessionRequest) { sessionID, error in
            XCTAssertNil(sessionID)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.code, BTHTTPError.httpResponseInvalid.errorCode)
            XCTAssertEqual(error.localizedDescription, "Unable to create HTTPURLResponse from response data.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    func testExecute_whenEmptyResponseBodyReturned_callsBackWithError() {
        mockAPIClient.cannedResponseBody = nil
        
        let expectation = expectation(description: "error callback invoked")
        sut.execute(createCustomerSessionRequest) { sessionID, error in
            XCTAssertNil(sessionID)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTShopperInsightsError.errorDomain)
            XCTAssertEqual(error.code, BTShopperInsightsError.emptyBodyReturned.errorCode)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    func testExceute_whenCreateCustomerSessionAPIFails_callsBackWithError() {
        let mockError = NSError(domain: "create-customer-sessionerror", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError
        
        let expectation = expectation(description: "error callback invoked")
        sut.execute(createCustomerSessionRequest) { sessionID, error in
            XCTAssertNil(sessionID)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error, mockError)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}

