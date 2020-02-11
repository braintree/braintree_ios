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
            XCTAssertEqual(graphQLQuery,
                           "query ClientConfiguration { clientConfiguration { paypal { preferredPaymentMethod } } }")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenPayPalAppIsInstalled_callsCompletionWithTrue() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        // whitelist paypal url
        fakeApplication.canOpenURLWhitelist = [
            URL(string: "paypal://")!
        ]
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertTrue(result.isPayPalPreferred)
            XCTAssertEqual(self.mockAPIClient.lastPOSTPath, "")
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.first, "ios.preferred-payment-methods.paypal.app-installed.true")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testFetchPreferredPaymentMethods_whenPayPalIsAvailable_callsCompletionWithTrue() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": ["clientConfiguration": ["paypal": ["preferredPaymentMethod": true]]]])
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertTrue(result.isPayPalPreferred)
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.first, "ios.preferred-payment-methods.paypal.api-detected.true")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenPayPalIsUnavailable_callsCompletionWithFalse() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        
        mockAPIClient.cannedResponseBody = BTJSON(value: ["data": ["clientConfiguration": ["paypal": ["preferredPaymentMethod": false]]]])
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.first, "ios.preferred-payment-methods.paypal.api-detected.false")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenGraphQLResponseIsNull_callsCompletionWithFalse() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        
        mockAPIClient.cannedResponseBody = nil
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.first, "ios.preferred-payment-methods.api-error")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenGraphQLReturnsError_callsCompletionWithFalse() {

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": "https://graphql.com"]])
        mockAPIClient.cannedResponseError = NSError(domain: "domain", code: 1, userInfo: nil)
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.first, "ios.preferred-payment-methods.api-error")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenGraphQLIsDisabled_callsCompletionWithFalse() {
        
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["graphQL": ["url": nil ]])
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient:  mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.first, "ios.preferred-payment-methods.api-disabled")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchPreferredPaymentMethods_whenFetchingConfigurationReturnsAnError_callsCompletionWithFalse() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "com.braintreepayments.UnitTest", code: 0, userInfo: nil)
        
        let expectation = self.expectation(description: "Calls completion with result")
        
        let sut = BTPreferredPaymentMethods(apiClient: mockAPIClient)
        sut.application = fakeApplication
        
        sut.fetch { result in
            XCTAssertFalse(result.isPayPalPreferred)
            XCTAssertEqual(self.mockAPIClient.postedAnalyticsEvents.first, "ios.preferred-payment-methods.api-error")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
