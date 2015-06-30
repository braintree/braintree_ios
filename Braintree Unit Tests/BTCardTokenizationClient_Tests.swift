import XCTest
import Braintree

class FakeAPIClient : BTAPIClient {
    static let fakeNonce = "fake-nonce"
    static let baseUrl = NSURL(string: "https://example.com")!

    override func POST(endpoint: String!, parameters: BTJSON!, completion completionBlock: BTAPIClientCompletionBlock!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let json = BTJSON(value: ["creditCards": [["nonce": FakeAPIClient.fakeNonce, "description": "Visa Ending in 11"]]])
            let response = NSHTTPURLResponse(URL: FakeAPIClient.baseUrl, statusCode: 201, HTTPVersion: "1.1", headerFields: nil)
            let error : NSError? = nil
            completionBlock(json, response, error)
        }
    }
}

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
