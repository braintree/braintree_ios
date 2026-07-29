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

    func testSetPaymentMethod_postsToGraphQLEndpoint() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_123", status: "SUCCEEDED")

        _ = try await sut.setPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "")
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
    }

    // MARK: - Success Cases

    func testSetPaymentMethod_whenStatusSucceeded_returnsResult() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_123", status: "SUCCEEDED")

        let result = try await sut.setPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.id, "pa_123")
        XCTAssertEqual(result.status, .succeeded)
    }

    func testSetPaymentMethod_whenStatusReadyForConfirmation_mapsCorrectly() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_456", status: "READY_FOR_CONFIRMATION")

        let result = try await sut.setPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .readyForConfirmation)
    }

    func testSetPaymentMethod_whenStatusRequiresCapture_mapsCorrectly() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_789", status: "REQUIRES_CAPTURE")

        let result = try await sut.setPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .requiresCapture)
    }

    func testSetPaymentMethod_whenStatusRequiresPaymentMethod_mapsCorrectly() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_000", status: "REQUIRES_PAYMENT_METHOD")

        let result = try await sut.setPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .requiresPaymentMethod)
    }

    func testSetPaymentMethod_whenStatusIsUnrecognized_mapsToUnknownWithoutThrowing() async throws {
        mockAPIClient.cannedResponseBody = paymentActionResponse(id: "pa_111", status: "SOME_FUTURE_STATUS")

        let result = try await sut.setPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .unknown)
        XCTAssertEqual(result.id, "pa_111")
    }

    func testSetPaymentMethod_whenPaymentActionIsMissingEntirely_doesNotThrowAndReturnsUnknown() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": ["setPaymentActionPaymentMethod": [:]] as [String: Any]])

        let result = try await sut.setPaymentMethod(StubGraphQLBody())

        XCTAssertEqual(result.status, .unknown)
        XCTAssertEqual(result.id, "")
    }

    // MARK: - Failure Cases

    func testSetPaymentMethod_when422ClientError_throwsCustomerInputInvalidWithMessage() async {
        let stubJSONResponse = BTJSON(
            value: ["error": ["message": "Card is invalid"]] as [String: Any]
        )
        let userInfo: [String: Any] = [
            BTCoreConstants.urlResponseKey: HTTPURLResponse(
                url: URL(string: "http://fake")!,
                statusCode: 422,
                httpVersion: nil,
                headerFields: nil
            )!,
            BTCoreConstants.jsonResponseBodyKey: stubJSONResponse
        ]
        mockAPIClient.cannedResponseError = BTHTTPError.clientError(userInfo) as NSError

        do {
            _ = try await sut.setPaymentMethod(StubGraphQLBody())
            XCTFail("Expected error to be thrown")
        } catch let error as BTPaymentActionsError {
            XCTAssertEqual(error, BTPaymentActionsError.customerInputInvalid([:]))
            if case .customerInputInvalid(let userInfo) = error {
                XCTAssertEqual(userInfo[NSLocalizedDescriptionKey] as? String, "Card is invalid")
            }
        } catch {
            XCTFail("Expected BTPaymentActionsError.customerInputInvalid, got \(error)")
        }
    }

    func testSetPaymentMethod_whenNon422Error_propagatesUnderlyingErrorUnchanged() async {
        let stubError = NSError(domain: BTHTTPError.errorDomain, code: BTHTTPError.clientError([:]).errorCode, userInfo: nil)
        mockAPIClient.cannedResponseError = stubError

        do {
            _ = try await sut.setPaymentMethod(StubGraphQLBody())
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
