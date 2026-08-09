import XCTest
@testable import BraintreeCore
@testable import BraintreePayPalSavedPaymentMethod

final class BTPayPalSavedPaymentMethodSummary_Tests: XCTestCase {

    func testInit_whenPaymentMethodsArePresent_parsesEveryField() throws {
        let json = BTJSON(
            value: [
                "payer": NSNull(),
                "paymentMethods": [
                    [
                        "label": "CREDIT UNION 1",
                        "imageUrl": "https://www.paypalobjects.com/ui-web/money-icons/bank/generic_bank.png",
                        "lastDigits": "3357",
                        "type": "BANK",
                        "subtype": NSNull()
                    ]
                ]
            ] as [String: Any]
        )

        let summary = try XCTUnwrap(BTPayPalSavedPaymentMethodSummary(json: json))
        let paymentMethod = try XCTUnwrap(summary.paymentMethods.first)

        XCTAssertNil(summary.payer)
        XCTAssertEqual(paymentMethod.type, .bank)
        XCTAssertEqual(paymentMethod.label, "CREDIT UNION 1")
        XCTAssertEqual(
            paymentMethod.imageURL,
            URL(string: "https://www.paypalobjects.com/ui-web/money-icons/bank/generic_bank.png")
        )
        XCTAssertEqual(paymentMethod.lastDigits, "3357")
        XCTAssertNil(paymentMethod.subtype)
    }

    func testInit_whenTypeIsUnrecognized_leavesTypeNilAndKeepsTheRestOfTheInstrument() throws {
        let json = BTJSON(
            value: [
                "paymentMethods": [
                    [
                        "label": "Visa",
                        "lastDigits": "0199",
                        "type": "SOME_FUTURE_TYPE"
                    ]
                ]
            ] as [String: Any]
        )

        let paymentMethod = try XCTUnwrap(BTPayPalSavedPaymentMethodSummary(json: json)?.paymentMethods.first)

        XCTAssertNil(paymentMethod.type)
        XCTAssertEqual(paymentMethod.label, "Visa")
        XCTAssertEqual(paymentMethod.lastDigits, "0199")
    }

    func testInit_whenOnlyPayerIsPresent_parsesPayerAndReturnsNoPaymentMethods() throws {
        let json = BTJSON(
            value: [
                "payer": [
                    "email": "buyer@example.com",
                    "editable": true
                ],
                "paymentMethods": []
            ] as [String: Any]
        )

        let summary = try XCTUnwrap(BTPayPalSavedPaymentMethodSummary(json: json))

        XCTAssertEqual(summary.payer?.email, "buyer@example.com")
        XCTAssertEqual(summary.payer?.isEditable, true)
        XCTAssertTrue(summary.paymentMethods.isEmpty)
    }

    func testInit_whenPayerOmitsEditable_defaultsToNotEditable() throws {
        let json = BTJSON(value: ["payer": ["email": "buyer@example.com"]])

        let payer = try XCTUnwrap(BTPayPalSavedPaymentMethodSummary(json: json)?.payer)

        XCTAssertEqual(payer.isEditable, false)
    }

    func testInit_whenPayloadIsEmpty_returnsEmptySummary() throws {
        let summary = try XCTUnwrap(BTPayPalSavedPaymentMethodSummary(json: BTJSON(value: [:] as [String: Any])))

        XCTAssertNil(summary.payer)
        XCTAssertTrue(summary.paymentMethods.isEmpty)
    }

    func testInit_whenPayloadIsNotAnObject_returnsNil() {
        XCTAssertNil(BTPayPalSavedPaymentMethodSummary(json: BTJSON(value: NSNull())))
    }
}
