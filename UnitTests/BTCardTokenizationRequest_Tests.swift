import XCTest

// See also BTCard_Internal_Tests
class BTCard_Tests: XCTestCase {
    func testInitialization_savesStandardProperties() {
        let card = BTCard(number: "4111111111111111", expirationMonth:"12", expirationYear:"2038", cvv: "123")

        XCTAssertEqual(card.number!, "4111111111111111")
        XCTAssertEqual(card.expirationMonth!, "12")
        XCTAssertEqual(card.expirationYear!, "2038")
        XCTAssertNil(card.postalCode)
        XCTAssertEqual(card.cvv!, "123")
    }

    func testInitialization_acceptsNilCvv() {
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        XCTAssertNil(card.cvv)
    }

    func testInitialization_withoutParameters() {
        let card = BTCard()

        card.number = "4111111111111111"
        card.expirationMonth = "12"
        card.expirationYear = "2038"
        card.cvv = "123"

        XCTAssertEqual(card.number!, "4111111111111111")
        XCTAssertEqual(card.expirationMonth!, "12")
        XCTAssertEqual(card.expirationYear!, "2038")
        XCTAssertNil(card.postalCode)
        XCTAssertEqual(card.cvv!, "123")
    }

    func testInitialization_fromParameters() {
        let card = BTCard(parameters: ["cvv": "123", "billing_address": ["postal_code": "94949"] ])

        XCTAssertNil(card.number)
        XCTAssertNil(card.expirationMonth)
        XCTAssertNil(card.expirationYear)
        XCTAssertNil(card.postalCode)
        XCTAssertNil(card.cvv)
    }
}
