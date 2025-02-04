import XCTest
@testable import BraintreeTestShared
@testable import BraintreeCore

final class AtomicEventLogger_Tests: XCTestCase {

    var currentTime: Int64!
    var oneSecondLater: Int64!

    override func setUp() {
        super.setUp()
        currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        oneSecondLater = Int64((Date().timeIntervalSince1970 * 1000) + 999)
    }

    func testSendAtomicStartEvent_whenConfigCompletes() {
        let stubAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let sut = AtomicCoreManager.shared
        sut.setAPIClient(stubAPIClient)

        sut.logCIStartEvent(AtomicLoggerEventModel.getPayWithPayPalCIStart(task: "select_vaulted_checkout_bt", flow: "modxo_vaulted_not_recurring"))
        XCTAssertEqual(sut.atomicEventLogger.http?.customBaseURL?.absoluteString, AtomicCoreConstants.URL.baseUrl)
    }

    func testSendAtomicStartEvent() {
        let stubAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let sut = AtomicCoreManager.shared
        sut.setAPIClient(stubAPIClient)

        sut.atomicEventLogger.http = mockAnalyticsHTTP

        let loggerEventModel = AtomicLoggerEventModel.getPayWithPayPalCIStart(task: "select_vaulted_checkout_bt", flow: "modxo_vaulted_not_recurring")
        sut.logCIStartEvent(loggerEventModel)

        // MARK: Checking if the Endpoint hit is same.
        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "/xoplatform/logger/api/ae/")

        // MARK: Checking if the Payload hit is same.
        let actualPayloadSent: [[String: Any]]? = sut.payloadConstructor.getCIStartEventPayload(model: loggerEventModel)

