import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreePayPalSavedPaymentMethod

final class BTPayPalCreditMessaging_Tests: XCTestCase {

    let clientToken = TestClientTokenFactory.token(withVersion: 3)

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

    func testFetchCreditPresentmentMessages_postsTreatmentARequestToThePayPalAPI() async throws {
        _ = try? await sut.fetchCreditPresentmentMessages(amount: "55.00", currencyCode: "USD")

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v2/credit/fetch-presentment-messages")
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .payPalAPI)

        let parameters = try XCTUnwrap(mockAPIClient.lastPOSTParameters)
        let flowContext = try XCTUnwrap(parameters["flow_context"] as? [String: Any])
        let placement = try XCTUnwrap((parameters["message_placements"] as? [[String: Any]])?.first)
        let amount = try XCTUnwrap(placement["amount"] as? [String: Any])

        XCTAssertEqual(flowContext["channel"] as? String, "MOBILE_APP")
        XCTAssertEqual(flowContext["flow_specifier"] as? String, "EARLY_PRESENTMENT")
        XCTAssertEqual(flowContext["attributes"] as? [String], ["BRAND_BRAINTREE", "EXPERIENCE_IOS_SDK"])
        XCTAssertEqual(amount["value"] as? String, "55.00")
        XCTAssertEqual(amount["currency_code"] as? String, "USD")
        XCTAssertEqual(
            placement["content_attributes"] as? [String],
            ["ALTERNATIVE_PREFIX_UPPERCASE_OR", "MESSAGE_LENGTH_COMPACT"]
        )
    }

    // MARK: - Response

    func testFetchCreditPresentmentMessages_whenAMessageIsReturned_returnsTheContentBlocksInOrder() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(value: Self.messagesResponse)

        let result = try await sut.fetchCreditPresentmentMessages(amount: "55.00", currencyCode: "USD")

        XCTAssertEqual(result.messageID, "1d8435e1-61ee-4585-8b05-a989de205c3e")
        XCTAssertEqual(result.messageType, "PLST_SQ")
        XCTAssertEqual(result.impressionURL, URL(string: "https://example.com/impression"))

        XCTAssertEqual(result.mainItems.count, 3)
        XCTAssertEqual(result.mainItems[0].type, .text)
        XCTAssertEqual(result.mainItems[0].text, "Or 4 interest-free payments of $13.75 with ")
        XCTAssertEqual(result.mainItems[1].type, .image)
        XCTAssertEqual(result.mainItems[1].name, "paypal_logo")
        XCTAssertEqual(result.mainItems[1].alternativeText, "PayPal")
        XCTAssertEqual(
            result.mainItems[1].sourceURL,
            URL(string: "https://www.paypalobjects.com/upstream/assets/logos/v2/paypal_badge_inline.svg")
        )
        XCTAssertEqual(result.mainItems[2].type, .text)
        XCTAssertEqual(result.mainItems[2].text, ".")

        XCTAssertTrue(result.disclaimerItems.isEmpty)

        let learnMore = try XCTUnwrap(result.actionItems.first)
        XCTAssertEqual(learnMore.type, .link)
        XCTAssertEqual(learnMore.text, "Learn more")
        XCTAssertEqual(learnMore.clickURL, URL(string: "https://example.com/click"))
        XCTAssertTrue(learnMore.isEmbeddable)
    }

    func testFetchCreditPresentmentMessages_whenAnItemTypeIsUnrecognized_keepsTheRestOfTheItem() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [
                "messages": [
                    [
                        "preferred_message": [
                            "content": ["main_items": [["type": "VIDEO", "text": "Or "]]]
                        ]
                    ]
                ]
            ] as [String: Any]
        )

        let result = try await sut.fetchCreditPresentmentMessages(amount: "55.00", currencyCode: "USD")

        XCTAssertNil(result.mainItems[0].type)
        XCTAssertEqual(result.mainItems[0].text, "Or ")
    }

    func testFetchCreditPresentmentMessages_whenTheMessageHasNoContent_returnsEmptyItems() async throws {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: ["messages": [["preferred_message": ["id": "fake-id"]]]] as [String: Any]
        )

        let result = try await sut.fetchCreditPresentmentMessages(amount: "55.00", currencyCode: "USD")

        XCTAssertEqual(result.messageID, "fake-id")
        XCTAssertNil(result.impressionURL)
        XCTAssertTrue(result.mainItems.isEmpty)
        XCTAssertTrue(result.disclaimerItems.isEmpty)
        XCTAssertTrue(result.actionItems.isEmpty)
    }

    // MARK: - Errors

    func testFetchCreditPresentmentMessages_whenAuthorizationIsATokenizationKey_throwsInvalidAuthorization() async {
        let sut = BTPayPalSavedPaymentMethodClient(authorization: "sandbox_merchant_1234567890abc")

        do {
            _ = try await sut.fetchCreditPresentmentMessages(amount: "55.00", currencyCode: "USD")
            XCTFail("Expected an error")
        } catch let error as BTPayPalSavedPaymentMethodError {
            XCTAssertEqual(error, .invalidAuthorization)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchCreditPresentmentMessages_whenNoMessagesAreReturned_throwsMissingPreferredMessage() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["messages": []] as [String: Any])

        do {
            _ = try await sut.fetchCreditPresentmentMessages(amount: "55.00", currencyCode: "USD")
            XCTFail("Expected an error")
        } catch let error as BTPayPalSavedPaymentMethodError {
            XCTAssertEqual(error, .missingPreferredMessage)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// PayPal answers `204 No Content` when it has nothing to present, which `BTHTTP` surfaces as an empty `BTJSON`.
    func testFetchCreditPresentmentMessages_whenTheResponseIsEmpty_throwsMissingPreferredMessage() async {
        mockAPIClient.cannedResponseBody = BTJSON()

        do {
            _ = try await sut.fetchCreditPresentmentMessages(amount: "55.00", currencyCode: "USD")
            XCTFail("Expected an error")
        } catch let error as BTPayPalSavedPaymentMethodError {
            XCTAssertEqual(error, .missingPreferredMessage)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchCreditPresentmentMessages_whenBodyIsNil_throwsEmptyBodyReturned() async {
        mockAPIClient.cannedResponseBody = nil

        do {
            _ = try await sut.fetchCreditPresentmentMessages(amount: "55.00", currencyCode: "USD")
            XCTFail("Expected an error")
        } catch let error as BTPayPalSavedPaymentMethodError {
            XCTAssertEqual(error, .emptyBodyReturned)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchCreditPresentmentMessages_whenTheRequestFails_propagatesTheError() async {
        let cannedError = NSError(domain: "com.example.error", code: 1)
        mockAPIClient.cannedResponseError = cannedError

        do {
            _ = try await sut.fetchCreditPresentmentMessages(amount: "55.00", currencyCode: "USD")
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as NSError, cannedError)
        }
    }

    // MARK: - Helpers

    /// A `PLST_SQ` payload as returned for a $55.00 order, with the tracking URLs stubbed.
    private static let messagesResponse: [String: Any] = [
        "messages": [
            [
                "preferred_message": [
                    "id": "1d8435e1-61ee-4585-8b05-a989de205c3e",
                    "type": "PLST_SQ",
                    "analytics": ["impression_url": "https://example.com/impression"],
                    "content": [
                        "main_items": [
                            ["type": "TEXT", "text": "Or 4 interest-free payments of $13.75 with "],
                            [
                                "type": "IMAGE",
                                "name": "paypal_logo",
                                "alternative_text": "PayPal",
                                "source_url": "https://www.paypalobjects.com/upstream/assets/logos/v2/paypal_badge_inline.svg"
                            ],
                            ["type": "TEXT", "text": "."]
                        ],
                        "action_items": [
                            [
                                "type": "LINK",
                                "text": "Learn more",
                                "click_url": "https://example.com/click",
                                "embeddable": true
                            ]
                        ]
                    ]
                ],
                "selection_reasons": [
                    ["code": "DEFAULT_PREFERRED", "description": "The standard messages have been returned."]
                ]
            ]
        ]
    ]
}
