import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared

private struct StubGraphQLBody: BTGraphQLEncodableBody {
    struct Variables: Encodable {
        let input: String
    }

    var query: String = "mutation StubMutation { stub }"
    var variables: Variables = Variables(input: "stub-input")
}

class BTPaymentActionsService_Tests: XCTestCase {

    let authorization: String = "development_tokenization_key"
    var mockAPIClient: MockAPIClient!
    var sut: BTPaymentActionsService!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: authorization)
        sut = BTPaymentActionsService(apiClient: mockAPIClient)
    }

    // MARK: - Request Shape

    func testSetPaymentActionPaymentMethod_postsToGraphQLEndpoint() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_123", status: "SUCCEEDED")

        _ = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "")
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
    }

    // MARK: - Success Cases

    func testSetPaymentActionPaymentMethod_whenStatusSucceeded_returnsResult() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_123", status: "SUCCEEDED")

        let result = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.id, "pa_123")
        XCTAssertEqual(result.status, .succeeded)
    }

    func testSetPaymentActionPaymentMethod_whenStatusReadyForConfirmation_mapsCorrectly() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_456", status: "READY_FOR_CONFIRMATION")

        let result = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .readyForConfirmation)
    }

    func testSetPaymentActionPaymentMethod_whenStatusRequiresCapture_mapsCorrectly() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_789", status: "REQUIRES_CAPTURE")

        let result = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .requiresCapture)
    }

    func testSetPaymentActionPaymentMethod_whenStatusRequiresPaymentMethod_mapsCorrectly() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_000", status: "REQUIRES_PAYMENT_METHOD")

        let result = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .requiresPaymentMethod)
    }

    func testSetPaymentActionPaymentMethod_whenStatusCanceled_mapsCorrectly() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_222", status: "CANCELED")

        let result = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .canceled)
    }

    func testSetPaymentActionPaymentMethod_whenStatusExpired_mapsCorrectly() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_333", status: "EXPIRED")

        let result = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .expired)
    }

    func testSetPaymentActionPaymentMethod_whenStatusIsUnrecognized_mapsToUnknownWithoutThrowing() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_111", status: "SOME_FUTURE_STATUS")

        let result = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .unknown)
        XCTAssertEqual(result.id, "pa_111")
    }

    // MARK: - Failure Cases

    func testSetPaymentActionPaymentMethod_whenPaymentActionIsMissingEntirely_throws() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": ["setPaymentActionPaymentMethod": [:]] as [String: Any]])

        do {
            _ = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())
            XCTFail("Expected error to be thrown")
        } catch {
            // TODO: assert against the finalized error type/case once the error shape is defined.
        }
    }

    func testSetPaymentActionPaymentMethod_whenIDIsMissing_throws() async {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "data": [
                    "setPaymentActionPaymentMethod": [
                        "paymentAction": [
                            "status": "SUCCEEDED"
                        ]
                    ]
                ]
            ] as [String: Any]
        )

        do {
            _ = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())
            XCTFail("Expected error to be thrown")
        } catch {
            // TODO: assert against the finalized error type/case once the error shape is defined.
        }
    }

    func testSetPaymentActionPaymentMethod_whenIDIsEmptyString_throws() async {
        // An empty string id is treated the same as a missing id -- there's no valid flow where
        // an empty PA id is usable downstream.
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "", status: "SUCCEEDED")

        do {
            _ = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())
            XCTFail("Expected error to be thrown")
        } catch {
            // TODO: assert against the finalized error type/case once the error shape is defined.
        }
    }

    func testSetPaymentActionPaymentMethod_whenStatusIsMissing_throws() async {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "data": [
                    "setPaymentActionPaymentMethod": [
                        "paymentAction": [
                            "id": "pa_123"
                        ]
                    ]
                ]
            ] as [String: Any]
        )

        do {
            _ = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())
            XCTFail("Expected error to be thrown")
        } catch {
            // TODO: assert against the finalized error type/case once the error shape is defined.
        }
    }

    func testSetPaymentActionPaymentMethod_whenNetworkErrorThrown_propagatesUnderlyingErrorUnchanged() async {
        // BTGraphQLHTTP already parses top-level GraphQL `errors` and HTTP-level failures into a
        // thrown error before this method ever sees a response body, so this method does no
        // custom error handling of its own -- errors from apiClient.post should propagate as-is.
        let stubError = NSError(domain: BTHTTPError.errorDomain, code: BTHTTPError.clientError([:]).errorCode, userInfo: nil)
        mockAPIClient.cannedResponseError = stubError

        do {
            _ = try await sut.setPaymentActionPaymentMethod(StubGraphQLBody())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, stubError)
        }
    }

    // MARK: - Helpers

    private func paymentActionResponse(id: String, status: String) -> BTJSON {
        BTJSON(
            value: [
                "data": [
                    "setPaymentActionPaymentMethod": [
                        "paymentAction": [
                            "id": id,
                            "status": status
                        ]
                    ]
                ]
            ] as [String: Any]
        )
    }
}
