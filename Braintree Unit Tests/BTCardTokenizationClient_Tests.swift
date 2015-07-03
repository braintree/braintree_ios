import XCTest
import Braintree

class BTCardTokenizationClient_Tests: XCTestCase {

    func testTokenization_sendsDataToClientAPI() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let apiClient = FakeAPIClient()
        let configuration = try! BTConfiguration(clientKey: "sandbox_abcd_fake_merchant_id")
        configuration.clientApiHTTP = apiClient
        let cardTokenizationClient = BTCardTokenizationClient(configuration: configuration)

        let card = BTCard(number: "4111111111111111", expirationDate: "12/2038", cvv: nil)

        cardTokenizationClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertEqual(apiClient.lastRequest!.endpoint, "v1/payment_methods/credit_cards")
            XCTAssertEqual(apiClient.lastRequest!.method, "POST")
            if let meta = apiClient.lastRequest!.parameters["_meta"] as? [String:String] {
                XCTAssertEqual(meta["source"]!, "unknown")
                XCTAssertEqual(meta["integration"]!, "custom")
                XCTAssertNotNil(meta["sessionId"])
            } else {
                XCTFail()
            }

            if let cardParameters = apiClient.lastRequest!.parameters["credit_card"] as? [String:String] {
                XCTAssertEqual(cardParameters["number"]!, "4111111111111111")
                XCTAssertEqual(cardParameters["expiration_date"]!, "12/2038")
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testTokenization_success_returnsTokenizedCard() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let configuration = try! BTConfiguration(clientKey: "sandbox_abcd_fake_merchant_id")
        configuration.clientApiHTTP = FakeAPIClient()
        let cardTokenizationClient = BTCardTokenizationClient(configuration: configuration)

        let card = BTCard(number: "4111111111111111", expirationDate: "12/2038", cvv: nil)

        cardTokenizationClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertEqual(tokenizedCard.paymentMethodNonce, FakeAPIClient.fakeNonce)
            XCTAssertEqual(tokenizedCard.localizedDescription, "Visa ending in 11")
            XCTAssertEqual(tokenizedCard.lastTwo!, "11")
            XCTAssertNil(tokenizedCard.threeDSecureInfo)
            XCTAssertEqual(tokenizedCard.cardNetwork, .Visa)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)

    }

    func testTokenization_errorResponse_returnsError() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let configuration = try! BTConfiguration(clientKey: "sandbox_abcd_fake_merchant_id")
        configuration.clientApiHTTP = ApplicationErrorAPIClient()
        let cardTokenizationClient = BTCardTokenizationClient(configuration: configuration)

        let card = BTCard(number: "4111111111111111", expirationDate: "12/2038", cvv: nil)

        cardTokenizationClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error!.domain, BTCardTokenizationClientErrorDomain)
            XCTAssertEqual(error!.code, BTCardTokenizationClientErrorCode.FatalError.rawValue)

            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testTokenization_failure_returnsError() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let configuration = try! BTConfiguration(clientKey: "sandbox_abcd_fake_merchant_id")
        configuration.clientApiHTTP = ErrorAPIClient()
        let cardTokenizationClient = BTCardTokenizationClient(configuration: configuration)

        let card = BTCard(number: "4111111111111111", expirationDate: "12/2038", cvv: nil)

        cardTokenizationClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error!, ErrorAPIClient.error)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}

/***** HELPERS ******/

class FakeAPIClient : BTHTTP {
    struct Request {
        let endpoint : String
        let method : String
        let parameters : [NSObject:AnyObject]
    }

    static let fakeNonce = "fake-nonce"
    var lastRequest : Request?

    override func POST(endpoint: String!, parameters: [NSObject : AnyObject]!, completion completionBlock: BTHTTPCompletionBlock!) {
        self.lastRequest = Request(endpoint: endpoint, method: "POST", parameters: parameters)

        let response  = NSHTTPURLResponse(URL: NSURL(string: endpoint)!, statusCode: 202, HTTPVersion: nil, headerFields: nil)!

        completionBlock(BTJSON(value: [
            "creditCards": [
                [
                    "nonce": FakeAPIClient.fakeNonce,
                    "description": "Visa ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "visa"] ] ] ]), response, nil)
    }
}

class ApplicationErrorAPIClient : BTHTTP {
    static let error = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)

    override func POST(endpoint: String!, parameters: [NSObject : AnyObject]!, completion completionBlock: BTHTTPCompletionBlock!) {
        let body = BTJSON()
        let response  = NSHTTPURLResponse(URL: NSURL(string: endpoint)!, statusCode: 503, HTTPVersion: nil, headerFields: nil)!
        completionBlock(body, response, nil)
    }
}

class ErrorAPIClient : BTHTTP {
    static let error = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)
    
    override func POST(endpoint: String!, parameters: [NSObject : AnyObject]!, completion completionBlock: BTHTTPCompletionBlock!) {
        completionBlock(nil, nil, ErrorAPIClient.error)
    }
}
