import XCTest

class BTAmericanExpressClient_Tests: XCTestCase {

    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_client_key")!
    var amexClient : BTAmericanExpressClient? = nil

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        amexClient = BTAmericanExpressClient(apiClient: mockAPIClient)
   }
    
    func testGetRewardsBalance_returnsSendsAnalyticsEventOnSuccess() {
        let responseBody = [
            "conversionRate": "0.0070",
            "currencyAmount": "316795.03",
            "currencyIsoCode": "USD",
            "requestId": "715f4712-8690-49ed-8cc5-d7fb1c2d",
            "rewardsAmount": "45256433",
            "rewardsUnit": "Points",
            ] as [String : Any]
        mockAPIClient.cannedResponseBody = BTJSON(value: responseBody)
        
        let expectation = self.expectation(description: "Amex rewards balance response")
        amexClient!.getRewardsBalance(forNonce: "fake-nonce", currencyIsoCode: "USD", completion: { (rewardsBalance, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(rewardsBalance)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents[mockAPIClient.postedAnalyticsEvents.count - 2], "ios.amex.rewards-balance.start")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.amex.rewards-balance.success")
    }
    
    func testGetRewardsBalance_returnsSendsAnalyticsEventOnError() {
        mockAPIClient.cannedResponseError = NSError(domain: "foo", code: 100, userInfo: nil)

        let expectation = self.expectation(description: "Amex rewards balance response")
        amexClient!.getRewardsBalance(forNonce: "fake-nonce", currencyIsoCode: "USD", completion: { (rewardsBalance, error) in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedResponseError!)
            XCTAssertNil(rewardsBalance)
            expectation.fulfill()
        })
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents[mockAPIClient.postedAnalyticsEvents.count - 2], "ios.amex.rewards-balance.start")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.amex.rewards-balance.error")
    }
}
