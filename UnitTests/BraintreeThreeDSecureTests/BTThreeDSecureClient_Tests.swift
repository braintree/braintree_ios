import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreeCard
@testable import BraintreeThreeDSecure

class BTThreeDSecureClient_Tests: XCTestCase {

    var mockAPIClient = MockAPIClient(authorization: TestClientTokenFactory.token(withVersion: 3))
    var threeDSecureRequest: BTThreeDSecureRequest!
    var client: BTThreeDSecureClient!
    var mockThreeDSecureRequestDelegate : MockThreeDSecureRequestDelegate!
    var authorization = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"

    let mockCardinalSession = MockCardinalSession()

    let mockConfiguration = BTJSON(value: [
        "threeDSecure": ["cardinalAuthenticationJWT": "FAKE_JWT"],
        "assetsUrl": "http://assets.example.com"
    ] as [String: Any])
    
    override func setUp() {
        super.setUp()
        threeDSecureRequest = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-card-nonce")
        client = BTThreeDSecureClient(authorization: authorization)

        client.apiClient = mockAPIClient

        client.cardinalSession = mockCardinalSession
        mockThreeDSecureRequestDelegate = MockThreeDSecureRequestDelegate()
    }

    // MARK: - performThreeDSecureLookup

    func testPerformThreeDSecureLookup_sendsAllParameters() {
        let expectation = self.expectation(description: "willCallCompletion")
        
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
        
        threeDSecureRequest = BTThreeDSecureRequest(
            amount: "9.97",
            nonce: "fake-card-nonce",
            accountType: .credit,
            billingAddress: billingAddress,
            cardAddChallengeRequested: true,
            challengeRequested: true,
            dataOnlyRequested: true,
            dfReferenceID: "df-reference-id", 
            email: "tester@example.com",
            exemptionRequested: true,
            mobilePhoneNumber: "5151234321",
            shippingMethod: .priority
        )

        client.apiClient = mockAPIClient

        client.performThreeDSecureLookup(threeDSecureRequest) { (lookup, error) in
            XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["amount"] as! String, "9.97")
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

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPerformThreeDSecureLookup_whenDefaultsArePassed_buildsRequestWithNilValues() {
        let expectation = expectation(description: "willCallCompletion")

        let threeDSecureRequest = BTThreeDSecureRequest(amount: "9.99", nonce: "fake-card-nonce")

        client.apiClient = mockAPIClient

        client.performThreeDSecureLookup(threeDSecureRequest) { _, _ in
            XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["amount"] as! String, "9.99")
            XCTAssertEqual(self.mockAPIClient.lastPOSTParameters!["requestedThreeDSecureVersion"] as! String, "2")
            XCTAssertNil(self.mockAPIClient.lastPOSTParameters!["dfReferenceId"] as? String)
            XCTAssertNil(self.mockAPIClient.lastPOSTParameters!["accountType"] as? String)
            XCTAssertNil(self.mockAPIClient.lastPOSTParameters!["requestedExemptionType"] as? String)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testPerformThreeDSecureLookup_whenCardAddChallengeRequestedNotSet_doesNotSendCardAddParameter() {
        let expectation = self.expectation(description: "willCallCompletion")
        
        threeDSecureRequest = BTThreeDSecureRequest(
            amount: "9.97",
            nonce: "fake-card-nonce",
            dfReferenceID: "df-reference-id"
        )

        client.performThreeDSecureLookup(threeDSecureRequest) { (lookup, error) in
            XCTAssertNil(self.mockAPIClient.lastPOSTParameters!["cardAdd"])

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPerformThreeDSecureLookup_whenCardAddChallengeRequested_sendsCardAddTrue() {
        
        threeDSecureRequest = BTThreeDSecureRequest(
            amount: "9.97",
            nonce: "fake-card-nonce",
            cardAddChallengeRequested: true,
            dfReferenceID: "df-reference-id"
        )

        let expectation = expectation(description: "willCallCompletion")

        client.apiClient = mockAPIClient

        client.performThreeDSecureLookup(threeDSecureRequest) { _, _ in
            XCTAssertTrue(self.mockAPIClient.lastPOSTParameters!["cardAdd"] as! Bool)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
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

        client.performThreeDSecureLookup(threeDSecureRequest) { result, error in
            XCTAssertNotNil(result)
            XCTAssertNotNil(result?.lookup)
            XCTAssertNotNil(result?.tokenizedCard)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupSucceeded))
    }

    func testPerformThreeDSecureLookup_whenFetchingConfigurationFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let expectation = self.expectation(description: "lookup fails with errors")

        client.performThreeDSecureLookup(threeDSecureRequest) { (lookup, error) in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupFailed))
    }

    func testPerformThreeDSecureLookup_whenLookupFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain:"BTError", code: 0, userInfo: nil)

        let expectation = self.expectation(description: "Post fails with error.")

        client.performThreeDSecureLookup(threeDSecureRequest) { result, error in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupFailed))
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
            BTCoreConstants.urlResponseKey: response as AnyObject,
            BTCoreConstants.jsonResponseBodyKey: BTJSON(data: errorBody.data(using: String.Encoding.utf8)!)
        ]

        mockAPIClient.cannedResponseError = BTHTTPError.clientError(userInfo) as NSError?
        let expectation = self.expectation(description: "Post fails with error code 422.")

        client.performThreeDSecureLookup(threeDSecureRequest) { result, error in
            let e = error! as NSError

            XCTAssertEqual(e.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(e.code, BTThreeDSecureError.failedLookup([:]).errorCode)
            XCTAssertEqual(e.userInfo[NSLocalizedDescriptionKey] as? String, "testMessage")
            XCTAssertEqual(e.userInfo["com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey"] as? [String : String], ["message" : "testMessage"])
            XCTAssertNil(result)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupFailed))
    }
    
    func testPerformThreeDSecureLookup_whenNetworkConnectionLost_sendsAnalytics() {
        mockAPIClient.cannedResponseError = NSError(domain: NSURLErrorDomain, code: -1005, userInfo: [NSLocalizedDescriptionKey: "The network connection was lost."])
        
        let expectation = self.expectation(description: "Callback envoked")
        
        client.performThreeDSecureLookup(threeDSecureRequest) { result, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupFailed))
    }
    
    // MARK: - startPaymentFlow
    
    func testStartPaymentFlow_whenAmountIsEmpty_throwsError() {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        
        threeDSecureRequest = BTThreeDSecureRequest(amount: "", nonce: "fake-card-nonce")
        let expectation = self.expectation(description: "Callback invoked")

        client.start(threeDSecureRequest) { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(error?.localizedDescription, "BTThreeDSecureRequest amount can not be nil or NaN.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }
    
    func testStartPayment_whenNoBodyReturned_returnsAnError() {
        threeDSecureRequest = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-card-nonce")
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        let expectation = expectation(description: "willCallCompletion")

        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        client.start(threeDSecureRequest) { result, error in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureError.noBodyReturned.errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }
    
    func testStartPayment_v2_returnsErrorWhenCardinalAuthenticationJWT_isMissing() {
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        let expectation = self.expectation(description: "willCallCompletion")

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": [] as [Any?],
            "assetsUrl": "http://assets.example.com"
        ] as [String: Any])

        client.start(threeDSecureRequest) { result, error in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureError.configuration("").errorCode)
            XCTAssertEqual(error.localizedDescription, "Missing the required Cardinal authentication JWT.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    func testStartPayment_whenAuthenticationNotRequired_returnsResult() {
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockThreeDSecureRequestDelegate.lookupCompleteExpectation = expectation(description: "startPaymentFlow completed successfully")
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "02",
                ],
                "nonce": "f689056d-aee1-421e-9d10-f2c9b34d4d6f",
                "threeDSecureInfo": [
                    "enrolled": "N",
                    "liabilityShiftPossible": false,
                    "liabilityShifted": false,
                    "status": "authenticate_successful_issuer_not_participating",
                ] as [String: Any],
                "type": "CreditCard",
            ] as [String: Any],
            "success": true,
            "threeDSecureInfo":     [
                "liabilityShiftPossible": false,
                "liabilityShifted": false,
            ]
        ] as [String : Any]
        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)

        client.start(threeDSecureRequest) { result, error in
            guard let result = result else { XCTFail(); return }
            guard let tokenizedCard = result.tokenizedCard else { XCTFail(); return }

            XCTAssertTrue(tokenizedCard.nonce.isANonce())
            XCTAssertNotEqual(tokenizedCard.nonce, self.threeDSecureRequest.nonce);
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShifted)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShiftPossible)
            XCTAssertTrue(tokenizedCard.threeDSecureInfo.wasVerified)
            XCTAssertNil(error)
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifySucceeded))
    }

    func testStartPayment_v2_callsOnLookupCompleteDelegateMethod() {
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockThreeDSecureRequestDelegate.lookupCompleteExpectation = expectation(description: "Lookup completed successfully")
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "02",
                ],
                "nonce": "f689056d-aee1-421e-9d10-f2c9b34d4d6f",
                "threeDSecureInfo": [
                    "enrolled": "Y",
                    "liabilityShiftPossible": true,
                    "liabilityShifted": true,
                    "status": "authenticate_successful",
                ] as [String: Any],
                "type": "CreditCard",
            ] as [String: Any],
            "success": true,
            "threeDSecureInfo":     [
                "liabilityShiftPossible": true,
                "liabilityShifted": true,
            ],
            "lookup": [
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com",
                "threeDSecureVersion": "1.0"
            ]
        ] as [String: Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)
        client.start(threeDSecureRequest) { _, _ in }

        waitForExpectations(timeout: 1)
    }

    func testStartPayment_v2_when_threeDSecureRequestDelegate_notSet_returnsError() {
        let expectation = expectation(description: "willCallCompletion")

        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        client.start(threeDSecureRequest) { result, error in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureError.configuration("").errorCode)
            XCTAssertEqual(error.localizedDescription, "Configuration Error: threeDSecureRequestDelegate can not be nil when versionRequested is 2.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    func getAuthRequiredLookupResponse() -> [String : Any] {
        return [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "02",
                ],
                "nonce": "f689056d-aee1-421e-9d10-f2c9b34d4d6f",
                "threeDSecureInfo": [
                    "enrolled": "Y",
                    "liabilityShiftPossible": true,
                    "liabilityShifted": true,
                    "status": "authenticate_successful",
                ] as [String: Any],
                "type": "CreditCard",
            ] as [String: Any],
            "success": true,
            "threeDSecureInfo":     [
                "liabilityShiftPossible": true,
                "liabilityShifted": true,
            ],
            "lookup": [
                "acsUrl": "http://example.com",
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com"
            ]
        ]
    }

    // MARK: - analytics events

    func testStartPayment_success_sendsAnalyticsEvents() {
        mockThreeDSecureRequestDelegate.lookupCompleteExpectation = expectation(description: "Lookup completed successfully")
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "02",
                ],
                "nonce": "f689056d-aee1-421e-9d10-f2c9b34d4d6f",
                "threeDSecureInfo": [
                    "enrolled": "Y",
                    "liabilityShiftPossible": true,
                    "liabilityShifted": true,
                    "status": "authenticate_successful",
                ] as [String: Any],
                "type": "CreditCard",
            ] as [String: Any],
            "success": true,
            "threeDSecureInfo":     [
                "liabilityShiftPossible": true,
                "liabilityShifted": true,
            ],
            "lookup": [
                "acsUrl": "http://example.com",
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com",
                "threeDSecureVersion": "2.0"
            ]
        ] as [String : Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)

        client.start(threeDSecureRequest) { _, _ in }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.challengeRequired))
    }
    
    func testStartPayment_success_whenAuthenticationNotRequired_sendsAnalyticsEvents() {
        mockThreeDSecureRequestDelegate.lookupCompleteExpectation = expectation(description: "Lookup completed successfully")
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "02",
                ],
                "nonce": "f689056d-aee1-421e-9d10-f2c9b34d4d6f",
                "threeDSecureInfo": [
                    "enrolled": "Y",
                    "liabilityShiftPossible": true,
                    "liabilityShifted": true,
                    "status": "authenticate_successful",
                ] as [String: Any],
                "type": "CreditCard",
            ] as [String: Any],
            "success": true,
            "threeDSecureInfo":     [
                "liabilityShiftPossible": true,
                "liabilityShifted": true,
            ],
            "lookup": [
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com",
                "threeDSecureVersion": "1.0"
            ]
        ] as [String : Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)

        client.start(threeDSecureRequest) { _, _ in }

        waitForExpectations(timeout: 1)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupSucceeded))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifySucceeded))
        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.challengeRequired))
    }
    
    func testStartPayment_failure_sendsAnalyticsEvents() {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        mockAPIClient.cannedResponseError = NSError(domain:"BTError", code: 500, userInfo: nil)
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        let expectation = expectation(description: "Start payment expectation")
        client.start(threeDSecureRequest) { result, error in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    func testStartPaymentFlow_whenV1ReturnedInLookup_callsBackWithResult() {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        let responseBody =
            """
            {
                "lookup": {
                    "acsUrl": "www.someAcsUrl.com",
                    "md": "someMd",
                    "pareq": "somePareq",
                    "termUrl": "www.someTermUrl.com",
                    "threeDSecureVersion": "1.1.0",
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

        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        client.start(threeDSecureRequest) { result, error in
            XCTAssertNotNil(error)
            XCTAssertNil(result)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureError.configuration("").errorCode)
            XCTAssertEqual(error.localizedDescription, "3D Secure v1 is deprecated and no longer supported. See https://developer.paypal.com/braintree/docs/guides/3d-secure/client-side for more information.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    // MARK: - prepareLookup

    func testPrepareLookup_getsJsonString() {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        let expectation = expectation(description: "willCallCompletion")

        threeDSecureRequest.dfReferenceID = "fake-df-reference-id"

        client.apiClient = mockAPIClient

        client.prepareLookup(threeDSecureRequest) { clientData, error in
            XCTAssertNil(error)
            XCTAssertNotNil(clientData)
            if let data = clientData!.data(using: .utf8) {
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                XCTAssertEqual(json!["dfReferenceId"] as! String, "fake-df-reference-id")
                XCTAssertEqual(json!["nonce"] as! String, "fake-card-nonce")
                XCTAssertNotNil(json!["braintreeLibraryVersion"] as! String)
                XCTAssertNotNil(json!["authorizationFingerprint"] as! String)
                let clientMetadata = json!["clientMetadata"] as! [String: Any]
                XCTAssertEqual(clientMetadata["requestedThreeDSecureVersion"] as! String, "2")
                XCTAssertEqual(clientMetadata["sdkVersion"] as! String, "iOS/\(BTCoreConstants.braintreeSDKVersion)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func testPrepareLookup_withTokenizationKey_throwsError() {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        
        let client = BTThreeDSecureClient(authorization: authorization)
        client.apiClient = MockAPIClient(authorization: authorization)
        let expectation = expectation(description: "willCallCompletion")

        threeDSecureRequest.dfReferenceID = "fake-df-reference-id"

        client.prepareLookup(threeDSecureRequest) { _, error in
            XCTAssertEqual(error?.localizedDescription, "A client token must be used for ThreeDSecure integrations.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testPrepareLookup_whenDfReferenceIDEmpty_throwsError() {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        mockCardinalSession.dfReferenceID = ""

        let expectation = expectation(description: "willCallCompletion")

        client.prepareLookup(threeDSecureRequest) { _, error in
            XCTAssertEqual(error?.localizedDescription, "There was an error retrieving the dfReferenceId.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
