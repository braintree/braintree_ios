import XCTest

class BTPaymentFlowDriver_ThreeDSecure_Tests: XCTestCase {

    var mockAPIClient = MockAPIClient(authorization: BTTestClientTokenFactory.token(withVersion: 3))!
    var threeDSecureRequest = BTThreeDSecureRequest()
    var driver: BTPaymentFlowDriver!

    override func setUp() {
        super.setUp()
        threeDSecureRequest.amount = 10.0
        threeDSecureRequest.nonce = "fake-card-nonce"
        driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
    }

    // MARK: - ThreeDSecure Lookup Tests

    func testPerformThreeDSecureLookup_whenSuccessful_callsBackWithResult() {
        let responseBody =
            """
            {
                "lookup": {
                    "acsUrl": "www.someAcsUrl.com",
                    "md": "someMd",
                    "pareq": "somePareq",
                    "termUrl": "www.someTermUrl.com",
                    "threeDSecureVersion": "2.1.0",
                    "transactionId": "someTransactionId"
                },
                "paymentMethod": {
                    "nonce": "someLookupNonce",
                    "threeDSecureInfo": {
                        "liabilityShiftPossible": true,
                        "liabilityShifted": false
                    }
                }
            }
            """

        mockAPIClient.cannedResponseBody = BTJSON(data: responseBody.data(using: String.Encoding.utf8)!)
        let expectation = self.expectation(description: "willCallCompletion")

        driver.performThreeDSecureLookupNew(threeDSecureRequest) { result, error in
            XCTAssertNotNil(result)
            XCTAssertNotNil(result?.lookup)
            XCTAssertNotNil(result?.tokenizedCard)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPerformThreeDSecureLookup_whenFetchingConfigurationFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let expectation = self.expectation(description: "lookup fails with errors")

        driver.performThreeDSecureLookupNew(threeDSecureRequest) { (lookup, error) in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPerformThreeDSecureLookup_whenLookupFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain:"BTError", code: 0, userInfo: nil)

        let expectation = self.expectation(description: "Post fails with error.")

        driver.performThreeDSecureLookupNew(threeDSecureRequest) { result, error in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testPerformThreeDSecureLookup_whenLookupFailsWith422_callsBackWithError() {
        let response = HTTPURLResponse(url: URL(string: "www.example.com")!, statusCode: 422, httpVersion: nil, headerFields: nil)

        let errorBody =
            """
            {
                "error" : {
                    "message" : "testMessage"
                }
            }
            """

        let userInfo: [String : AnyObject] = [
            BTHTTPURLResponseKey: response as AnyObject,
            BTHTTPJSONResponseBodyKey: BTJSON(data: errorBody.data(using: String.Encoding.utf8)!)
        ]

        mockAPIClient.cannedResponseError = NSError(domain:BTHTTPErrorDomain, code: BTHTTPErrorCode.clientError.rawValue, userInfo: userInfo)
        let expectation = self.expectation(description: "Post fails with error code 422.")

        driver.performThreeDSecureLookupNew(threeDSecureRequest) { result, error in
            let e = error! as NSError

            XCTAssertEqual(e.domain, BTThreeDSecureFlowErrorDomain)
            XCTAssertEqual(e.code, BTThreeDSecureFlowErrorType.failedLookup.rawValue)
            XCTAssertEqual(e.userInfo[NSLocalizedDescriptionKey] as? String, "testMessage")
            XCTAssertEqual(e.userInfo["com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey"] as? [String : String], ["message" : "testMessage"])
            XCTAssertNil(result)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
