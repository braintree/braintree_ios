import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCoreSwift

final class BTAnalyticsService_Tests: XCTestCase {

    var currentTime: UInt64!
    var oneSecondLater: UInt64!

    override func setUp() {
        super.setUp()
        currentTime = UInt64(Date().timeIntervalSince1970 * 1000)
        oneSecondLater = UInt64((Date().timeIntervalSince1970 * 1000) + 999)
    }

    func testSendAnalyticsEvent_whenRemoteConfigurationHasNoAnalyticsURL_returnsError() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL()
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        let expectation = expectation(description: "Sends analytics event")
        analyticsService.sendAnalyticsEvent("any.analytics.event") { error in
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTAnalyticsServiceError.errorDomain)
            XCTAssertEqual(error.code, Int(BTAnalyticsServiceError.missingAnalyticsURL.rawValue))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSendAnalyticsEvent_whenRemoteConfigurationHasAnalyticsURL_setsUpAnalyticsHTTPToUseBaseURL() {
        let stubAPIClient: MockAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let analyticsService = BTAnalyticsService(apiClient: stubAPIClient)

        let expectation = expectation(description: "Sends analytics event")
        analyticsService.sendAnalyticsEvent("any.analytics.event") { error in
            XCTAssertNil(error)
            XCTAssertEqual(analyticsService.http?.baseURL.absoluteString, "test://do-not-send.url")
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
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))

        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "/")

        let parameters = mockAnalyticsHTTP.lastRequestParameters?["analytics"] as? [[String: Any]]
        let timestamp = parameters?[0]["timestamp"] as! UInt64
        XCTAssertEqual(parameters?[0]["kind"] as? String, "an.analytics.event")
        XCTAssertGreaterThanOrEqual(timestamp, currentTime)
        XCTAssertLessThanOrEqual(timestamp, oneSecondLater)
        validateMetadataParameters(metadataParameters: (mockAnalyticsHTTP.lastRequestParameters!["_meta"] as? [String: Any])!)
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
            XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "/")

            let parameters = mockAnalyticsHTTP.lastRequestParameters?["analytics"] as? [[String: Any]]
            let timestampOne = parameters?[0]["timestamp"] as! UInt64
            let timestampTwo = parameters?[1]["timestamp"] as! UInt64

            XCTAssertEqual(parameters?[0]["kind"] as? String, "an.analytics.event")
            XCTAssertGreaterThanOrEqual(timestampOne, self.currentTime)
            XCTAssertLessThanOrEqual(timestampOne, self.oneSecondLater)

            XCTAssertEqual(parameters?[1]["kind"] as? String, "another.analytics.event")
            XCTAssertGreaterThanOrEqual(timestampTwo, self.currentTime)
            XCTAssertLessThanOrEqual(timestampTwo, self.oneSecondLater)
            self.validateMetadataParameters(metadataParameters: (mockAnalyticsHTTP.lastRequestParameters!["_meta"] as? [String: Any])!)
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

            let parameters = mockAnalyticsHTTP.lastRequestParameters?["analytics"] as? [[String: Any]]
            let timestampOne = parameters?[0]["timestamp"] as! UInt64
            let timestampTwo = parameters?[1]["timestamp"] as! UInt64

            XCTAssertEqual(parameters?[0]["kind"] as? String, "an.analytics.event")
            XCTAssertGreaterThanOrEqual(timestampOne, self.currentTime)
            XCTAssertLessThanOrEqual(timestampOne, self.oneSecondLater)

            XCTAssertEqual(parameters?[1]["kind"] as? String, "another.analytics.event")
            XCTAssertGreaterThanOrEqual(timestampTwo, self.currentTime)
            XCTAssertLessThanOrEqual(timestampTwo, self.oneSecondLater)
            self.validateMetadataParameters(metadataParameters: (mockAnalyticsHTTP.lastRequestParameters!["_meta"] as? [String: Any])!)
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

            let parameters = mockAnalyticsHTTP.lastRequestParameters?["analytics"] as? [[String: Any]]
            let timestampOne = parameters?[0]["timestamp"] as! UInt64
            let timestampTwo = parameters?[1]["timestamp"] as! UInt64

            XCTAssertEqual(parameters?[0]["kind"] as? String, "an.analytics.event.1")
            XCTAssertGreaterThanOrEqual(timestampOne, self.currentTime)
            XCTAssertLessThanOrEqual(timestampOne, self.oneSecondLater)

            XCTAssertEqual(parameters?[1]["kind"] as? String, "an.analytics.event.2")
            XCTAssertGreaterThanOrEqual(timestampTwo, self.currentTime)
            XCTAssertLessThanOrEqual(timestampTwo, self.oneSecondLater)
            self.validateMetadataParameters(metadataParameters: (mockAnalyticsHTTP.lastRequestParameters!["_meta"] as? [String: Any])!)
            expectation2.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Helper Functions

    func stubbedAPIClientWithAnalyticsURL(_ analyticsURL: String? = nil) -> MockAPIClient {
        let stubAPIClient = MockAPIClient(authorization: "development_tokenization_key", sendAnalyticsEvent: false)

        if analyticsURL != nil {
            stubAPIClient?.cannedConfigurationResponseBody = BTJSON(value: ["analytics": ["url": analyticsURL]])
        } else {
            stubAPIClient?.cannedConfigurationResponseBody = BTJSON(value: [:])
        }

        return stubAPIClient!
    }

    func validateMetadataParameters(metadataParameters: [String: Any]) {
        XCTAssertEqual(metadataParameters["platform"] as? String, "iOS")
        XCTAssertNotNil(metadataParameters["platformVersion"] as? String)
        XCTAssertEqual(metadataParameters["sdkVersion"] as? String, BTCoreConstants.braintreeSDKVersion)
        XCTAssertNotNil(metadataParameters["merchantAppId"] as? String)
        XCTAssertNotNil(metadataParameters["merchantAppName"] as? String)
        XCTAssertNotNil(metadataParameters["merchantAppVersion"] as? String)
        XCTAssertEqual(metadataParameters["deviceManufacturer"] as? String, "Apple")
        XCTAssertNotNil(metadataParameters["deviceModel"] as? String)
        XCTAssertNotNil(metadataParameters["iosIdentifierForVendor"] as? String)
        XCTAssertNotNil(metadataParameters["iosPackageManager"] as? String)
        XCTAssertNotNil(metadataParameters["isSimulator"] as? Bool)
        XCTAssertNotNil(metadataParameters["deviceScreenOrientation"] as? String)
    }
}
