import XCTest
import Braintree

class BTCardTokenizationClient_Tests: XCTestCase {
    func testExample() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let configuration = BTConfiguration(key: "CLIENT_KEY")
        let cardTokenizationClient = BTCardTokenizationClient(configuration: configuration, apiClient: FakeAPIClient())

        let card = BTCard(number: "4111111111111111", expirationDate: "12/2038")
        cardTokenizationClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertEqual(tokenizedCard.paymentMethodNonce, FakeAPIClient.fakeNonce)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
