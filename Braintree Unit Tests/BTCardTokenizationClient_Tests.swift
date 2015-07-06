import XCTest
import Braintree

class BTCardTokenizationClient_Tests: XCTestCase {

    func testTokenization_sendsDataToClientAPI() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let fakeHTTP = FakeHTTP()
        let apiClient = try! BTAPIClient(clientKey: "sandbox_abcd_fake_merchant_id")
        apiClient.http = fakeHTTP
        let cardTokenizationClient = BTCardTokenizationClient(APIClient: apiClient)

        let card = BTCardTokenizationRequest(number: "4111111111111111", expirationDate: "12/2038", cvv: nil)

        cardTokenizationClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertEqual(fakeHTTP.lastRequest!.endpoint, "v1/payment_methods/credit_cards")
            XCTAssertEqual(fakeHTTP.lastRequest!.method, "POST")
            if let meta = fakeHTTP.lastRequest!.parameters["_meta"] as? [String:String] {
                XCTAssertEqual(meta["source"]!, "unknown")
                XCTAssertEqual(meta["integration"]!, "custom")
                XCTAssertNotNil(meta["sessionId"])
            } else {
                XCTFail()
            }

            if let cardParameters = fakeHTTP.lastRequest!.parameters["credit_card"] as? [String:String] {
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
        let apiClient = try! BTAPIClient(clientKey: "sandbox_abcd_fake_merchant_id")
        apiClient.http = FakeHTTP()
        let cardTokenizationClient = BTCardTokenizationClient(APIClient: apiClient)

        let card = BTCardTokenizationRequest(number: "4111111111111111", expirationDate: "12/2038", cvv: nil)

        cardTokenizationClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertEqual(tokenizedCard.paymentMethodNonce, FakeHTTP.fakeNonce)
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
        let apiClient = try! BTAPIClient(clientKey: "sandbox_abcd_fake_merchant_id")
        apiClient.http = ApplicationErrorAPIClient()
        let cardTokenizationClient = BTCardTokenizationClient(APIClient: apiClient)

        let card = BTCardTokenizationRequest(number: "4111111111111111", expirationDate: "12/2038", cvv: nil)

        cardTokenizationClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error!.domain, BTCardTokenizationClientErrorDomain)
            XCTAssertEqual(error!.code, BTCardTokenizationClientErrorType.FatalError.rawValue)

            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testTokenization_failure_returnsError() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let apiClient = try! BTAPIClient(clientKey: "sandbox_abcd_fake_merchant_id")
        apiClient.http = ErrorAPIClient()
        let cardTokenizationClient = BTCardTokenizationClient(APIClient: apiClient)

        let card = BTCardTokenizationRequest(number: "4111111111111111", expirationDate: "12/2038", cvv: nil)

        cardTokenizationClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error!, ErrorAPIClient.error)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}

/***** HELPERS ******/

class FakeHTTP : BTHTTP {
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
                    "nonce": FakeHTTP.fakeNonce,
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
