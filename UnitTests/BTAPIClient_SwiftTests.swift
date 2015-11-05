import XCTest

class BTAPIClient_SwiftTests: XCTestCase {
    
    let ValidClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI3ODJhZmFlNDJlZTNiNTA4NWUxNmMzYjhkZTY3OGQxNTJhODFlYzk5MTBmZDNhY2YyYWU4MzA2OGI4NzE4YWZhfGNyZWF0ZWRfYXQ9MjAxNS0wOC0yMFQwMjoxMTo1Ni4yMTY1NDEwNjErMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTM3OTU5QTE5LThCMjktNDVBNC1CNTA3LTRFQUNBM0VBOEM4Nlx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6dHJ1ZSwiY29pbmJhc2UiOnsiY2xpZW50SWQiOiIxMWQyNzIyOWJhNThiNTZkN2UzYzAxYTA1MjdmNGQ1YjQ0NmQ0ZjY4NDgxN2NiNjIzZDI1NWI1NzNhZGRjNTliIiwibWVyY2hhbnRBY2NvdW50IjoiY29pbmJhc2UtZGV2ZWxvcG1lbnQtbWVyY2hhbnRAZ2V0YnJhaW50cmVlLmNvbSIsInNjb3BlcyI6ImF1dGhvcml6YXRpb25zOmJyYWludHJlZSB1c2VyIiwicmVkaXJlY3RVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbS9jb2luYmFzZS9vYXV0aC9yZWRpcmVjdC1sYW5kaW5nLmh0bWwiLCJlbnZpcm9ubWVudCI6Im1vY2sifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ==";
    
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
        let apiClient = BTAPIClient(authorization: ValidClientToken)
        let clientToken = try! BTClientToken(clientToken: ValidClientToken)
        XCTAssertEqual(apiClient?.clientToken, clientToken)
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

    func testPaymentButton_whenUsingTokenizationKey_doesNotCrash() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let paymentButton = BTPaymentButton(APIClient: apiClient) { _ in }
        let viewController = UIViewController()
        viewController.view.addSubview(paymentButton)
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
