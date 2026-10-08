import XCTest
@testable import BraintreeCore
@testable import BraintreePayPalSavedPaymentMethod

final class CreditMessageContent_Tests: XCTestCase {

    private func result(actionItems: [[String: Any]]) throws -> PayPalCreditMessagingResult {
        try XCTUnwrap(
            PayPalCreditMessagingResult(
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

    /// Copy without a URL would render a link that does nothing when tapped, so it is dropped.
    func testInit_whenTheActionItemHasNoClickURL_dropsTheLearnMoreCopy() throws {
        let content = CreditMessageContent(
            result: try result(actionItems: [["type": "LINK", "text": "Learn more"]])
        )

        XCTAssertNil(content?.learnMore)
        XCTAssertEqual(content?.message, "Or 4 interest-free payments.")
    }

    func testInit_whenThereAreMultipleActionItems_textAndURLComeFromTheSameItem() throws {
        let content = CreditMessageContent(
            result: try result(actionItems: [
                ["type": "IMAGE", "alternative_text": "PayPal"],
                ["type": "LINK", "text": "Learn more", "click_url": "https://example.com/click"]
            ])
        )

        XCTAssertEqual(content?.learnMore?.text, "Learn more")
        XCTAssertEqual(content?.learnMore?.url, URL(string: "https://example.com/click"))
    }
}
