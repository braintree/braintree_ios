import XCTest
import Braintree

// See also BTCard_Internal_Tests
class BTCardSpec: XCTestCase {
    func testInitialization_savesStandardProperties() {
        let card = BTCard(number: "4111111111111111", expirationDate: "12/2038", cvv: "123")

        XCTAssertEqual(card.number!, "4111111111111111")
        XCTAssertEqual(card.expirationDate!, "12/2038")
        XCTAssertNil(card.postalCode)
        XCTAssertEqual(card.cvv!, "123")
    }

    func testInitialization_acceptsNil() {
        let card1 = BTCard(number: nil, expirationDate: "12/2038", cvv: "123")
        let card2 = BTCard(number: "4111111111111111", expirationDate: nil, cvv: "123")
        let card3 = BTCard(number: "4111111111111111", expirationDate: "12/2038", cvv: nil)

        XCTAssertNil(card1.number)
        XCTAssertNil(card2.expirationDate)
        XCTAssertNil(card3.cvv)
    }


    func testInitialization_withoutParameters() {
        let card = BTCard()

        card.number = "4111111111111111"
        card.expirationDate = "12/2038"
        card.cvv = "123"

        XCTAssertEqual(card.number!, "4111111111111111")
        XCTAssertEqual(card.expirationDate!, "12/2038")
        XCTAssertNil(card.postalCode)
        XCTAssertEqual(card.cvv!, "123")
    }

    func testInitialization_fromParameters() {
        let card = BTCard(parameters: ["cvv": "123", "billing_address": ["postal_code": "94949"] ])

        XCTAssertNil(card.number)
        XCTAssertNil(card.expirationDate)
        XCTAssertNil(card.postalCode)
        XCTAssertNil(card.cvv)
    }
}
