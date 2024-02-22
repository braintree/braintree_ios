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

    func testSendAnalyticsEvent_whenConfigFetchCompletes_setsUpAnalyticsHTTPToUseBaseURL() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        let expectation = expectation(description: "Sends analytics event")
        analyticsService.sendAnalyticsEvent("any.analytics.event") { error in
            XCTAssertNil(error)
            XCTAssertEqual(analyticsService.http?.baseURL.absoluteString, "https://api-m.paypal.com")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSendAnalyticsEvent_whenNumberOfQueuedEventsMeetsThreshold_sendsAnalyticsEvent() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        analyticsService.flushThreshold = 1
        analyticsService.http = mockAnalyticsHTTP

        analyticsService.sendAnalyticsEvent("an.analytics.event")

        // Pause briefly to allow analytics service to dispatch async blocks
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.9))

        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "v1/tracking/batch/events")
        
        let timestamp = parseTimestamp(mockAnalyticsHTTP.lastRequestParameters)!
        let eventName = parseEventName(mockAnalyticsHTTP.lastRequestParameters)
        XCTAssertEqual(eventName, "an.analytics.event")
        XCTAssertGreaterThanOrEqual(timestamp, currentTime)
        XCTAssertLessThanOrEqual(timestamp, oneSecondLater)
        validateMetadataParameters(mockAnalyticsHTTP.lastRequestParameters)
    }

    func testSendAnalyticsEvent_whenFlushThresholdIsGreaterThanNumberOfBatchedEvents_doesNotSendAnalyticsEvent() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        analyticsService.flushThreshold = 2
        analyticsService.http = mockAnalyticsHTTP

        analyticsService.sendAnalyticsEvent("an.analytics.event")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))

        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 0)
    }

    func testSendAnalyticsEventCompletion_whenCalled_sendsAllEvents() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        analyticsService.flushThreshold = 5
        analyticsService.http = mockAnalyticsHTTP

        let expectation = expectation(description: "Sends batched request")

        analyticsService.sendAnalyticsEvent("an.analytics.event")
        analyticsService.sendAnalyticsEvent("another.analytics.event") { error in
            XCTAssertNil(error)
            XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 1)
            XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "v1/tracking/batch/events")

            let timestampOne = self.parseTimestamp(mockAnalyticsHTTP.lastRequestParameters, at: 0)!
            let timestampTwo = self.parseTimestamp(mockAnalyticsHTTP.lastRequestParameters, at: 1)!
            
            let eventOne = self.parseEventName(mockAnalyticsHTTP.lastRequestParameters, at: 0)
            XCTAssertEqual(eventOne, "an.analytics.event")
            XCTAssertGreaterThanOrEqual(timestampOne, self.currentTime)
            XCTAssertLessThanOrEqual(timestampOne, self.oneSecondLater)

            let eventTwo = self.parseEventName(mockAnalyticsHTTP.lastRequestParameters, at: 1)
            XCTAssertEqual(eventTwo, "another.analytics.event")
            XCTAssertGreaterThanOrEqual(timestampTwo, self.currentTime)
            XCTAssertLessThanOrEqual(timestampTwo, self.oneSecondLater)
            self.validateMetadataParameters(mockAnalyticsHTTP.lastRequestParameters)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testFlush_whenCalled_sendsAllQueuedEvents() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        analyticsService.flushThreshold = 5
        analyticsService.http = mockAnalyticsHTTP

        analyticsService.sendAnalyticsEvent("an.analytics.event")
        analyticsService.sendAnalyticsEvent("another.analytics.event")

        // Pause briefly to allow analytics service to dispatch async blocks
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))

        let expectation = expectation(description: "Sends batched request")

        analyticsService.flush() { error in
            XCTAssertNil(error)
            XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 1)

            let timestampOne = self.parseTimestamp(mockAnalyticsHTTP.lastRequestParameters, at: 0)!
            let timestampTwo = self.parseTimestamp(mockAnalyticsHTTP.lastRequestParameters, at: 1)!

            let eventOne = self.parseEventName(mockAnalyticsHTTP.lastRequestParameters, at: 0)
            XCTAssertEqual(eventOne, "an.analytics.event")
            XCTAssertGreaterThanOrEqual(timestampOne, self.currentTime)
            XCTAssertLessThanOrEqual(timestampOne, self.oneSecondLater)

            let eventTwo = self.parseEventName(mockAnalyticsHTTP.lastRequestParameters, at: 1)
            XCTAssertEqual(eventTwo, "another.analytics.event")
            XCTAssertGreaterThanOrEqual(timestampTwo, self.currentTime)
            XCTAssertLessThanOrEqual(timestampTwo, self.oneSecondLater)
            self.validateMetadataParameters(mockAnalyticsHTTP.lastRequestParameters)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testFlush_whenThereAreNoQueuedEvents_doesNotPOST() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        analyticsService.flushThreshold = 5
        analyticsService.http = mockAnalyticsHTTP

        let expectation = expectation(description: "Sends batched request")

        analyticsService.flush() { error in
            XCTAssertNil(error)
            XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 0)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testAnalyticsService_whenAPIClientConfigurationFails_returnsError() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let stubbedError = NSError(domain: "SomeError", code: 1)
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        stubAPIClient.cannedConfigurationResponseError = stubbedError
        analyticsService.http = mockAnalyticsHTTP

        let expectation = expectation(description: "Callback invoked with error")

        analyticsService.sendAnalyticsEvent("an.analytics.event") { error in
            guard let error = error as? NSError else { return }
            XCTAssertEqual(error, stubbedError)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testAnalyticsService_afterConfigurationError_maintainsQueuedEventsUntilConfigurationIsSuccessful() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let stubbedError = NSError(domain: "SomeError", code: 1)
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        stubAPIClient.cannedConfigurationResponseError = stubbedError
        analyticsService.http = mockAnalyticsHTTP

        let expectation1 = expectation(description: "Callback invoked with error")

        analyticsService.sendAnalyticsEvent("an.analytics.event.1") { error in
            guard let error = error as? NSError else { return }
            XCTAssertEqual(error, stubbedError)
            expectation1.fulfill()
        }

        waitForExpectations(timeout: 2)

        stubAPIClient.cannedConfigurationResponseError = nil

        let expectation2 = expectation(description: "Callback invoked with error")

        analyticsService.sendAnalyticsEvent("an.analytics.event.2") { error in
            XCTAssertNil(error)
            XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 1)

            let timestampOne = self.parseTimestamp(mockAnalyticsHTTP.lastRequestParameters, at: 0)!
            let timestampTwo = self.parseTimestamp(mockAnalyticsHTTP.lastRequestParameters, at: 1)!

            let eventOne = self.parseEventName(mockAnalyticsHTTP.lastRequestParameters, at: 0)
            XCTAssertEqual(eventOne, "an.analytics.event.1")
            XCTAssertGreaterThanOrEqual(timestampOne, self.currentTime)
            XCTAssertLessThanOrEqual(timestampOne, self.oneSecondLater)

            let eventTwo = self.parseEventName(mockAnalyticsHTTP.lastRequestParameters, at: 1)
            XCTAssertEqual(eventTwo, "an.analytics.event.2")
            XCTAssertGreaterThanOrEqual(timestampTwo, self.currentTime)
            XCTAssertLessThanOrEqual(timestampTwo, self.oneSecondLater)
            self.validateMetadataParameters(mockAnalyticsHTTP.lastRequestParameters)
            expectation2.fulfill()
        }

        waitForExpectations(timeout: 2)
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
