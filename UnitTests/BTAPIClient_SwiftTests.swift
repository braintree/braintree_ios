import XCTest

class BTAPIClient_SwiftTests: XCTestCase {
    
    func testAPIClientInitialization_withValidTokenizationKey_returnsClientWithTokenizationKey() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        XCTAssertEqual(apiClient.tokenizationKey, "development_testing_integration_merchant_id")
    }
    
    func testAPIClientInitialization_withInvalidTokenizationKey_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: "invalid"))
    }
    
    func testAPIClientInitialization_withEmptyTokenizationKey_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: ""))
    }
    
    func testAPIClientInitialization_withValidClientToken_returnsClientWithClientToken() {
        let clientToken = BTTestClientTokenFactory.tokenWithVersion(2)
        let apiClient = BTAPIClient(authorization: clientToken)
        XCTAssertEqual(apiClient?.clientToken.originalValue, clientToken)
    }
    
    // MARK: - Analytics Tests
    
    func testAPIClientSendAnalyticsEvent_whenRemoteConfigurationHasEmptyAnalyticsURL_doesNotSendEvent() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let fakeHttp = BTFakeHTTP()!
        fakeHttp.stubRequest("GET", toEndpoint: "/client_api/v1/configuration", respondWith: ["analytics": ["url": ""]], statusCode: 200)
        apiClient.http = fakeHttp
        
        let expectation = expectationWithDescription("Callback invoked")
        apiClient.sendAnalyticsEvent("test.analytics.event") { (error) -> Void in
            XCTAssertEqual(error.domain, BTHTTPErrorDomain)
            XCTAssertEqual(error.code, BTHTTPErrorCode.MissingBaseURL.rawValue)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testSendAnalyticsEvent_whenSuccessful_sendsCorrectAnalyticsParameters() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let mockAnalyticsHTTP = BTFakeHTTP()!
        let stubConfigurationHTTP = BTFakeHTTP()!
        apiClient.analyticsHttp = mockAnalyticsHTTP
        apiClient.http = stubConfigurationHTTP
        stubConfigurationHTTP.stubRequest("GET", toEndpoint: "/client_api/v1/configuration", respondWith: ["analytics": ["url": "test://do-not-send.url"]], statusCode: 200)
        let metadata = apiClient.metadata
        let expectation = self.expectationWithDescription("Sends analytics event")
        
        // As a sanity check, intentionally generate timestamp a different way
        let unixTimestampVia2001ReferenceDate = NSDate.timeIntervalSinceReferenceDate() + NSTimeIntervalSince1970
        
        apiClient.sendAnalyticsEvent("an.analytics.event") { (error) -> Void in
            XCTAssertNil(error)
            XCTAssertEqual(metadata.source, BTClientMetadataSourceType.Unknown) // Default
            XCTAssertEqual(metadata.integration, BTClientMetadataIntegrationType.Custom) // Default
            XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "/")
            XCTAssertEqual(mockAnalyticsHTTP.lastRequestParameters!["analytics"]![0]["kind"], "an.analytics.event")
            
            let timestamp = (mockAnalyticsHTTP.lastRequestParameters!["analytics"]![0] as! NSDictionary)["timestamp"]!.longValue
            XCTAssert(abs(Double(timestamp) - unixTimestampVia2001ReferenceDate) < 2) // Typically ~0.4
            
            let meta = mockAnalyticsHTTP.lastRequestParameters!["_meta"] as! NSDictionary
            XCTAssertEqual(meta["integration"] as? String, metadata.integrationString)
            XCTAssertEqual(meta["source"] as? String, metadata.sourceString)
            XCTAssertEqual(meta["sessionId"] as? String, metadata.sessionId)
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    // MARK: - Copy

    func testCopyWithSource_whenUsingClientToken_usesSameClientToken() {
        let clientToken = BTTestClientTokenFactory.tokenWithVersion(2)
        let apiClient = BTAPIClient(authorization: clientToken)

        let copiedApiClient = apiClient?.copyWithSource(.Unknown, integration: .Unknown)

        XCTAssertEqual(copiedApiClient?.clientToken.originalValue, clientToken)
    }

    func testCopyWithSource_whenUsingTokenizationKey_usesSameTokenizationKey() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let copiedApiClient = apiClient?.copyWithSource(.Unknown, integration: .Unknown)
        XCTAssertEqual(copiedApiClient?.tokenizationKey, "development_testing_integration_merchant_id")
    }

    func testCopyWithSource_setsMetadataSourceAndIntegration() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let copiedApiClient = apiClient?.copyWithSource(.PayPalBrowser, integration: .DropIn)
        XCTAssertEqual(copiedApiClient?.metadata.source, .PayPalBrowser)
        XCTAssertEqual(copiedApiClient?.metadata.integration, .DropIn)
    }

    func testCopyWithSource_copiesHTTP() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let copiedApiClient = apiClient?.copyWithSource(.PayPalBrowser, integration: .DropIn)
        XCTAssertTrue(copiedApiClient !== apiClient)
    }

}
