import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreeCard
@testable import BraintreeThreeDSecure

class BTThreeDSecureClient_Tests: XCTestCase {

    var mockAPIClient = MockAPIClient(authorization: TestClientTokenFactory.token(withVersion: 3))
    var threeDSecureRequest: BTThreeDSecureRequest!
    var client: BTThreeDSecureClient!
    var mockThreeDSecureRequestDelegate: MockThreeDSecureRequestDelegate!
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
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        mockThreeDSecureRequestDelegate = MockThreeDSecureRequestDelegate()
    }

    // MARK: - performThreeDSecureLookup

    func testPerformThreeDSecureLookup_sendsAllParameters() async {
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

        _ = try? await client.performThreeDSecureLookup(threeDSecureRequest)

        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["amount"] as! String, "9.97")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["requestedThreeDSecureVersion"] as! String, "2")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["dfReferenceId"] as! String, "df-reference-id")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["accountType"] as! String, "credit")
        XCTAssertTrue(mockAPIClient.lastPOSTParameters!["challengeRequested"] as! Bool)
        XCTAssertTrue(mockAPIClient.lastPOSTParameters!["exemptionRequested"] as! Bool)
        XCTAssertTrue(mockAPIClient.lastPOSTParameters!["dataOnlyRequested"] as! Bool)
        XCTAssertTrue(mockAPIClient.lastPOSTParameters!["cardAdd"] as! Bool)

        let additionalInfo = mockAPIClient.lastPOSTParameters!["additionalInfo"] as! Dictionary<String, String>
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
    }

    func testPerformThreeDSecureLookup_whenDefaultsArePassed_buildsRequestWithNilValues() async {
        let threeDSecureRequest = BTThreeDSecureRequest(amount: "9.99", nonce: "fake-card-nonce")

        _ = try? await client.performThreeDSecureLookup(threeDSecureRequest)

        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["amount"] as! String, "9.99")
        XCTAssertEqual(mockAPIClient.lastPOSTParameters!["requestedThreeDSecureVersion"] as! String, "2")
        XCTAssertNil(mockAPIClient.lastPOSTParameters!["dfReferenceId"] as? String)
        XCTAssertNil(mockAPIClient.lastPOSTParameters!["accountType"] as? String)
        XCTAssertNil(mockAPIClient.lastPOSTParameters!["requestedExemptionType"] as? String)
    }

    func testPerformThreeDSecureLookup_whenCardAddChallengeRequestedNotSet_doesNotSendCardAddParameter() async {
        threeDSecureRequest = BTThreeDSecureRequest(
            amount: "9.97",
            nonce: "fake-card-nonce",
            dfReferenceID: "df-reference-id"
        )

        _ = try? await client.performThreeDSecureLookup(threeDSecureRequest)

        XCTAssertNil(mockAPIClient.lastPOSTParameters!["cardAdd"])
    }

    func testPerformThreeDSecureLookup_whenCardAddChallengeRequested_sendsCardAddTrue() async {
        threeDSecureRequest = BTThreeDSecureRequest(
            amount: "9.97",
            nonce: "fake-card-nonce",
            cardAddChallengeRequested: true,
            dfReferenceID: "df-reference-id"
        )

        _ = try? await client.performThreeDSecureLookup(threeDSecureRequest)

        XCTAssertTrue(mockAPIClient.lastPOSTParameters!["cardAdd"] as! Bool)
    }

    func testPerformThreeDSecureLookup_whenSuccessful_callsBackWithResult() async {
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

        let result = try? await client.performThreeDSecureLookup(threeDSecureRequest)

        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.lookup)
        XCTAssertNotNil(result?.tokenizedCard)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupSucceeded))
    }

    func testPerformThreeDSecureLookup_whenFetchingConfigurationFails_callsBackWithConfigurationError() async {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        mockAPIClient.cannedConfigurationResponseBody = nil

        do {
            _ = try await client.performThreeDSecureLookup(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockAPIClient.cannedConfigurationResponseError!)
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupFailed))
    }

    func testPerformThreeDSecureLookup_whenLookupFails_callsBackWithError() async {
        mockAPIClient.cannedResponseError = NSError(domain: "BTError", code: 0, userInfo: nil)

        do {
            _ = try await client.performThreeDSecureLookup(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockAPIClient.cannedResponseError!)
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupFailed))
    }

    func testPerformThreeDSecureLookup_whenLookupFailsWith422_callsBackWithError() async {
        let response = HTTPURLResponse(url: URL(string: "www.example.com")!, statusCode: 422, httpVersion: nil, headerFields: nil)

        let errorBody =
            """
            {
                "error" : {
                    "message" : "testMessage"
                }
            }
            """

        let userInfo: [String: AnyObject] = [
            BTCoreConstants.urlResponseKey: response as AnyObject,
            BTCoreConstants.jsonResponseBodyKey: BTJSON(data: errorBody.data(using: String.Encoding.utf8)!)
        ]

        mockAPIClient.cannedResponseError = BTHTTPError.clientError(userInfo) as NSError?

        do {
            _ = try await client.performThreeDSecureLookup(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            let e = error as NSError
            XCTAssertEqual(e.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(e.code, BTThreeDSecureError.failedLookup([:]).errorCode)
            XCTAssertEqual(e.userInfo[NSLocalizedDescriptionKey] as? String, "testMessage")
            XCTAssertEqual(e.userInfo["com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey"] as? [String: String], ["message": "testMessage"])
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupFailed))
    }

    func testPerformThreeDSecureLookup_whenNetworkConnectionLost_sendsAnalytics() async {
        mockAPIClient.cannedResponseError = NSError(domain: NSURLErrorDomain, code: -1005, userInfo: [NSLocalizedDescriptionKey: "The network connection was lost."])

        do {
            _ = try await client.performThreeDSecureLookup(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupFailed))
    }

    // MARK: - startPaymentFlow

    func testStartPaymentFlow_whenAmountIsEmpty_throwsError() async {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        threeDSecureRequest = BTThreeDSecureRequest(amount: "", nonce: "fake-card-nonce")

        do {
            _ = try await client.start(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error.localizedDescription, "BTThreeDSecureRequest amount can not be nil or NaN.")
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    func testStartPayment_whenNoBodyReturned_returnsAnError() async {
        threeDSecureRequest = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-card-nonce")
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        do {
            _ = try await client.start(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            let e = error as NSError
            XCTAssertEqual(e.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(e.code, BTThreeDSecureError.noBodyReturned.errorCode)
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    func testStartPayment_v2_returnsErrorWhenCardinalAuthenticationJWT_isMissing() async {
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": [] as [Any?],
            "assetsUrl": "http://assets.example.com"
        ] as [String: Any])

        do {
            _ = try await client.start(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            let e = error as NSError
            XCTAssertEqual(e.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(e.code, BTThreeDSecureError.configuration("").errorCode)
            XCTAssertEqual(e.localizedDescription, "Missing the required Cardinal authentication JWT.")
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    func testStartPayment_whenAuthenticationNotRequired_returnsResult() async {
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": ["cardType": "Visa", "lastTwo": "02"],
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
            "threeDSecureInfo": ["liabilityShiftPossible": false, "liabilityShifted": false]
        ] as [String: Any]
        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)

        do {
            let result = try await client.start(threeDSecureRequest)
            guard let tokenizedCard = result.tokenizedCard else { XCTFail(); return }
            XCTAssertTrue(tokenizedCard.nonce.isANonce())
            XCTAssertNotEqual(tokenizedCard.nonce, threeDSecureRequest.nonce)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShifted)
            XCTAssertFalse(tokenizedCard.threeDSecureInfo.liabilityShiftPossible)
            XCTAssertTrue(tokenizedCard.threeDSecureInfo.wasVerified)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifySucceeded))
    }

    func testStartPayment_v2_callsOnLookupCompleteDelegateMethod() async {
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        let lookupExpectation = XCTestExpectation(description: "onLookupComplete called")
        mockThreeDSecureRequestDelegate.lookupCompleteExpectation = lookupExpectation
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": ["cardType": "Visa", "lastTwo": "02"],
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
            "threeDSecureInfo": ["liabilityShiftPossible": true, "liabilityShifted": true],
            "lookup": [
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com",
                "threeDSecureVersion": "1.0"
            ]
        ] as [String: Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)
        _ = try? await client.start(threeDSecureRequest)

        await fulfillment(of: [lookupExpectation], timeout: 1)
    }

    func testStartPayment_v2_when_threeDSecureRequestDelegate_notSet_returnsError() async {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        do {
            _ = try await client.start(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            let e = error as NSError
            XCTAssertEqual(e.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(e.code, BTThreeDSecureError.configuration("").errorCode)
            XCTAssertEqual(e.localizedDescription, "Configuration Error: threeDSecureRequestDelegate can not be nil when versionRequested is 2.")
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    func getAuthRequiredLookupResponse() -> [String: Any] {
        return [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": ["cardType": "Visa", "lastTwo": "02"],
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
            "threeDSecureInfo": ["liabilityShiftPossible": true, "liabilityShifted": true],
            "lookup": [
                "acsUrl": "http://example.com",
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com"
            ]
        ]
    }

    // MARK: - analytics events

    func testStartPayment_success_sendsAnalyticsEvents() async {
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": ["cardType": "Visa", "lastTwo": "02"],
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
            "threeDSecureInfo": ["liabilityShiftPossible": true, "liabilityShifted": true],
            "lookup": [
                "acsUrl": "http://example.com",
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com",
                "threeDSecureVersion": "2.0"
            ]
        ] as [String: Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)
        mockThreeDSecureRequestDelegate.lookupCompleteExpectation = expectation(description: "Lookup completed successfully")
        Task { _ = try? await client.start(threeDSecureRequest) }
        await fulfillment(of: [mockThreeDSecureRequestDelegate.lookupCompleteExpectation!], timeout: 1)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.challengeRequired))
    }

    func testStartPayment_success_whenAuthenticationNotRequired_sendsAnalyticsEvents() async {
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration

        let responseBody = [
            "paymentMethod": [
                "consumed": false,
                "description": "ending in 02",
                "details": ["cardType": "Visa", "lastTwo": "02"],
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
            "threeDSecureInfo": ["liabilityShiftPossible": true, "liabilityShifted": true],
            "lookup": [
                "pareq": "",
                "md": "",
                "termUrl": "http://example.com",
                "threeDSecureVersion": "1.0"
            ]
        ] as [String: Any]

        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)
        _ = try? await client.start(threeDSecureRequest)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.lookupSucceeded))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifySucceeded))
        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.challengeRequired))
    }

    func testStartPayment_failure_sendsAnalyticsEvents() async {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        mockAPIClient.cannedResponseError = NSError(domain: "BTError", code: 500, userInfo: nil)
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        _ = try? await client.start(threeDSecureRequest)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    func testStartPaymentFlow_whenV1ReturnedInLookup_callsBackWithResult() async {
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
        threeDSecureRequest.threeDSecureRequestDelegate = mockThreeDSecureRequestDelegate

        do {
            _ = try await client.start(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            let e = error as NSError
            XCTAssertEqual(e.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(e.code, BTThreeDSecureError.configuration("").errorCode)
            XCTAssertEqual(e.localizedDescription, "3D Secure v1 is deprecated and no longer supported. See https://developer.paypal.com/braintree/docs/guides/3d-secure/client-side for more information.")
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    // MARK: - initializeChallenge

    func testInitializeChallenge_whenFetchingConfigurationFails_throwsError() async {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "BTError", code: 0, userInfo: nil)
        mockAPIClient.cannedConfigurationResponseBody = nil

        do {
            _ = try await client.initializeChallenge(lookupResponse: "{}", request: threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockAPIClient.cannedConfigurationResponseError!)
        }
    }

    func testInitializeChallenge_whenAuthenticationNotRequired_returnsResult() async {
        let lookupResponse =
            """
            {
                "paymentMethod": {
                    "nonce": "a-nonce",
                    "threeDSecureInfo": {
                        "liabilityShiftPossible": true,
                        "liabilityShifted": true
                    }
                },
                "threeDSecureInfo": {
                    "liabilityShiftPossible": true,
                    "liabilityShifted": true
                }
            }
            """

        do {
            let result = try await client.initializeChallenge(lookupResponse: lookupResponse, request: threeDSecureRequest)
            XCTAssertNotNil(result)
            XCTAssertNil(result.lookup)
        } catch {
            XCTFail("Expected success but got error: \(error)")
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifySucceeded))
    }

    func testInitializeChallenge_whenV1ReturnedInLookup_throwsError() async {
        let lookupResponse =
            """
            {
                "lookup": {
                    "acsUrl": "http://www.someAcsUrl.com",
                    "pareq": "somePareq",
                    "termUrl": "http://www.someTermUrl.com",
                    "threeDSecureVersion": "1.0.2"
                },
                "paymentMethod": {
                    "nonce": "a-nonce",
                    "threeDSecureInfo": {
                        "liabilityShiftPossible": true,
                        "liabilityShifted": false
                    }
                }
            }
            """

        do {
            _ = try await client.initializeChallenge(lookupResponse: lookupResponse, request: threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            let error = error as NSError
            XCTAssertEqual(error.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureError.configuration("").errorCode)
            XCTAssertEqual(error.localizedDescription, "3D Secure v1 is deprecated and no longer supported. See https://developer.paypal.com/braintree/docs/guides/3d-secure/client-side for more information.")
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    func testInitializeChallenge_whenV2ChallengeRequired_throwsError() async {
        let lookupResponse =
            """
            {
                "lookup": {
                    "acsUrl": "http://www.someAcsUrl.com",
                    "pareq": "somePareq",
                    "termUrl": "http://www.someTermUrl.com",
                    "threeDSecureVersion": "2.1.0",
                    "transactionId": "someTransactionId"
                },
                "paymentMethod": {
                    "nonce": "a-nonce",
                    "threeDSecureInfo": {
                        "liabilityShiftPossible": true,
                        "liabilityShifted": false
                    }
                }
            }
            """

        do {
            _ = try await client.initializeChallenge(lookupResponse: lookupResponse, request: threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            let error = error as NSError
            XCTAssertEqual(error.domain, BTThreeDSecureError.errorDomain)
            XCTAssertEqual(error.code, BTThreeDSecureError.failedLookup([:]).errorCode)
        }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTThreeDSecureAnalytics.verifyFailed))
    }

    // MARK: - prepareLookup

    func testPrepareLookup_getsJsonString() async {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        threeDSecureRequest.dfReferenceID = "fake-df-reference-id"

        let clientData = try? await client.prepareLookup(threeDSecureRequest)

        XCTAssertNotNil(clientData)
        if let data = clientData?.data(using: .utf8) {
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            XCTAssertEqual(json!["dfReferenceId"] as! String, "fake-df-reference-id")
            XCTAssertEqual(json!["nonce"] as! String, "fake-card-nonce")
            XCTAssertNotNil(json!["braintreeLibraryVersion"] as! String)
            XCTAssertNotNil(json!["authorizationFingerprint"] as! String)
            let clientMetadata = json!["clientMetadata"] as! [String: Any]
            XCTAssertEqual(clientMetadata["requestedThreeDSecureVersion"] as! String, "2")
            XCTAssertEqual(clientMetadata["sdkVersion"] as! String, "iOS/\(BTCoreConstants.braintreeSDKVersion)")
        }
    }

    func testPrepareLookup_withTokenizationKey_throwsError() async {
        let client = BTThreeDSecureClient(authorization: authorization)
        client.apiClient = MockAPIClient(authorization: authorization)
        threeDSecureRequest.dfReferenceID = "fake-df-reference-id"

        do {
            _ = try await client.prepareLookup(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error.localizedDescription, "A client token must be used for ThreeDSecure integrations.")
        }
    }

    func testPrepareLookup_whenDfReferenceIDEmpty_throwsError() async {
        mockAPIClient.cannedConfigurationResponseBody = mockConfiguration
        mockCardinalSession.dfReferenceID = ""

        do {
            _ = try await client.prepareLookup(threeDSecureRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error.localizedDescription, "There was an error retrieving the dfReferenceId.")
        }
    }
}
