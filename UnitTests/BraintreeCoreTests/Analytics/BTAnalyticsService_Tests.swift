import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore

final class BTAnalyticsService_Tests: XCTestCase {

    var currentTime: UInt64!
    var oneSecondLater: UInt64!

    override func setUp() {
        super.setUp()
        currentTime = UInt64(Date().timeIntervalSince1970 * 1000)
        oneSecondLater = UInt64((Date().timeIntervalSince1970 * 1000) + 999)
    }

    func testSendAnalyticsEvent_whenConfigFetchCompletes_setsUpAnalyticsHTTPToUseBaseURL() async {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)
        
        await analyticsService.performEventRequest("any.analytics.event")
        
        XCTAssertEqual(analyticsService.http?.customBaseURL?.absoluteString, "https://api.paypal.com")
    }

    func testSendAnalyticsEvent_sendsAnalyticsEvent() async {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)
        analyticsService.shouldBypassTimerQueue = true

        analyticsService.http = mockAnalyticsHTTP
        
        await analyticsService.performEventRequest("any.analytics.event")
        
        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "v1/tracking/batch/events")
        
        let timestamp = self.parseTimestamp(mockAnalyticsHTTP.lastRequestParameters)!
        let eventName = self.parseEventName(mockAnalyticsHTTP.lastRequestParameters)
        
        XCTAssertEqual(eventName!, "any.analytics.event")
        XCTAssertGreaterThanOrEqual(timestamp, self.currentTime)
        XCTAssertLessThanOrEqual(timestamp, self.oneSecondLater)
        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 1)

        self.validateMetadataParameters(mockAnalyticsHTTP.lastRequestParameters)
    }

    // MARK: - Helper Functions

    func stubbedAPIClientWithAnalyticsURL(_ analyticsURL: String? = nil) -> MockAPIClient {
        let stubAPIClient = MockAPIClient(authorization: "development_tokenization_key", sendAnalyticsEvent: false)

        if analyticsURL != nil {
            stubAPIClient?.cannedConfigurationResponseBody = BTJSON(
                value: [
                    "analytics": ["url": analyticsURL],
                    "merchantId": "a-fake-merchantID"
                ]
            )
        } else {
            stubAPIClient?.cannedConfigurationResponseBody = BTJSON(value: [:] as [String?: Any])
        }

        return stubAPIClient!
    }

    func validateMetadataParameters(_ postParameters: [String: Any]?) {
        let topLevelEvent = postParameters?["events"] as? [[String: Any]]
        let batchParams = topLevelEvent?[0]["batch_params"] as! [String: Any]
        
        XCTAssertTrue((batchParams["api_integration_type"] as! String).matches("custom|dropin"))
        XCTAssertNotNil(batchParams["merchant_id"])
        XCTAssertNotNil(batchParams["session_id"])
        let authKey = batchParams["tokenization_key"] as? String ?? batchParams["auth_fingerprint"] as? String
        XCTAssertNotNil(authKey)
    }
    
    func parseTimestamp(_ postParameters: [String: Any]?, at index: Int = 0) -> UInt64? {
        let topLevelEvent = postParameters?["events"] as? [[String: Any]]
        let eventParams = topLevelEvent?[0]["event_params"] as? [[String: Any]]
        if let timestampString = eventParams?[index]["t"] as? String {
            return UInt64(timestampString)
        } else {
            return nil
        }
    }

    func parseEventName(_ postParameters: [String: Any]?, at index: Int = 0) -> String? {
        let topLevelEvent = postParameters?["events"] as? [[String: Any]]
        let eventParams = topLevelEvent?[0]["event_params"] as? [[String: Any]]
        return eventParams?[index]["event_name"] as? String
    }
}
