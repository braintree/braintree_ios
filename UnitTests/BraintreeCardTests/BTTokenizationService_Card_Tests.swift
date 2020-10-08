import XCTest
import BraintreeTestShared

class BTTokenizationService_Card_Tests: XCTestCase {
    func testSingleton_hasCardTypeAvailable() {
        let sharedService = BTTokenizationService.shared()

        XCTAssertTrue(sharedService.isTypeAvailable("Card"))
    }

    func testSingleton_canTokenizeCards() {
        let sharedService = BTTokenizationService.shared()
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2020", cvv: "123")
        let stubAPIClient = MockAPIClient(authorization: "development_fake_key")!
        stubAPIClient.cannedResponseBody = BTJSON(value: [
            "creditCards": [
                [
                    "nonce": "a-nonce",
                    "description": "A card"
                ]
            ]
        ])

        let expectation = self.expectation(description: "Card is tokenized")
        sharedService.tokenizeType("Card", options: card.parameters() as? [String : AnyObject], with: stubAPIClient) { (cardNonce, error) -> Void in
            XCTAssertEqual(cardNonce?.nonce, "a-nonce")
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
