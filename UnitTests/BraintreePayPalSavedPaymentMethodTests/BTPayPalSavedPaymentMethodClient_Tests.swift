import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreePayPalSavedPaymentMethod

final class BTPayPalSavedPaymentMethodClient_Tests: XCTestCase {

    let clientToken = TestClientTokenFactory.token(
        withVersion: 3,
        overrides: ["paymentMethodIdJwt": "fake-payment-method-id-jwt"]
    )

    var mockAPIClient: MockAPIClient!
    var sut: BTPayPalSavedPaymentMethodClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: clientToken)
        sut = BTPayPalSavedPaymentMethodClient(authorization: clientToken)
        sut.apiClient = mockAPIClient
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        super.tearDown()
    }

    // MARK: - Request

    func testFetchPaymentMethod_whenStickyFI_postsQueryWithPaymentMethodIDJWT() async throws {
        _ = try? await sut.fetchPaymentMethod(fundingInstrumentType: .stickyFI, merchantAccountID: "fake-merchant-account-id")

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "")
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)

        let parameters = try XCTUnwrap(mockAPIClient.lastPOSTParameters)
        let query = try XCTUnwrap(parameters["query"] as? String)
        let input = try XCTUnwrap((parameters["variables"] as? [String: Any])?["input"] as? [String: Any])

        XCTAssertTrue(query.contains("paypalFundingInstrumentDetails(input: $input)"))
        XCTAssertEqual(input["fundingInstrumentType"] as? String, "STICKY_FI")
        XCTAssertEqual(input["integrationChannel"] as? String, "BT_NATIVE_SDK")
        XCTAssertEqual(input["paymentMethodIdJwt"] as? String, "fake-payment-method-id-jwt")
        XCTAssertEqual(input["merchantAccountId"] as? String, "fake-merchant-account-id")
        XCTAssertNil(input["orderId"])
    }

    func testFetchPaymentMethod_whenFIFromApprovedCheckout_postsQueryWithOrderID() async throws {
        _ = try? await sut.fetchPaymentMethod(fundingInstrumentType: .fiFromApprovedCheckout, orderID: "fake-order-id")

        let parameters = try XCTUnwrap(mockAPIClient.lastPOSTParameters)
        let input = try XCTUnwrap((parameters["variables"] as? [String: Any])?["input"] as? [String: Any])

        XCTAssertEqual(input["fundingInstrumentType"] as? String, "FI_FROM_APPROVED_CHECKOUT")
        XCTAssertEqual(input["orderId"] as? String, "fake-order-id")
        XCTAssertNil(input["paymentMethodIdJwt"])
        XCTAssertNil(input["merchantAccountId"])
    }

    func testFetchPaymentMethod_whenStickyFI_ignoresOrderID() async throws {
        _ = try? await sut.fetchPaymentMethod(fundingInstrumentType: .stickyFI, orderID: "fake-order-id")

        let parameters = try XCTUnwrap(mockAPIClient.lastPOSTParameters)
        let input = try XCTUnwrap((parameters["variables"] as? [String: Any])?["input"] as? [String: Any])

        XCTAssertNil(input["orderId"])
    }

    // MARK: - Response

    func testFetchPaymentMethod_whenPaymentMethodsAreReturned_returnsSummary() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "data": [
                    "paypalFundingInstrumentDetails": [
                        "payer": NSNull(),
                        "paymentMethods": [
                            [
                                "label": "Visa",
                                "imageUrl": "https://example.com/visa.png",
                                "lastDigits": "0199",
                                "type": "CARD",
                                "subtype": "SIGNATURE"
                            ]
                        ]
                    ]
                ]
            ] as [String: Any]
        )

        let summary = try await sut.fetchPaymentMethod(fundingInstrumentType: .stickyFI)
        let paymentMethod = try XCTUnwrap(summary.paymentMethods.first)

        XCTAssertNil(summary.payer)
        XCTAssertEqual(paymentMethod.type, .card)
        XCTAssertEqual(paymentMethod.label, "Visa")
        XCTAssertEqual(paymentMethod.imageURL, URL(string: "https://example.com/visa.png"))
        XCTAssertEqual(paymentMethod.lastDigits, "0199")
        XCTAssertEqual(paymentMethod.subtype, "SIGNATURE")
    }

    func testFetchPaymentMethod_whenOnlyPayerIsReturned_returnsSummaryWithPayer() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "data": [
                    "paypalFundingInstrumentDetails": [
                        "payer": [
                            "email": "buyer@example.com",
                            "editable": true
                        ],
                        "paymentMethods": []
                    ]
                ]
            ] as [String: Any]
        )

        let summary = try await sut.fetchPaymentMethod(fundingInstrumentType: .stickyFI)

        XCTAssertEqual(summary.payer?.email, "buyer@example.com")
        XCTAssertEqual(summary.payer?.isEditable, true)
        XCTAssertTrue(summary.paymentMethods.isEmpty)
    }

    // MARK: - Errors

    func testFetchPaymentMethod_whenAuthorizationIsATokenizationKey_throwsInvalidAuthorization() async {
        let sut = BTPayPalSavedPaymentMethodClient(authorization: "sandbox_merchant_1234567890abc")

        do {
            _ = try await sut.fetchPaymentMethod(fundingInstrumentType: .stickyFI)
            XCTFail("Expected an error")
        } catch let error as BTPayPalSavedPaymentMethodError {
            XCTAssertEqual(error, .invalidAuthorization)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchPaymentMethod_whenStickyFIAndClientTokenHasNoJWT_throwsMissingPaymentMethodIDJWT() async {
        let clientTokenWithoutJWT = TestClientTokenFactory.token(withVersion: 3)
        sut = BTPayPalSavedPaymentMethodClient(authorization: clientTokenWithoutJWT)
        sut.apiClient = MockAPIClient(authorization: clientTokenWithoutJWT)

        do {
            _ = try await sut.fetchPaymentMethod(fundingInstrumentType: .stickyFI)
            XCTFail("Expected an error")
        } catch let error as BTPayPalSavedPaymentMethodError {
            XCTAssertEqual(error, .missingPaymentMethodIDJWT)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchPaymentMethod_whenFIFromApprovedCheckoutWithoutOrderID_throwsMissingOrderID() async {
        do {
            _ = try await sut.fetchPaymentMethod(fundingInstrumentType: .fiFromApprovedCheckout)
            XCTFail("Expected an error")
        } catch let error as BTPayPalSavedPaymentMethodError {
            XCTAssertEqual(error, .missingOrderID)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchPaymentMethod_whenBodyIsNil_throwsEmptyBodyReturned() async {
        mockAPIClient.cannedResponseBody = nil

        do {
            _ = try await sut.fetchPaymentMethod(fundingInstrumentType: .stickyFI)
            XCTFail("Expected an error")
        } catch let error as BTPayPalSavedPaymentMethodError {
            XCTAssertEqual(error, .emptyBodyReturned)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchPaymentMethod_whenFundingInstrumentDetailsIsNull_throwsFailedToParseSummary() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": ["paypalFundingInstrumentDetails": NSNull()]])

        do {
            _ = try await sut.fetchPaymentMethod(fundingInstrumentType: .stickyFI)
            XCTFail("Expected an error")
        } catch let error as BTPayPalSavedPaymentMethodError {
            XCTAssertEqual(error, .failedToParseSummary)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchPaymentMethod_whenTheRequestFails_propagatesTheError() async {
        let cannedError = NSError(domain: "com.example.error", code: 1)
        mockAPIClient.cannedResponseError = cannedError

        do {
            _ = try await sut.fetchPaymentMethod(fundingInstrumentType: .stickyFI)
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as NSError, cannedError)
        }
    }
}
