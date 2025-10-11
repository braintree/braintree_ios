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
        let sut = BTAnalyticsService.shared
        sut.setAPIClient(stubAPIClient)
        
        await sut.performEventRequest(with: FPTIBatchData.Event(eventName: "any.analytics.event"))
        
        XCTAssertEqual(sut.http?.customBaseURL?.absoluteString, "https://api.paypal.com")
    }

    func testSendAnalyticsEvent_sendsAnalyticsEvent() async {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let sut = BTAnalyticsService.shared
        sut.setAPIClient(stubAPIClient)
        sut.shouldBypassTimerQueue = true

        sut.http = mockAnalyticsHTTP
        
        await sut.performEventRequest(with: FPTIBatchData.Event(eventName: "any.analytics.event"))

        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "v1/tracking/batch/events")
        
        let timestamp = parseTimestamp(mockAnalyticsHTTP.lastRequestParameters)!
        let eventName = parseEventName(mockAnalyticsHTTP.lastRequestParameters)
        
        XCTAssertEqual(eventName!, "any.analytics.event")
        XCTAssertGreaterThanOrEqual(timestamp, currentTime)
        XCTAssertLessThanOrEqual(timestamp, oneSecondLater)
        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 1)

        self.validateMetadataParameters(mockAnalyticsHTTP.lastRequestParameters)
    }

    func testSendAnalyticsEvent_whenMultipleSessionIDs_sendsMultiplePOSTs() async {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let sut = BTAnalyticsService.shared
        sut.setAPIClient(stubAPIClient)
        sut.http = mockAnalyticsHTTP
        
        await resetAnalyticsState(analyticsService: sut, analyticsHTTP: mockAnalyticsHTTP)
        
        // Send events associated with 1st sessionID
        stubAPIClient.metadata.sessionID = "session-id-1"
        await sut.performEventRequest(with: FPTIBatchData.Event(eventName: "event1"))
        
        // Send events associated with 2nd sessionID
        stubAPIClient.metadata.sessionID = "session-id-2"
        sut.shouldBypassTimerQueue = true
        await sut.performEventRequest(with: FPTIBatchData.Event(eventName: "event2"))
        
        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 2)
    }

    func testSendAnalyticsEvents_whenMultipleEventsSent_tracksLatestEventName_andNumberOfPOSTRequests() async {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let sut = BTAnalyticsService.shared
        sut.setAPIClient(stubAPIClient)
        sut.http = mockAnalyticsHTTP
        
        let event1 = FPTIBatchData.Event(eventName: "event1")
        let event2 = FPTIBatchData.Event(eventName: "event2")
        let event3 = FPTIBatchData.Event(eventName: "event3")
            
        await sut.sendAnalyticEvent(event1, apiClient: stubAPIClient)
        await sut.sendAnalyticEvent(event2, apiClient: stubAPIClient)
        await sut.sendAnalyticEvent(event3, apiClient: stubAPIClient)
        
        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 3)
        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "v1/tracking/batch/events")
    }
    
    func testSendAnalyticsEventsImmediately_callsBeginsAndEndsBackgroundTask() async {
        let stubAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let mockBackgroundTaskManager = MockBackgroundTaskManager()
        let expectedTaskID = UIBackgroundTaskIdentifier(rawValue: 123)
        mockBackgroundTaskManager.taskIDsToReturn.insert(expectedTaskID)
        let event = FPTIBatchData.Event(eventName: "event")
        let sut = BTAnalyticsService.shared
        sut.setAPIClient(stubAPIClient)
        sut.application = mockBackgroundTaskManager
        sut.http = mockAnalyticsHTTP
        
        await sut.sendAnalyticsEventsImmediately(event: event)

        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "v1/tracking/batch/events")
        XCTAssertEqual(mockBackgroundTaskManager.lastTaskName, "BTSendAnalyticEvent")
        XCTAssertTrue(mockBackgroundTaskManager.didBeginBackgroundTask)
        XCTAssertTrue(mockBackgroundTaskManager.didEndBackgroundTask)
        XCTAssertEqual(mockBackgroundTaskManager.endedTaskID, expectedTaskID)
    }
    
    func testSendAnalyticsEventsImmediately_withConcurrentCalls_beginAndEnd_returnSameTaskIDs() async {
        let stubAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let mockBackgroundTaskManager = MockBackgroundTaskManager()
        let sut = BTAnalyticsService.shared
        sut.setAPIClient(stubAPIClient)
        sut.application = mockBackgroundTaskManager
        sut.http = mockAnalyticsHTTP

        let events = [
            FPTIBatchData.Event(eventName: "event1"),
            FPTIBatchData.Event(eventName: "event2"),
            FPTIBatchData.Event(eventName: "event3")
        ]
        let taskIDs: [UIBackgroundTaskIdentifier] = [
            UIBackgroundTaskIdentifier(rawValue: 101),
            UIBackgroundTaskIdentifier(rawValue: 102),
            UIBackgroundTaskIdentifier(rawValue: 103)
        ]
        mockBackgroundTaskManager.taskIDsToReturn = Set(taskIDs)
        
        var tasks: [Task<Void, Never>] = []

        for event in events {
            let task = Task {
                await sut.sendAnalyticsEventsImmediately(event: event)
            }
            
            tasks.append(task)
        }

        for task in tasks {
            await task.value
        }

        XCTAssertEqual(mockBackgroundTaskManager.begunTaskIDs, Set(taskIDs))
        XCTAssertEqual(mockBackgroundTaskManager.endedTaskIDs, Set(taskIDs))
    }
    
    func testSendAnalyticsEventsImmediately_callsExpirationHandler() async {
        let stubAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let mockBackgroundTaskManager = MockBackgroundTaskManager()
        let expectedTaskID = UIBackgroundTaskIdentifier(rawValue: 123)
        mockBackgroundTaskManager.taskIDsToReturn.insert(expectedTaskID)
        let event = FPTIBatchData.Event(eventName: "event")
        let sut = BTAnalyticsService.shared
        sut.setAPIClient(stubAPIClient)
        sut.application = mockBackgroundTaskManager
        sut.http = mockAnalyticsHTTP
        
        // Start the async task but do not await
        let task = Task {
            await sut.sendAnalyticsEventsImmediately(event: event)
        }

        // Wait for the background task to be started and expirationHandler to be set
        while mockBackgroundTaskManager.expirationHandler == nil {
            await Task.yield()
        }

        // Simulate expiration
        mockBackgroundTaskManager.expirationHandler?()
        
        await task.value
        
        XCTAssertTrue(mockBackgroundTaskManager.didBeginBackgroundTask)
        XCTAssertTrue(mockBackgroundTaskManager.didEndBackgroundTask)
        XCTAssertEqual(mockBackgroundTaskManager.endedTaskID, expectedTaskID)
    }
    
    func testSendAnalyticsEventsImmediately_withConcurrentCalls_beginAndEnd_returnSameTaskIDs_callsExpirationHandler() async {
        let stubAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let mockBackgroundTaskManager = MockBackgroundTaskManager()
        let sut = BTAnalyticsService.shared
        sut.setAPIClient(stubAPIClient)
        sut.application = mockBackgroundTaskManager
        sut.http = mockAnalyticsHTTP

        let events = [
            FPTIBatchData.Event(eventName: "event1"),
            FPTIBatchData.Event(eventName: "event2"),
            FPTIBatchData.Event(eventName: "event3")
        ]
        let taskIDs: [UIBackgroundTaskIdentifier] = [
            UIBackgroundTaskIdentifier(rawValue: 301),
            UIBackgroundTaskIdentifier(rawValue: 302),
            UIBackgroundTaskIdentifier(rawValue: 303)
        ]

        mockBackgroundTaskManager.taskIDsToReturn = Set(taskIDs)
        
        var tasks: [Task<Void, Never>] = []

        for event in events {
            let task = Task {
                await sut.sendAnalyticsEventsImmediately(event: event)
            }
            
            // Wait for the expiration handler to be set for each task
            while mockBackgroundTaskManager.expirationHandler == nil {
                await Task.yield()
            }
            
            mockBackgroundTaskManager.expirationHandler?()
            tasks.append(task)
            
            // Reset the handler for the next iteration
            mockBackgroundTaskManager.expirationHandler = nil
        }

        for task in tasks {
            await task.value
        }

        // Assert that the begun and ended task IDs match and are as expected
        XCTAssertEqual(mockBackgroundTaskManager.begunTaskIDs, Set(taskIDs))
        XCTAssertEqual(mockBackgroundTaskManager.endedTaskIDs, Set(taskIDs))
    }
    
    // MARK: - Helper Functions

    func stubbedAPIClientWithAnalyticsURL(_ analyticsURL: String? = nil) -> MockAPIClient {
        let stubAPIClient = MockAPIClient(authorization: "development_tokenization_key")

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
    
    /// Sends a dummy event to flush queued analytics and reset state before subsequent unit tests.
    private func resetAnalyticsState(analyticsService: BTAnalyticsService, analyticsHTTP: FakeHTTP) async {
        await analyticsService.performEventRequest(with: FPTIBatchData.Event(eventName: "clear-queue-event"))
        analyticsHTTP.POSTRequestCount = 0
    }
}
