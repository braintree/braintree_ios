import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreePaymentActions

private struct MockPaymentActionRequest: BTPaymentActionRequest {
    let paymentActionID: String
    let paymentMethod: [String: String]

    init(paymentActionID: String = "payment-action-id", paymentMethod: [String: String] = ["type": "MOCK"]) {
        self.paymentActionID = paymentActionID
        self.paymentMethod = paymentMethod
    }

    func paymentMethodParameters() -> any Encodable {
        paymentMethod
    }
}

class BTPaymentActionsClient_Tests: XCTestCase {

    let authorization: String = "development_tokenization_key"
    var mockAPIClient: MockAPIClient!
    var sut: BTPaymentActionsClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: authorization)
        sut = BTPaymentActionsClient(authorization: authorization)
        sut.apiClient = mockAPIClient
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

        let request = MockPaymentActionRequest(paymentActionID: "payment-action-123")
        _ = try await sut.submitForPaymentAction(request)

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)

        let body = SetPaymentActionPaymentMethodGraphQLBody(request: request)
        let expectedDictionary = try! body.toDictionary()

        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail("Expected POST parameters")
            return
        }
        XCTAssertEqual(lastPostParameters as NSObject, expectedDictionary as NSObject)
    }

    // MARK: - Success

    func testSubmitForPaymentAction_success_returnsStatus() async throws {
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

        let status = try await sut.submitForPaymentAction(MockPaymentActionRequest())
        XCTAssertEqual(status, .readyForConfirmation)
    }

    func testSubmitForPaymentAction_unknownServerStatus_mapsToUnknown() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "setPaymentActionPaymentMethod": [
                    "paymentAction": [
                        "id": "payment-action-id",
                        "status": "SOME_NEW_SERVER_STATUS"
                    ]
                ] as [String: Any]
            ]
        ])

        let status = try await sut.submitForPaymentAction(MockPaymentActionRequest())
        XCTAssertEqual(status, .unknown)
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

    // MARK: - internal setPaymentActionPaymentMethod

    func testSetPaymentActionPaymentMethod_returnsFullResult() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "setPaymentActionPaymentMethod": [
                    "paymentAction": [
                        "id": "payment-action-id",
                        "status": "SUCCEEDED"
                    ]
                ] as [String: Any]
            ]
        ])

        let request = MockPaymentActionRequest()
        let body = SetPaymentActionPaymentMethodGraphQLBody(request: request)
        let result = try await sut.setPaymentActionPaymentMethod(body)

        XCTAssertEqual(result.id, "payment-action-id")
        XCTAssertEqual(result.status, .succeeded)
    }
}
