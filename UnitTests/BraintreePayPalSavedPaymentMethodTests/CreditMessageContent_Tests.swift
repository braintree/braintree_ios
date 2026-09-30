import XCTest
@testable import BraintreeCore
@testable import BraintreePayPalSavedPaymentMethod

final class CreditMessageContent_Tests: XCTestCase {

    private func result(actionItems: [[String: Any]]) throws -> BTPayPalCreditMessagingResult {
        try XCTUnwrap(
            BTPayPalCreditMessagingResult(
                json: BTJSON(
                    value: [
                        "messages": [
                            [
                                "preferred_message": [
                                    "content": [
                                        "main_items": [["type": "TEXT", "text": "Or 4 interest-free payments."]],
                                        "action_items": actionItems
                                    ]
                                ]
                            ]
                        ]
                    ] as [String: Any]
                )
            )
        )
    }

    func testInit_whenTheActionItemHasAClickURL_keepsTheLearnMoreCopy() throws {
        let content = CreditMessageContent(
            result: try result(actionItems: [
                ["type": "LINK", "text": "Learn more", "click_url": "https://example.com/click"]
            ])
        )

        XCTAssertEqual(content?.learnMoreText, "Learn more")
        XCTAssertEqual(content?.learnMoreURL, URL(string: "https://example.com/click"))
    }

    /// Copy without a URL would render a link that does nothing when tapped, so it is dropped.
    func testInit_whenTheActionItemHasNoClickURL_dropsTheLearnMoreCopy() throws {
        let content = CreditMessageContent(
            result: try result(actionItems: [["type": "LINK", "text": "Learn more"]])
        )

        XCTAssertNil(content?.learnMoreText)
        XCTAssertNil(content?.learnMoreURL)
        XCTAssertEqual(content?.message, "Or 4 interest-free payments.")
    }
}
