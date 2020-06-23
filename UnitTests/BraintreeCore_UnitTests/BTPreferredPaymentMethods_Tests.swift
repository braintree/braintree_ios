import XCTest

class BTPreferredPaymentMethods_Tests: XCTestCase {
    
    var mockAPIClient = MockAPIClient(authorization: "development_client_key")!
    var fakeApplication = FakeApplication()
    
    override func setUp() {
        fakeApplication.cannedCanOpenURL = false
    }
    
    func testFetchPreferredPaymentMethods_sendsQueryToGraphQL() {
                
        let expectation = self.expectation(description: "Sends query to GraphQL")
        let apiClient = BTAPIClient(authorization: "development_client_key")!
        
        let mockConfigurationHTTP = BTFakeHTTP()!
        mockConfigurationHTTP.cannedConfiguration = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        mockConfigurationHTTP.cannedStatusCode = 200

        apiClient.configurationHTTP = mockConfigurationHTTP
        
        let mockGraphQLHTTP = BTFakeGraphQLHTTP.fake()!
        apiClient.graphQL = mockGraphQLHTTP
        
        let sut = BTPreferredPaymentMethods(apiClient: apiClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            
            let lastRequestParameters = mockGraphQLHTTP.lastRequestParameters as! [String: Any]
            let graphQLQuery = lastRequestParameters["query"] as! String
            XCTAssertEqual(graphQLQuery, "query PreferredPaymentMethods { preferredPaymentMethods { paypalPreferred } }")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenBothPayPalAndVenmoAppsAreInstalled_callsCompletionWithTrueForBoth() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        // allowlist paypal and venmo urls
        fakeApplication.canOpenURLWhitelist = [
            URL(string: "paypal://")!,
            URL(string: "com.venmo.touch.v2://")!
        ]
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertTrue(result.isPayPalPreferred)
            XCTAssertTrue(result.isVenmoPreferred)
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.preferred-payment-methods.paypal.app-installed.true"))
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.preferred-payment-methods.venmo.app-installed.true"))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testFetchPreferredPaymentMethods_whenVenmoAppIsNotInstalled_callsCompletionWithFalseForVenmo() {

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])

        let expectation = self.expectation(description: "Calls completion with result")

        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication

        sut.fetch { result in
            XCTAssertFalse(result.isVenmoPreferred)
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.preferred-payment-methods.venmo.app-installed.false"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testFetchPreferredPaymentMethods_whenAPIDetectsPayPalPreferred_callsCompletionWithTrueForPayPal() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        
        let jsonString =
            """
            {
                "data": {
                    "preferredPaymentMethods": {
                        "paypalPreferred": true
                    }
                }
            }
            """
        mockAPIClient.cannedResponseBody = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertTrue(result.isPayPalPreferred)
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.preferred-payment-methods.paypal.api-detected.true"))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenAPIDetectsPayPalNotPreferred_callsCompletionWithFalseForPayPal() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        
        let jsonString =
            """
            {
                "data": {
                    "preferredPaymentMethods": {
                        "paypalPreferred": false
                    }
                }
            }
            """
        mockAPIClient.cannedResponseBody = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.preferred-payment-methods.paypal.api-detected.false"))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenGraphQLResponseIsNull_callsCompletionWithFalseForPayPal() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        
        mockAPIClient.cannedResponseBody = nil
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.preferred-payment-methods.api-error"))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenGraphQLReturnsError_callsCompletionWithFalseForPayPal() {

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        mockAPIClient.cannedResponseError = NSError(domain: "domain", code: 1, userInfo: nil)
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.preferred-payment-methods.api-error"))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenGraphQLIsDisabled_callsCompletionWithFalseForPayPal() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": nil ]])
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient:  mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.preferred-payment-methods.api-disabled"))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenFetchingConfigurationReturnsAnError_callsCompletionWithFalseForPayPal() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "com.braintreepayments.UnitTest", code: 0, userInfo: nil)
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertTrue(self.mockAPIClient.postedAnalyticsEvents.contains("ios.preferred-payment-methods.api-error"))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
