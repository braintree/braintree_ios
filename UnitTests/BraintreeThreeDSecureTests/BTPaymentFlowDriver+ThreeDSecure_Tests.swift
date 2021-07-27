import XCTest
import BraintreeTestShared

class BTPaymentFlowDriver_ThreeDSecure_Tests: XCTestCase {

    var mockAPIClient = MockAPIClient(authorization: TestClientTokenFactory.token(withVersion: 3))!
    var threeDSecureRequest = BTThreeDSecureRequest()
    var driver: BTPaymentFlowDriver!

    override func setUp() {
        super.setUp()
        threeDSecureRequest.amount = 10.0
        threeDSecureRequest.nonce = "fake-card-nonce"
        driver = BTPaymentFlowDriver(apiClient: mockAPIClient)
    }

    // MARK: - performThreeDSecureLookup

    func testPerformThreeDSecureLookup_sendsAllParameters() {
        let expectation = self.expectation(description: "willCallCompletion")

        threeDSecureRequest.nonce = "fake-card-nonce"
        threeDSecureRequest.amount = 9.97
        threeDSecureRequest.versionRequested = .version2
        threeDSecureRequest.dfReferenceID = "df-reference-id"
        threeDSecureRequest.accountType = .credit
        threeDSecureRequest.challengeRequested = true
        threeDSecureRequest.exemptionRequested = true
        threeDSecureRequest.dataOnlyRequested = true
        threeDSecureRequest.cardAddChallenge = .requested

        threeDSecureRequest.mobilePhoneNumber = "5151234321"
        threeDSecureRequest.email = "tester@example.com"
        threeDSecureRequest.shippingMethod = .priority

        let billingAddress = BTThreeDSecurePostalAddress()
        billingAddress.givenName = "Joe"
        billingAddress.surname = "Guy"
        billingAddress.phoneNumber = "12345678"
        billingAddress.streetAddress = "555 Smith St."
        billingAddress.extendedAddress = "#5"
        billingAddress.line3 = "Suite A"
        billingAddress.locality = "Oakland"
        billingAddress.region = "CA"
        billingAddress.countryCodeAlpha2 = "US"
        billingAddress.postalCode = "54321"
        threeDSecureRequest.billingAddress = billingAddress

        driver.performThreeDSecureLookup(threeDSecureRequest) { (lookup, error) in
            XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["amount"] as! NSDecimalNumber, 9.97)
            XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["requestedThreeDSecureVersion"] as! String, "2")
            XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["dfReferenceId"] as! String, "df-reference-id")
            XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["accountType"] as! String, "credit")
            XCTAssertTrue(self.mockAPIClient.lastPOSTParameters!["challengeRequested"] as! Bool)
            XCTAssertTrue(self.mockAPIClient.lastPOSTParameters!["exemptionRequested"] as! Bool)
            XCTAssertTrue(self.mockAPIClient.lastPOSTParameters!["dataOnlyRequested"] as! Bool)
            XCTAssertTrue(self.mockAPIClient.lastPOSTParameters!["cardAdd"] as! Bool)

            let additionalInfo = self.mockAPIClient.lastPOSTParameters!["additionalInfo"] as! Dictionary<String, String>
            XCTAssertEqual(additionalInfo["mobilePhoneNumber"], "5151234321")
            XCTAssertEqual(additionalInfo["email"], "tester@example.com")
            XCTAssertEqual(additionalInfo["shippingMethod"], "03")

            XCTAssertEqual(additionalInfo["billingGivenName"], "Joe")
            XCTAssertEqual(additionalInfo["billingSurname"], "Guy")
            XCTAssertEqual(additionalInfo["billingPhoneNumber"], "12345678")
            XCTAssertEqual(additionalInfo["billingLine1"], "555 Smith St.")
            XCTAssertEqual(additionalInfo["billingLine2"], "#5")
            XCTAssertEqual(additionalInfo["billingLine3"], "Suite A")
            XCTAssertEqual(additionalInfo["billingCity"], "Oakland")
            XCTAssertEqual(additionalInfo["billingState"], "CA")
            XCTAssertEqual(additionalInfo["billingCountryCode"], "US")
            XCTAssertEqual(additionalInfo["billingPostalCode"], "54321")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testPerformThreeDSecureLookup_whenCardAddChallengeNotRequested_sendsCardAddFalse() {
        let expectation = self.expectation(description: "willCallCompletion")

        threeDSecureRequest.nonce = "fake-card-nonce"
        threeDSecureRequest.amount = 9.97
        threeDSecureRequest.dfReferenceID = "df-reference-id"

        threeDSecureRequest.cardAddChallenge = .notRequested

        driver.performThreeDSecureLookup(threeDSecureRequest) { (lookup, error) in
            XCTAssertFalse(self.mockAPIClient.lastPOSTParameters!["cardAdd"] as! Bool)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testPerformThreeDSecureLookup_whenCardAddChallengeRequestedNotSet_doesNotSendCardAddParameter() {
        let expectation = self.expectation(description: "willCallCompletion")

        threeDSecureRequest.nonce = "fake-card-nonce"
        threeDSecureRequest.amount = 9.97
        threeDSecureRequest.dfReferenceID = "df-reference-id"

        driver.performThreeDSecureLookup(threeDSecureRequest) { (lookup, error) in
            XCTAssertNil(self.mockAPIClient.lastPOSTParameters!["cardAdd"] as? Bool)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }


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

        driver.performThreeDSecureLookup(threeDSecureRequest) { result, error in
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

        driver.performThreeDSecureLookup(threeDSecureRequest) { (lookup, error) in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPerformThreeDSecureLookup_whenLookupFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain:"BTError", code: 0, userInfo: nil)

        let expectation = self.expectation(description: "Post fails with error.")

        driver.performThreeDSecureLookup(threeDSecureRequest) { result, error in
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

        driver.performThreeDSecureLookup(threeDSecureRequest) { result, error in
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
