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

    func testInitialization_acceptsNil() {
        let card1 = BTCard(number: nil, expirationMonth:"12", expirationYear: "2038", cvv: "123")
        let card2 = BTCard(number: "4111111111111111", expirationMonth: nil, expirationYear: "2038", cvv: "123")
        let card3 = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: nil, cvv: "123")
        let card4 = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        XCTAssertNil(card1.number)
        XCTAssertNil(card2.expirationMonth)
        XCTAssertNil(card3.expirationYear)
        XCTAssertNil(card4.cvv)
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
