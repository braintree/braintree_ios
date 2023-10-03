import XCTest
@testable import BraintreePayPal

final class BTPayPalAccountNonce_Tests: XCTestCase {

    func testPayPalAccountNonce_returnsPayPalCreditFinancingAmount() {
        let payPalCreditFinancingAmount = BTJSON(value: [
            "currency": "USD",
            "value": "123.45",
        ])

        guard let amount = payPalCreditFinancingAmount.asPayPalCreditFinancingAmount() else {
            XCTFail("Expected amount")
            return
        }
        XCTAssertEqual(amount.currency, "USD")
        XCTAssertEqual(amount.value, "123.45")
    }

    func testPayPalAccountNonce_returnsPayPalCreditFinancing() {
        let payPalCreditFinancing = BTJSON(value: [
            "cardAmountImmutable": false,
            "monthlyPayment": [
                "currency": "USD",
                "value": "123.45",
            ],
            "payerAcceptance": false,
            "term": 3,
            "totalCost": [
                "currency": "ABC",
                "value": "789.01",
            ],
            "totalInterest": [
                "currency": "XYZ",
                "value": "456.78",
            ],
        ] as [String: Any])

        guard let creditFinancing = payPalCreditFinancing.asPayPalCreditFinancing() else {
            XCTFail("Expected credit financing")
            return
        }

        XCTAssertFalse(creditFinancing.cardAmountImmutable)
        guard let monthlyPayment = creditFinancing.monthlyPayment else {
            XCTFail("Expected monthly payment details")
            return
        }
        XCTAssertEqual(monthlyPayment.currency, "USD")
        XCTAssertEqual(monthlyPayment.value, "123.45")

        XCTAssertFalse(creditFinancing.payerAcceptance)
        XCTAssertEqual(creditFinancing.term, 3)

        XCTAssertNotNil(creditFinancing.totalCost)

        guard let totalCost = creditFinancing.totalCost else {
            XCTFail("Expected total cost details")
            return
        }
        XCTAssertEqual(totalCost.currency, "ABC")
        XCTAssertEqual(totalCost.value, "789.01")

        guard let totalInterest = creditFinancing.totalInterest else {
            XCTFail("Expected total interest details")
            return
        }
        XCTAssertEqual(totalInterest.currency, "XYZ")
        XCTAssertEqual(totalInterest.value, "456.78")
    }

    func testPayPalAccountNonce_returnsPayPalAccountNonceWithCreditFinancingOffered() {
        let payPalAccountNonce = BTPayPalAccountNonce(
            json: BTJSON(
                value: [
                    "consumed": false,
                    "description": "jane.doe@example.com",
                    "details": [
                        "email": "jane.doe@example.com",
                        "creditFinancingOffered": [
                            "cardAmountImmutable": true,
                            "monthlyPayment": [
                                "currency": "USD",
                                "value": "13.88",
                            ] as [String: Any],
                            "payerAcceptance": true,
                            "term": 18,
                            "totalCost": [
                                "currency": "USD",
                                "value": "250.00",
                            ],
                            "totalInterest": [
                                "currency": "USD",
                                "value": "0.00",
                            ],
                        ] as [String: Any],
                    ] as [String: Any],
                    "isLocked": false,
                    "nonce": "a-nonce",
                    "securityQuestions": [] as [Any?],
                    "type": "PayPalAccount",
                    "default": true,
                ] as [String: Any]
            )
        )

        XCTAssertEqual(payPalAccountNonce?.nonce, "a-nonce")
        XCTAssertEqual(payPalAccountNonce?.type, "PayPal")
        XCTAssertEqual(payPalAccountNonce?.email, "jane.doe@example.com")
        XCTAssertTrue(payPalAccountNonce!.isDefault)

        guard let creditFinancing = payPalAccountNonce?.creditFinancing else {
            XCTFail("Expected credit financing terms")
            return
        }

        XCTAssertTrue(creditFinancing.cardAmountImmutable)
        guard let monthlyPayment = creditFinancing.monthlyPayment else {
            XCTFail("Expected monthly payment details")
            return
        }
        XCTAssertEqual(monthlyPayment.currency, "USD")
        XCTAssertEqual(monthlyPayment.value, "13.88")

        XCTAssertTrue(creditFinancing.payerAcceptance)
        XCTAssertEqual(creditFinancing.term, 18)

        XCTAssertNotNil(creditFinancing.totalCost)

        guard let totalCost = creditFinancing.totalCost else {
            XCTFail("Expected total cost details")
            return
        }
        XCTAssertEqual(totalCost.currency, "USD")
        XCTAssertEqual(totalCost.value, "250.00")

        guard let totalInterest = creditFinancing.totalInterest else {
            XCTFail("Expected total interest details")
            return
        }
        XCTAssertEqual(totalInterest.currency, "USD")
        XCTAssertEqual(totalInterest.value, "0.00")
    }
}
