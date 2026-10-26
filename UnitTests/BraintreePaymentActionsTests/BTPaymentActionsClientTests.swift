import XCTest
import CardinalMobile
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreePaymentActions

class BTPaymentActionsClient_Tests: XCTestCase {

    let authorization: String = "development_tokenization_key"
    var mockAPIClient: MockAPIClient!
    var sut: BTPaymentActionsClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: authorization)
        sut = BTPaymentActionsClient(authorization: authorization)
        sut.apiClient = mockAPIClient

        // handleNextAction fetches configuration to construct its CardinalMobile wrapper.
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "threeDSecure": ["cardinalAuthenticationJWT": "fake-cardinal-authentication-jwt"]
        ])
    }

    // MARK: - Request Posting

    func testSubmitForPaymentAction_postsToGraphQLAPI() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "setPaymentActionPaymentMethod": [
                    "paymentAction": [
                        "id": "payment-action-id",
                        "status": "READY_FOR_CONFIRMATION"
                    ]
                ] as [String: Any]
            ]
        ])

        let request = MockPaymentActionRequest()
        _ = try await sut.submitForPaymentAction(request)

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)

        let body = try SetPaymentActionPaymentMethodGraphQLBody(request: request)
        let expectedDictionary = try! body.toDictionary()

        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail("Expected POST parameters")
            return
        }
        XCTAssertEqual(lastPostParameters as NSObject, expectedDictionary as NSObject)
    }

    // MARK: - Status -> Result Mapping (async/await API)

    func testSubmitForPaymentAction_requiresPaymentMethod_returnsPaymentMethodRequiredResult() async throws {
        stubResponse(id: "payment-action-id", status: "REQUIRES_PAYMENT_METHOD")
  
        let result = try await sut.submitForPaymentAction(MockPaymentActionRequest())
 
        XCTAssertEqual(result.type, .paymentMethodRequired)
        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }

    func testSubmitForPaymentAction_readyForConfirmation_returnsServerActionRequiredConfirm() async throws {
        stubResponse(id: "payment-action-id", status: "READY_FOR_CONFIRMATION")

        let result = try await sut.submitForPaymentAction(MockPaymentActionRequest())

        XCTAssertEqual(result.type, .serverActionRequired)
        XCTAssertEqual((result as? BTServerActionRequiredResult)?.serverAction, .confirm)
        XCTAssertEqual(result.id, "payment-action-id")
    }

    func testSubmitForPaymentAction_requiresCapture_returnsServerActionRequiredCapture() async throws {
        stubResponse(id: "payment-action-id", status: "REQUIRES_CAPTURE")

        let result = try await sut.submitForPaymentAction(MockPaymentActionRequest())

        XCTAssertEqual(result.type, .serverActionRequired)
        XCTAssertEqual((result as? BTServerActionRequiredResult)?.serverAction, .capture)
        XCTAssertEqual(result.id, "payment-action-id")
    }

    func testSubmitForPaymentAction_requiresCustomerAction_returnsCustomerActionRequiredResult() async throws {
        stubResponse(id: "payment-action-id", status: "REQUIRES_CUSTOMER_ACTION")

        let result = try await sut.submitForPaymentAction(MockPaymentActionRequest())

        XCTAssertEqual(result.type, .customerActionRequired)
        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }

    func testSubmitForPaymentAction_processing_returnsProcessingResult() async throws {
        stubResponse(id: "payment-action-id", status: "PROCESSING")

        let result = try await sut.submitForPaymentAction(MockPaymentActionRequest())

        XCTAssertEqual(result.type, .processing)
        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }

    func testSubmitForPaymentAction_succeeded_returnsCompletedResult() async throws {
        stubResponse(id: "payment-action-id", status: "SUCCEEDED")

        let result = try await sut.submitForPaymentAction(MockPaymentActionRequest())

        XCTAssertEqual(result.type, .completed)
        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }

    func testSubmitForPaymentAction_canceled_returnsCanceledResult() async throws {
        stubResponse(id: "payment-action-id", status: "CANCELLED")

        let result = try await sut.submitForPaymentAction(MockPaymentActionRequest())

        XCTAssertEqual(result.type, .canceled)
        XCTAssertEqual(result.id, "payment-action-id")
    }

    func testSubmitForPaymentAction_expired_returnsExpiredResult() async throws {
        stubResponse(id: "payment-action-id", status: "EXPIRED")

        let result = try await sut.submitForPaymentAction(MockPaymentActionRequest())

        XCTAssertEqual(result.type, .expired)
        XCTAssertEqual(result.id, "payment-action-id")
    }

    func testSubmitForPaymentAction_unknownServerStatus_returnsUnknownResult() async throws {
        stubResponse(id: "payment-action-id", status: "SOME_NEW_SERVER_STATUS")

        let result = try await sut.submitForPaymentAction(MockPaymentActionRequest())

        XCTAssertEqual(result.type, .unknown)
        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }
    
    // MARK: - Missing / Empty Fields

    func testSubmitForPaymentAction_missingID_throwsMissingID() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "setPaymentActionPaymentMethod": [
                    "paymentAction": [
                        "status": "READY_FOR_CONFIRMATION"
                    ]
                ] as [String: Any]
            ]
        ])

        do {
            _ = try await sut.submitForPaymentAction(MockPaymentActionRequest())
            XCTFail("Expected missingID error to be thrown")
        } catch let error as BTPaymentActionError {
            XCTAssertEqual(error, .missingID)
        } catch {
            XCTFail("Expected BTPaymentActionError.missingID, got \(error)")
        }
    }

    func testSubmitForPaymentAction_emptyID_throwsMissingID() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "setPaymentActionPaymentMethod": [
                    "paymentAction": [
                        "id": "",
                        "status": "READY_FOR_CONFIRMATION"
                    ]
                ] as [String: Any]
            ]
        ])

        do {
            _ = try await sut.submitForPaymentAction(MockPaymentActionRequest())
            XCTFail("Expected missingID error to be thrown")
        } catch let error as BTPaymentActionError {
            XCTAssertEqual(error, .missingID)
        } catch {
            XCTFail("Expected BTPaymentActionError.missingID, got \(error)")
        }
    }

    func testSubmitForPaymentAction_missingStatus_throwsMissingStatus() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "setPaymentActionPaymentMethod": [
                    "paymentAction": [
                        "id": "payment-action-id"
                    ]
                ] as [String: Any]
            ]
        ])

        do {
            _ = try await sut.submitForPaymentAction(MockPaymentActionRequest())
            XCTFail("Expected missingStatus error to be thrown")
        } catch let error as BTPaymentActionError {
            XCTAssertEqual(error, .missingStatus)
        } catch {
            XCTFail("Expected BTPaymentActionError.missingStatus, got \(error)")
        }
    }

    func testSubmitForPaymentAction_emptyStatus_throwsMissingStatus() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "setPaymentActionPaymentMethod": [
                    "paymentAction": [
                        "id": "payment-action-id",
                        "status": ""
                    ]
                ] as [String: Any]
            ]
        ])

        do {
            _ = try await sut.submitForPaymentAction(MockPaymentActionRequest())
            XCTFail("Expected missingStatus error to be thrown")
        } catch let error as BTPaymentActionError {
            XCTAssertEqual(error, .missingStatus)
        } catch {
            XCTFail("Expected BTPaymentActionError.missingStatus, got \(error)")
        }
    }

    func testSubmitForPaymentAction_missingDataEnvelope_throwsMissingID() async {
        // No "data" key at all in the response
        mockAPIClient.cannedResponseBody = BTJSON(value: [:] as [String: Any])

        do {
            _ = try await sut.submitForPaymentAction(MockPaymentActionRequest())
            XCTFail("Expected missingID error to be thrown")
        } catch let error as BTPaymentActionError {
            XCTAssertEqual(error, .missingID)
        } catch {
            XCTFail("Expected BTPaymentActionError.missingID, got \(error)")
        }
    }

    // MARK: - paymentMethodParameters() Failures

    func testSubmitForPaymentAction_baseClassDoesNotOverrideParameters_throwsMissingParameters() async {
        // Using BTPaymentActionRequest directly (no subclass override) should throw .missingParameters
        // before any network call is made.
        let request = BTPaymentActionRequest()

        do {
            _ = try await sut.submitForPaymentAction(request)
            XCTFail("Expected missingParameters error to be thrown")
        } catch let error as BTPaymentActionError {
            XCTAssertEqual(error, .missingParameters)
        } catch {
            XCTFail("Expected BTPaymentActionError.missingParameters, got \(error)")
        }
    }

    func testSubmitForPaymentAction_paymentMethodParametersThrows_propagatesError() async {
        let mockError = NSError(domain: "TestErrorDomain", code: 42, userInfo: nil)

        let request = MockPaymentActionRequest()
        request.stubbedError = mockError

        do {
            _ = try await sut.submitForPaymentAction(request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockError)
        }
    }

    // MARK: - Network Error Propagation

    func testSubmitForPaymentAction_networkError_propagatesError() async {
        let mockError = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError

        do {
            _ = try await sut.submitForPaymentAction(MockPaymentActionRequest())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockError)
        }
    }

    // MARK: - Completion Block API

    func testSubmitForPaymentAction_completion_success_returnsResult() {
        stubResponse(id: "payment-action-id", status: "SUCCEEDED")

        let expectation = expectation(description: "Completion called")

        sut.submitForPaymentAction(MockPaymentActionRequest()) { result, error in
            XCTAssertNil(error)
            XCTAssertEqual(result?.type, .completed)
            XCTAssertEqual(result?.id, "payment-action-id")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testSubmitForPaymentAction_completion_failure_returnsError() {
        let mockError = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError

        let expectation = expectation(description: "Completion called")

        sut.submitForPaymentAction(MockPaymentActionRequest()) { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(error as? NSError, mockError)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - internal setPaymentActionPaymentMethod

    func testSetPaymentActionPaymentMethod_returnsFullResult() async throws {
        stubResponse(id: "payment-action-id", status: "SUCCEEDED")

        let request = MockPaymentActionRequest()
        let body = try SetPaymentActionPaymentMethodGraphQLBody(request: request)
        let result = try await sut.setPaymentActionPaymentMethod(body)

        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertEqual(result.status, .succeeded)
    }

    // MARK: - internal result(from:) mapping

    func testResultFrom_requiresPaymentMethod_mapsToPaymentMethodRequired() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .requiresPaymentMethod)
        let result = sut.result(from: paymentAction)

        XCTAssertEqual(result.type, .paymentMethodRequired)
        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }

    func testResultFrom_readyForConfirmation_mapsToServerActionRequiredConfirm() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .readyForConfirmation)
        let result = sut.result(from: paymentAction)

        XCTAssertEqual(result.type, .serverActionRequired)
        XCTAssertEqual((result as? BTServerActionRequiredResult)?.serverAction, .confirm)
    }

    func testResultFrom_requiresCapture_mapsToServerActionRequiredCapture() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .requiresCapture)
        let result = sut.result(from: paymentAction)

        XCTAssertEqual(result.type, .serverActionRequired)
        XCTAssertEqual((result as? BTServerActionRequiredResult)?.serverAction, .capture)
    }

    func testResultFrom_requiresCustomerAction_mapsToCustomerActionRequired() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .requiresCustomerAction)
        let result = sut.result(from: paymentAction)

        XCTAssertEqual(result.type, .customerActionRequired)
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }

    func testResultFrom_processing_mapsToProcessing() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .processing)
        let result = sut.result(from: paymentAction)

        XCTAssertEqual(result.type, .processing)
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }

    func testResultFrom_succeeded_mapsToCompleted() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .succeeded)
        let result = sut.result(from: paymentAction)

        XCTAssertEqual(result.type, .completed)
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }

    func testResultFrom_canceled_mapsToCanceled() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .canceled)
        let result = sut.result(from: paymentAction)

        XCTAssertEqual(result.type, .canceled)
    }

    func testResultFrom_expired_mapsToExpired() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .expired)
        let result = sut.result(from: paymentAction)

        XCTAssertEqual(result.type, .expired)
    }

    func testResultFrom_unknown_mapsToUnknown() {
        let paymentAction = BTPaymentAction(id: "payment-action-id", status: .unknown)
        let result = sut.result(from: paymentAction)

        XCTAssertEqual(result.type, .unknown)
        XCTAssertFalse(result is BTServerActionRequiredResult)
    }
    
    // MARK: - internal getPaymentAction

    func testGetPaymentAction_postsToGraphQLAPI_withNoIDArgument() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "paymentAction": [
                    "id": "payment-action-id",
                    "status": "REQUIRES_CUSTOMER_ACTION"
                ] as [String: Any]
            ]
        ])

        let result = try await sut.getPaymentAction()

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertEqual(result.status, .requiresCustomerAction)
    }

    func testGetPaymentAction_parsesNextAction() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "paymentAction": [
                    "id": "payment-action-id",
                    "status": "REQUIRES_CUSTOMER_ACTION",
                    "nextAction": [
                        "__typename": "PaymentActionThreeDSecureAuthentication",
                        "bin": "401288"
                    ] as [String: Any]
                ] as [String: Any]
            ]
        ])

        let result = try await sut.getPaymentAction()

        XCTAssertEqual(
            result.nextAction,
            .threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction(bin: "401288"))
        )
    }

    func testGetPaymentAction_missingID_throwsMissingID() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "paymentAction": ["status": "REQUIRES_CUSTOMER_ACTION"] as [String: Any]
            ]
        ])

        do {
            _ = try await sut.getPaymentAction()
            XCTFail("Expected missingID error to be thrown")
        } catch let error as BTPaymentActionError {
            XCTAssertEqual(error, .missingID)
        } catch {
            XCTFail("Expected BTPaymentActionError.missingID, got \(error)")
        }
    }

    func testGetPaymentAction_networkError_propagatesError() async {
        let mockError = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError

        do {
            _ = try await sut.getPaymentAction()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockError)
        }
    }

    // MARK: - internal signalCustomerActionComplete

    func testSignalCustomerActionComplete_postsToGraphQLAPI() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "signalCustomerActionComplete": [
                    "paymentAction": [
                        "id": "payment-action-id",
                        "status": "REQUIRES_CUSTOMER_ACTION",
                        "nextAction": [
                            "__typename": "PaymentActionThreeDSecureChallenge",
                            "acsUrl": "https://acs.example.com",
                            "challengePayload": "payload-data"
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any]
            ]
        ])

        let completedAction = BTCustomerCompletedAction.deviceDataCollection(dfReferenceID: "df-reference-id")
        let result = try await sut.signalCustomerActionComplete(completedAction)

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertEqual(result.status, .requiresCustomerAction)
        XCTAssertEqual(
            result.nextAction,
            .threeDSecureChallenge(
                BTPaymentActionThreeDSecureChallengeNextAction(
                    acsURL: URL(string: "https://acs.example.com")!,
                    acsRenderingType: nil,
                    challengePayload: "payload-data",
                    mpiTransactionID: nil
                )
            )
        )
    }

    func testSignalCustomerActionComplete_readyForConfirmation_clearsNextAction() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "signalCustomerActionComplete": [
                    "paymentAction": [
                        "id": "payment-action-id",
                        "status": "READY_FOR_CONFIRMATION"
                    ] as [String: Any]
                ] as [String: Any]
            ]
        ])

        let completedAction = BTCustomerCompletedAction.challenge(cardinalAuthenticationJWT: "jwt-value")
        let result = try await sut.signalCustomerActionComplete(completedAction)

        XCTAssertEqual(result.status, .readyForConfirmation)
        XCTAssertNil(result.nextAction)
    }

    func testSignalCustomerActionComplete_missingStatus_throwsMissingStatus() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "signalCustomerActionComplete": [
                    "paymentAction": ["id": "payment-action-id"] as [String: Any]
                ] as [String: Any]
            ]
        ])

        do {
            _ = try await sut.signalCustomerActionComplete(.challenge(cardinalAuthenticationJWT: "jwt-value"))
            XCTFail("Expected missingStatus error to be thrown")
        } catch let error as BTPaymentActionError {
            XCTAssertEqual(error, .missingStatus)
        } catch {
            XCTFail("Expected BTPaymentActionError.missingStatus, got \(error)")
        }
    }

    func testSignalCustomerActionComplete_networkError_propagatesError() async {
        let mockError = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError

        do {
            _ = try await sut.signalCustomerActionComplete(.challenge(cardinalAuthenticationJWT: "jwt-value"))
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockError)
        }
    }

    // MARK: - handleNextAction

    func testHandleNextAction_requiresCustomerAction_unrecognizedNextAction_returnsCustomerActionRequired() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "paymentAction": [
                    "id": "payment-action-id",
                    "status": "REQUIRES_CUSTOMER_ACTION",
                    "nextAction": ["__typename": "PaymentActionRedirectUrl"] as [String: Any]
                ] as [String: Any]
            ]
        ])

        let result = try await sut.handleNextAction()

        XCTAssertEqual(result.type, .customerActionRequired)
        XCTAssertEqual(result.id, "payment-action-id")
    }

    func testHandleNextAction_requiresCustomerAction_threeDSecureAuthentication_drivesDDCAndContinues() async throws {
        let mockCardinalSession = MockCardinalSession()
        sut.cardinalSession = mockCardinalSession

        mockAPIClient.cannedResponseBodies = [
            BTJSON(value: [
                "data": [
                    "paymentAction": [
                        "id": "payment-action-id",
                        "status": "REQUIRES_CUSTOMER_ACTION",
                        "nextAction": [
                            "__typename": "PaymentActionThreeDSecureAuthentication",
                            "bin": "401288"
                        ] as [String: Any]
                    ] as [String: Any]
                ]
            ]),
            BTJSON(value: [
                "data": [
                    "signalCustomerActionComplete": [
                        "paymentAction": ["id": "payment-action-id", "status": "READY_FOR_CONFIRMATION"] as [String: Any]
                    ] as [String: Any]
                ]
            ])
        ]

        let result = try await sut.handleNextAction()

        XCTAssertEqual(result.type, .serverActionRequired)
        XCTAssertEqual((result as? BTServerActionRequiredResult)?.serverAction, .confirm)
    }

    func testHandleNextAction_requiresCustomerAction_threeDSecureChallengeAbandoned_returnsThreeDSecureCanceled() async throws {
        let mockCardinalSession = MockCardinalSession()
        mockCardinalSession.actionCodeToDeliver = .cancel
        sut.cardinalSession = mockCardinalSession

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "paymentAction": [
                    "id": "payment-action-id",
                    "status": "REQUIRES_CUSTOMER_ACTION",
                    "nextAction": [
                        "__typename": "PaymentActionThreeDSecureChallenge",
                        "acsUrl": "https://acs.example.com",
                        "challengePayload": "payload-data",
                        "mpiTransactionId": "mpi-1"
                    ] as [String: Any]
                ] as [String: Any]
            ]
        ])

        let result = try await sut.handleNextAction()

        XCTAssertEqual(result.type, .threeDSecureCanceled)
        XCTAssertEqual(result.id, "payment-action-id")
    }

    func testHandleNextAction_readyForConfirmation_returnsServerActionRequiredConfirm() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": ["paymentAction": ["id": "payment-action-id", "status": "READY_FOR_CONFIRMATION"] as [String: Any]]
        ])

        let result = try await sut.handleNextAction()

        let serverActionResult = try XCTUnwrap(result as? BTServerActionRequiredResult)
        XCTAssertEqual(serverActionResult.serverAction, .confirm)
    }

    func testHandleNextAction_succeeded_returnsCompletedResult() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": ["paymentAction": ["id": "payment-action-id", "status": "SUCCEEDED"] as [String: Any]]
        ])

        let result = try await sut.handleNextAction()

        XCTAssertEqual(result.type, .completed)
    }

    func testHandleNextAction_networkError_propagatesError() async {
        let mockError = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError

        do {
            _ = try await sut.handleNextAction()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockError)
        }
    }

    @MainActor
    func testHandleNextAction_calledWhileInFlight_throwsAlreadyInProgress() async {
        sut.isHandlingNextAction = true

        do {
            _ = try await sut.handleNextAction()
            XCTFail("Expected handleNextActionAlreadyInProgress error to be thrown")
        } catch let error as BTPaymentActionError {
            XCTAssertEqual(error, .handleNextActionAlreadyInProgress)
        } catch {
            XCTFail("Expected BTPaymentActionError.handleNextActionAlreadyInProgress, got \(error)")
        }
    }

    func testHandleNextAction_afterPreviousCallCompletes_doesNotThrowAlreadyInProgress() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": ["paymentAction": ["id": "payment-action-id", "status": "SUCCEEDED"] as [String: Any]]
        ])

        _ = try await sut.handleNextAction()
        let result = try await sut.handleNextAction()

        XCTAssertEqual(result.type, .completed)
    }

    func testHandleNextAction_completion_success_returnsResult() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": ["paymentAction": ["id": "payment-action-id", "status": "SUCCEEDED"] as [String: Any]]
        ])

        let expectation = expectation(description: "Completion called")

        sut.handleNextAction { result, error in
            XCTAssertNil(error)
            XCTAssertEqual(result?.type, .completed)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testHandleNextAction_completion_failure_returnsError() {
        let mockError = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)
        mockAPIClient.cannedResponseError = mockError

        let expectation = expectation(description: "Completion called")

        sut.handleNextAction { result, error in
            XCTAssertNil(result)
            XCTAssertEqual(error as? NSError, mockError)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - Helpers

    private func stubResponse(id: String, status: String) {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "setPaymentActionPaymentMethod": [
                    "paymentAction": [
                        "id": id,
                        "status": status
                    ]
                ] as [String: Any]
            ]
        ])
    }
}