        var json: [[String: Any]]?
        if let body = mockAnalyticsHTTP.lastRequestParametersAsData, let payloadObject = try? JSONDecoder().decode([AnalyticsPayload].self, from: body) {
            json = sut.payloadConstructor.convertToJson(payloads: payloadObject)
        }

        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 1) // asserts the only one call is made
        XCTAssertNotNil(actualPayloadSent) // asserts the actual sent payload whether Nil or not.
        XCTAssertNotNil(json) // asserts the sent payload whether Nil or not.
        if let json, let actualPayloadSent {
            XCTAssertEqual(json as NSObject, actualPayloadSent as NSObject)
        }

        // MARK: Checking about the time in which the requet was made ensuring its under a second
        let requestTimeLogged = sut.eventTimerManager.getStartTime(for: loggerEventModel.interaction)
        XCTAssertNotNil(requestTimeLogged)
        if let requestTimeLogged {
            XCTAssertGreaterThanOrEqual(requestTimeLogged, currentTime)
            XCTAssertLessThanOrEqual(requestTimeLogged, oneSecondLater)
        }
    }

    func testSendAtomicEndEvent() {
        let stubAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let sut = AtomicCoreManager.shared
        sut.setAPIClient(stubAPIClient)

        sut.atomicEventLogger.http = mockAnalyticsHTTP

        let loggerEventModel = AtomicLoggerEventModel.getPayWithPayPalCIEnd(task: "select_vaulted_checkout_bt", flow: "modxo_vaulted_not_recurring")
        let startTime = Date().millisecondsSince1970
        sut.logCIEndEvent(loggerEventModel, startTime: startTime)

        // MARK: Checking if the Endpoint hit is same.
        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "/xoplatform/logger/api/ae/")

        // MARK: Checking if the Payload hit is same.
        let actualPayloadSent: [[String: Any]]? = sut.payloadConstructor.getCIEndEventPayload(model: loggerEventModel, startTime: startTime)

        var json: [[String: Any]]?
        if let body = mockAnalyticsHTTP.lastRequestParametersAsData, let payloadObject = try? JSONDecoder().decode([AnalyticsPayload].self, from: body) {
            json = sut.payloadConstructor.convertToJson(payloads: payloadObject)
        }

        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 1) // asserts the only one call is made
        XCTAssertNotNil(actualPayloadSent) // asserts the actual sent payload whether Nil or not.
        XCTAssertNotNil(json) // asserts the sent payload whether Nil or not.

        // Checking only the first part of the payload sent cause the second part is always constant and only the metricValue differs and that change depends on the time of payload construction and varies in milliseconds.
        if let json, let actualPayloadSent {
            XCTAssertEqual(json[0] as NSObject, actualPayloadSent[0] as NSObject)
        }

        // MARK: Checking about the time in which the requet was made ensuring its under a second
        XCTAssertNotNil(startTime)
        XCTAssertGreaterThanOrEqual(startTime, currentTime)
        XCTAssertLessThanOrEqual(startTime, oneSecondLater)
    }

    func testSendAtomicStartEndEvents() {
        let stubAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let sut = AtomicCoreManager.shared
        sut.setAPIClient(stubAPIClient)

        sut.atomicEventLogger.http = mockAnalyticsHTTP

        // MARK: Send CI Start Event Part
        let loggerEventStartModel = AtomicLoggerEventModel.getPayWithPayPalCIStart(task: "select_vaulted_checkout_bt", flow: "modxo_vaulted_not_recurring")
        sut.logCIStartEvent(loggerEventStartModel)

        // MARK: Checking if the Endpoint hit is same.
        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "/xoplatform/logger/api/ae/")

        // MARK: Checking if the Payload hit is same.
        let actualStartPayloadSent: [[String: Any]]? = sut.payloadConstructor.getCIStartEventPayload(model: loggerEventStartModel)

        var startJson: [[String: Any]]?
        if let body = mockAnalyticsHTTP.lastRequestParametersAsData, let payloadObject = try? JSONDecoder().decode([AnalyticsPayload].self, from: body) {
            startJson = sut.payloadConstructor.convertToJson(payloads: payloadObject)
        }

        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 1) // asserts the only one call is made
        XCTAssertNotNil(actualStartPayloadSent) // asserts the actual sent payload whether Nil or not.
        XCTAssertNotNil(startJson) // asserts the sent payload whether Nil or not.
        if let startJson, let actualStartPayloadSent {
            XCTAssertEqual(startJson as NSObject, actualStartPayloadSent as NSObject)
        }

        // MARK: Checking about the time in which the requet was made ensuring its under a second
        let requestTimeLogged = sut.eventTimerManager.getStartTime(for: loggerEventStartModel.interaction)
        XCTAssertNotNil(requestTimeLogged)
        if let requestTimeLogged {
            XCTAssertGreaterThanOrEqual(requestTimeLogged, currentTime)
            XCTAssertLessThanOrEqual(requestTimeLogged, oneSecondLater)
        }

        // MARK: Checking if the interaction is logged along with the start time
        XCTAssertEqual(sut.eventTimerManager.getCachedInteractionsCount(), 1)
        if let interaction = sut.eventTimerManager.getCachedInteractions().first {
            XCTAssertEqual(interaction, loggerEventStartModel.interaction)
        }

        // MARK: Send CI End Event Part
        let loggerEventEndModel = AtomicLoggerEventModel.getPayWithPayPalCIEnd(task: "select_vaulted_checkout_bt", flow: "modxo_vaulted_not_recurring")
        let startTime = Date().millisecondsSince1970
        sut.logCIEndEvent(loggerEventEndModel, startTime: startTime)

        // MARK: Checking if the Endpoint hit is same.
        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "/xoplatform/logger/api/ae/")

        // MARK: Checking if the Payload hit is same.
        let actualEndPayloadSent: [[String: Any]]? = sut.payloadConstructor.getCIEndEventPayload(model: loggerEventEndModel, startTime: startTime)

        var endJson: [[String: Any]]?
        if let body = mockAnalyticsHTTP.lastRequestParametersAsData, let payloadObject = try? JSONDecoder().decode([AnalyticsPayload].self, from: body) {
            endJson = sut.payloadConstructor.convertToJson(payloads: payloadObject)
        }

        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 2) // asserts the only one call is made
        XCTAssertNotNil(actualEndPayloadSent) // asserts the actual sent payload whether Nil or not.
        XCTAssertNotNil(endJson) // asserts the sent payload whether Nil or not.

        // Checking only the first part of the payload sent cause the second part is always constant and only the metricValue differs and that change depends on the time of payload construction and varies in milliseconds.
        if let endJson, let actualEndPayloadSent {
            XCTAssertEqual(endJson[0] as NSObject, actualEndPayloadSent[0] as NSObject)
        }

        // MARK: Checking about the time in which the requet was made ensuring its under a second
        XCTAssertNotNil(startTime)
        XCTAssertGreaterThanOrEqual(startTime, currentTime)
        XCTAssertLessThanOrEqual(startTime, oneSecondLater)

        // MARK: Checking if the interaction is logged along with the start time
        XCTAssertEqual(sut.eventTimerManager.getCachedInteractionsCount(), 0)
    }

    func testSendAtomicEventRemovalHandlerTest() async {
        let stubAPIClient = stubbedAPIClientWithAnalyticsURL("test://do-not-send.url")
        let mockAnalyticsHTTP = FakeHTTP.fakeHTTP()
        let sut = AtomicCoreManager.shared
        sut.setAPIClient(stubAPIClient)

        sut.atomicEventLogger.http = mockAnalyticsHTTP

        let timeInterval: Int = 2 // in seconds.
        sut.eventTimerManager.updateTimeIntervalInSeconds(to: timeInterval)

        let loggerEventModel = AtomicLoggerEventModel.getPayWithPayPalCIStart(task: "select_vaulted_checkout_bt", flow: "modxo_vaulted_not_recurring")
        sut.logCIStartEvent(loggerEventModel)

        // MARK: Checking if the Endpoint hit is same.
        XCTAssertEqual(mockAnalyticsHTTP.lastRequestEndpoint, "/xoplatform/logger/api/ae/")

        // MARK: Checking if the Payload hit is same.
        let actualPayloadSent: [[String: Any]]? = sut.payloadConstructor.getCIStartEventPayload(model: loggerEventModel)

        var json: [[String: Any]]?
        if let body = mockAnalyticsHTTP.lastRequestParametersAsData, let payloadObject = try? JSONDecoder().decode([AnalyticsPayload].self, from: body) {
            json = sut.payloadConstructor.convertToJson(payloads: payloadObject)
        }

        XCTAssertEqual(mockAnalyticsHTTP.POSTRequestCount, 1) // asserts the only one call is made
        XCTAssertNotNil(actualPayloadSent) // asserts the actual sent payload whether Nil or not.
        XCTAssertNotNil(json) // asserts the sent payload whether Nil or not.
        if let json, let actualPayloadSent {
            XCTAssertEqual(json as NSObject, actualPayloadSent as NSObject)
        }

        // MARK: Checking about the time in which the requet was made ensuring its under a second
        let requestTimeLogged = sut.eventTimerManager.getStartTime(for: loggerEventModel.interaction)
        XCTAssertNotNil(requestTimeLogged)
        if let requestTimeLogged {
            XCTAssertGreaterThanOrEqual(requestTimeLogged, currentTime)
            XCTAssertLessThanOrEqual(requestTimeLogged, oneSecondLater)
        }

        // MARK: Checking if the interaction is logged along with the start time
        XCTAssertEqual(sut.eventTimerManager.getCachedInteractionsCount(), 1)

        // Below intentional delay is induced to check whether the unremoved tasks are removed from the cache.
        let timeInNanoSeconds = (timeInterval + 2) * 1000000000
        try? await Task.sleep(nanoseconds: UInt64(timeInNanoSeconds))
        XCTAssertEqual(sut.eventTimerManager.getCachedInteractionsCount(), 0) // asserts and ensures removal
    }

    // Helper Methods.
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
}