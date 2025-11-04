import XCTest
import BraintreeCore
@testable import BraintreeTestShared
@testable import BraintreeAmericanExpress

class BTAmericanExpressClient_Tests: XCTestCase {

    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_client_key")
    var amexClient : BTAmericanExpressClient? = nil

    override func setUp() {
        super.setUp()
        amexClient = BTAmericanExpressClient(authorization: "development_tokenization_key")
        amexClient?.apiClient = mockAPIClient
    }
    
    func testGetRewardsBalance_formatsGETRequest() async {
        let _ = try? await amexClient!.getRewardsBalance(forNonce: "fake-nonce", currencyISOCode: "fake-code")
        
        XCTAssertEqual(mockAPIClient.lastGETPath, "v1/payment_methods/amex_rewards_balance")
        
        guard let lastGetParameters = mockAPIClient.lastGETParameters else {
            XCTFail("Expected GET parameters")
            return
        }
        XCTAssertEqual(lastGetParameters["currencyIsoCode"] as! String, "fake-code")
        XCTAssertEqual(lastGetParameters["paymentMethodNonce"] as! String, "fake-nonce")
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
        amexClient!.getRewardsBalance(forNonce: "fake-nonce", currencyISOCode: "USD") { rewardsBalance, error in
            XCTAssertNil(error)
            XCTAssertNotNil(rewardsBalance)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents[mockAPIClient.postedAnalyticsEvents.count - 2], "amex:rewards-balance:started")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "amex:rewards-balance:succeeded")
    }
    
    func testGetRewardsBalance_returnsSendsAnalyticsEventOnError() {
        mockAPIClient.cannedResponseError = NSError(domain: "foo", code: 100, userInfo: [NSLocalizedDescriptionKey:"Fake description"])

        let expectation = self.expectation(description: "Amex rewards balance response")
        amexClient!.getRewardsBalance(forNonce: "fake-nonce", currencyISOCode: "USD") { rewardsBalance, error in
            
            if let error = error as NSError? {
                XCTAssertEqual(error.code, 100)
                XCTAssertEqual(error.localizedDescription, "Fake description")
                XCTAssertEqual(error.domain, "foo")
            }
            
            XCTAssertNil(rewardsBalance)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents[mockAPIClient.postedAnalyticsEvents.count - 2], "amex:rewards-balance:started")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "amex:rewards-balance:failed")
    }
    
    func testGetRewardsBalance_returnsSendsAnalyticsEventOnNilAPIResponse() {
        mockAPIClient.cannedResponseBody = nil

        let expectation = self.expectation(description: "Amex rewards balance response was nil")
        amexClient!.getRewardsBalance(forNonce: "fake-nonce", currencyISOCode: "USD") { rewardsBalance, error in
            
            if let error = error as NSError? {
                XCTAssertEqual(error.code, BTAmericanExpressError.noRewardsData.errorCode)
                XCTAssertEqual(error.localizedDescription, "No American Express Rewards data was returned. Please contact support.")
                XCTAssertEqual(error.domain, BTAmericanExpressError.errorDomain)
            }
            
            XCTAssertNil(rewardsBalance)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents[mockAPIClient.postedAnalyticsEvents.count - 2], "amex:rewards-balance:started")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "amex:rewards-balance:failed")
    }
    
    func testGetRewardsBalance_withInvalidAuthorization_returnsError() {
        amexClient = BTAmericanExpressClient(authorization: "badAuth")
        mockAPIClient.cannedResponseError = NSError(
            domain: BTAPIClientError.errorDomain,
            code: BTAPIClientError.invalidAuthorization("").errorCode,
            userInfo: [NSLocalizedDescriptionKey: BTAPIClientError.invalidAuthorization("").errorDescription ?? ""]
        )
        
        let expectation = expectation(description: "Amex reward balance should return invalid authorization error")
        amexClient?.getRewardsBalance(forNonce: "", currencyISOCode: "") { rewardsBalance, error in
            XCTAssertNil(rewardsBalance)
            if let error = error as NSError? {
                XCTAssertEqual(error.code, BTAPIClientError.invalidAuthorization("").errorCode)
                XCTAssertEqual(error.localizedDescription, "Invalid authorization provided: badAuth. See https://developer.paypal.com/braintree/docs/guides/client-sdk/setup/ios/v6#initialization for more info.")
                XCTAssertEqual(error.domain, BTAPIClientError.errorDomain)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
}
