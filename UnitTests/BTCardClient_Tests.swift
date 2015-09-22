import XCTest

class BTCardClient_Tests: XCTestCase {

    func testTokenization_sendsDataToClientAPI() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let fakeHTTP = FakeHTTP.fakeHTTP()
        let apiClient = BTAPIClient(clientKey: "sandbox_abcd_fake_merchant_id")!
        apiClient.http = fakeHTTP
        let cardClient = BTCardClient(APIClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertEqual(fakeHTTP.lastRequest!.endpoint, "v1/payment_methods/credit_cards")
            XCTAssertEqual(fakeHTTP.lastRequest!.method, "POST")

            if let cardParameters = fakeHTTP.lastRequest!.parameters["credit_card"] as? [String:AnyObject] {
                XCTAssertEqual(cardParameters["number"] as? String, "4111111111111111")
                XCTAssertEqual(cardParameters["expiration_date"] as? String, "12/2038")
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testTokenization_whenAPIClientSucceeds_returnsTokenizedCard() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let apiClient = BTAPIClient(clientKey: "sandbox_abcd_fake_merchant_id")!
        apiClient.http = FakeHTTP.fakeHTTP()
        let cardClient = BTCardClient(APIClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertEqual(tokenizedCard.paymentMethodNonce, FakeHTTP.fakeNonce)
            XCTAssertEqual(tokenizedCard.localizedDescription, "Visa ending in 11")
            XCTAssertEqual(tokenizedCard.lastTwo!, "11")
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.Visa)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testTokenization_whenAPIClientFails_returnsError() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let apiClient = BTAPIClient(clientKey: "sandbox_abcd_fake_merchant_id")!
        apiClient.http = ErrorHTTP.fakeHTTP()
        let cardClient = BTCardClient(APIClient: apiClient)

        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)

        cardClient.tokenizeCard(card) { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error!, ErrorHTTP.error)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    // MARK: _meta parameter
    
    func testMetaParameter_whenTokenizationIsSuccessful_isPOSTedToServer() {
        let mockAPIClient = MockAPIClient(clientKey: "development_client_key")!
        let cardClient = BTCardClient(APIClient: mockAPIClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2038", cvv: nil)
        
        let expectation = expectationWithDescription("Tokenized card")
        cardClient.tokenizeCard(card) { _ -> Void in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)
        
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "v1/payment_methods/credit_cards")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let metaParameters = lastPostParameters["_meta"] as! NSDictionary
        XCTAssertEqual(metaParameters["source"] as? String, "unknown")
        XCTAssertEqual(metaParameters["integration"] as? String, "custom")
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionId)
    }
}

// MARK: Helpers

class FakeHTTP : BTHTTP {
    struct Request {
        let endpoint : String
        let method : String
        let parameters : [NSObject:AnyObject]
    }

    static let fakeNonce = "fake-nonce"
    var lastRequest : Request?

    class func fakeHTTP() -> FakeHTTP {
        return FakeHTTP(baseURL: NSURL(string: "fake://fake")!, authorizationFingerprint: "")
    }

    override func POST(endpoint: String, parameters: [NSObject : AnyObject]?, completion completionBlock: ((BTJSON?, NSHTTPURLResponse?, NSError?) -> Void)?) {
        self.lastRequest = Request(endpoint: endpoint, method: "POST", parameters: parameters!)

        let response  = NSHTTPURLResponse(URL: NSURL(string: endpoint)!, statusCode: 202, HTTPVersion: nil, headerFields: nil)!

        guard let completionBlock = completionBlock else {
            return
        }
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

class ErrorHTTP : BTHTTP {
    static let error = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil)

    class func fakeHTTP() -> ErrorHTTP {
        return ErrorHTTP(baseURL: NSURL(), authorizationFingerprint: "")
    }

    override func POST(endpoint: String, parameters: [NSObject : AnyObject]?, completion completionBlock: ((BTJSON?, NSHTTPURLResponse?, NSError?) -> Void)?) {
        guard let completionBlock = completionBlock else {
            return
        }
        completionBlock(nil, nil, ErrorHTTP.error)
    }
}
