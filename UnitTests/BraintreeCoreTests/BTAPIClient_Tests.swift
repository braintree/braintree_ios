import XCTest
import BraintreeTestShared
@testable import BraintreeCore

class BTAPIClient_Tests: XCTestCase {
    private let mockConfigurationHTTP = FakeHTTP.fakeHTTP()

    override func setUp() {
        super.setUp()
        ConfigurationCache.shared.cacheInstance.removeAllObjects()
        mockConfigurationHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWith: [] as [Any?], statusCode: 200)
    }

    // MARK: - Initialization

    func testAPIClientInitialization_withValidTokenizationKey_setsValidAuthorization() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        XCTAssertEqual(apiClient?.authorization.originalValue, "development_testing_integration_merchant_id")
        XCTAssertEqual(apiClient?.authorization.type, .tokenizationKey)
    }

    func testInitialization_withInvalidTokenizationKey_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: "not_a_valid_tokenization_key"))
    }

    func testInitialization_withInvalidClientToken_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: "invalidclienttoken"))
    }

    func testAPIClientInitialization_withInvalidAuthorization_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: "invalid"))
    }

    func testAPIClientInitialization_withEmptyAuthorization_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: ""))
    }

    func testAPIClientInitialization_withValidClientToken_setsValidAuthorization() {
        let clientToken = TestClientTokenFactory.token(withVersion: 2)
        let apiClient = BTAPIClient(authorization: clientToken)
        XCTAssertEqual(apiClient?.authorization.originalValue, clientToken)
        XCTAssertEqual(apiClient?.authorization.type, .clientToken)
    }

    func testAPIClientInitialization_withVersionThreeClientToken_setsValidAuthorization() {
        let clientToken = TestClientTokenFactory.token(withVersion: 3)
        let apiClient = BTAPIClient(authorization: clientToken)
        XCTAssertEqual(apiClient?.authorization.originalValue, clientToken)
        XCTAssertEqual(apiClient?.authorization.type, .clientToken)
    }

    // MARK: - Dispatch Queue

    func testCallbacks_useMainDispatchQueue() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP = FakeHTTP.fakeHTTP()

        // Override apiClient.http so that requests don't fail
        apiClient?.http = mockHTTP
        apiClient?.configurationLoader = MockConfigurationLoader(http: mockHTTP)
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200

        let expectation1 = expectation(description: "Fetch configuration")
        apiClient?.fetchOrReturnRemoteConfiguration() { _, _ in
            XCTAssert(Thread.isMainThread)
            expectation1.fulfill()
        }

        let expectation2 = expectation(description: "GET request")
        apiClient?.get("/endpoint", parameters: nil) { _, response, error in
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssert(Thread.isMainThread)
            expectation2.fulfill()
        }

        let expectation3 = expectation(description: "POST request")
        apiClient?.post("/endpoint", parameters: nil) { _, response, error in
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssert(Thread.isMainThread)
            expectation3.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - Analytics

    func testAnalyticsService_isCreatedDuringInitialization() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        XCTAssertTrue(apiClient?.analyticsService is BTAnalyticsService)
    }

    func testSendAnalyticsEvent_whenCalled_callsAnalyticsService() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let mockAnalyticsService = FakeAnalyticsService()

        apiClient.analyticsService = mockAnalyticsService
        apiClient.sendAnalyticsEvent("blahblah")

        XCTAssertEqual(mockAnalyticsService.lastEvent, "blahblah")
    }

    func testFetchAPITiming_whenConfigurationPathIsValid_sendsLatencyEvent() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let mockAnalyticsService = FakeAnalyticsService()
        apiClient.analyticsService = mockAnalyticsService

        apiClient.fetchAPITiming(
            path: "/merchants/1234567890/client_api/v1/configuration",
            connectionStartTime: 123,
            requestStartTime: 456,
            startTime: 12345678,
            endTime: 0987654
        )

        XCTAssertEqual(mockAnalyticsService.lastEvent, "core:api-request-latency")
        XCTAssertEqual(mockAnalyticsService.endpoint, "/v1/configuration")
    }

    func testFetchAPITiming_whenPathIsBatchEvents_doesNotSendLatencyEvent() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let mockAnalyticsService = FakeAnalyticsService()
        apiClient.analyticsService = mockAnalyticsService

        apiClient.fetchAPITiming(
            path: "/v1/tracking/batch/events",
            connectionStartTime: 123,
            requestStartTime: 456,
            startTime: 12345678,
            endTime: 0987654
        )

        XCTAssertNil(mockAnalyticsService.lastEvent)
        XCTAssertNil(mockAnalyticsService.endpoint)
    }

    func testFetchAPITiming_whenPathIsNotBatchEvents_sendLatencyEvent() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let mockAnalyticsService = FakeAnalyticsService()
        apiClient.analyticsService = mockAnalyticsService

        apiClient.fetchAPITiming(
            path: "/merchants/1234567890/client_api/v1/paypal_hermes/create_payment_resource",
            connectionStartTime: 123,
            requestStartTime: 456,
            startTime: 12345678,
            endTime: 0987654
        )

        XCTAssertEqual(mockAnalyticsService.lastEvent, "core:api-request-latency")
        XCTAssertEqual(mockAnalyticsService.endpoint, "/v1/paypal_hermes/create_payment_resource")
    }

    // MARK: - Client SDK Metadata

    func testPOST_whenUsingGateway_includesMetadata() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP = FakeHTTP.fakeHTTP()
        let metadata = apiClient?.metadata

        apiClient?.http = mockHTTP
        apiClient?.configurationLoader = MockConfigurationLoader(http: mockHTTP)
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200

        let expectation = expectation(description: "POST callback")
        apiClient?.post("/", parameters: [:], httpType: .gateway) { _, _, _ in
            let metaParameters = mockHTTP.lastRequestParameters?["_meta"] as? [String: Any]
            XCTAssertEqual(metaParameters?["integration"] as? String, metadata?.integration.stringValue)
            XCTAssertEqual(metaParameters?["source"] as? String, metadata?.source.stringValue)
            XCTAssertEqual(metaParameters?["sessionId"] as? String, metadata?.sessionID)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testPOST_whenUsingGraphQLAPI_includesMetadata() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockGraphQLHTTP = FakeGraphQLHTTP.fakeHTTP()
        let mockHTTP = FakeHTTP.fakeHTTP()
        let metadata = apiClient?.metadata
        
        apiClient?.graphQLHTTP = mockGraphQLHTTP
        apiClient?.http = mockHTTP
        apiClient?.configurationLoader = MockConfigurationLoader(http: mockHTTP)
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200

        let expectation = expectation(description: "POST callback")
        apiClient?.post("/", parameters: [:], httpType: .graphQLAPI) { _, _, _ in
            let clientSdkMetadata = mockGraphQLHTTP.lastRequestParameters?["clientSdkMetadata"] as? [String: String]
            XCTAssertEqual(clientSdkMetadata?["integration"] as? String, metadata?.integration.stringValue)
            XCTAssertEqual(clientSdkMetadata?["source"] as? String, metadata?.source.stringValue)
            XCTAssertEqual(clientSdkMetadata?["sessionId"] as? String, metadata?.sessionID)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
    
    func testPOST_withEncodableParams_whenUsingGateway_includesMetadata() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP = FakeHTTP.fakeHTTP()
        let metadata = apiClient?.metadata

        apiClient?.http = mockHTTP
        apiClient?.configurationLoader = MockConfigurationLoader(http: mockHTTP)
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        
        let postParameters = FakeRequest(testValue: "fake-value")

        let expectation = expectation(description: "POST callback")
        apiClient?.post("/", parameters: postParameters, httpType: .gateway) { _, _, _ in
            XCTAssertEqual(mockHTTP.lastRequestParameters?["testValue"] as? String, "fake-value")
            
            let metaParameters = mockHTTP.lastRequestParameters?["_meta"] as? [String: Any]
            XCTAssertEqual(metaParameters?["integration"] as? String, metadata?.integration.stringValue)
            XCTAssertEqual(metaParameters?["source"] as? String, metadata?.source.stringValue)
            XCTAssertEqual(metaParameters?["sessionId"] as? String, metadata?.sessionID)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testPOST_withEncodableParams_whenUsingGraphQLAPI_includesMetadata() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockGraphQLHTTP = FakeGraphQLHTTP.fakeHTTP()
        let mockHTTP = FakeHTTP.fakeHTTP()
        let metadata = apiClient?.metadata

        apiClient?.graphQLHTTP = mockGraphQLHTTP
        apiClient?.http = mockHTTP
        apiClient?.configurationLoader = MockConfigurationLoader(http: mockHTTP)
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        
        let postParameters = FakeRequest(testValue: "fake-value")

        let expectation = expectation(description: "POST callback")
        apiClient?.post("/", parameters: postParameters, httpType: .graphQLAPI) { _, _, _ in
            XCTAssertEqual(mockGraphQLHTTP.lastRequestParameters?["testValue"] as? String, "fake-value")
            
            let clientSdkMetadata = mockGraphQLHTTP.lastRequestParameters?["clientSdkMetadata"] as? [String: String]
            XCTAssertEqual(clientSdkMetadata?["integration"] as? String, metadata?.integration.stringValue)
            XCTAssertEqual(clientSdkMetadata?["source"] as? String, metadata?.source.stringValue)
            XCTAssertEqual(clientSdkMetadata?["sessionId"] as? String, metadata?.sessionID)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Timeouts

    func testGETCallback_returnFetchConfigErrors() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP: FakeHTTP = FakeHTTP.fakeHTTP()
        apiClient?.http = mockHTTP
        apiClient?.configurationLoader = MockConfigurationLoader(http: mockHTTP)
        
        let mockError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost)
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWithError: mockError)

        let expectation = expectation(description: "GET request")
        apiClient?.get("/example", parameters: nil) { body, response, error in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            XCTAssertEqual(mockError, error as NSError?)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testPOSTCallback_returnFetchConfigErrors() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP: FakeHTTP = FakeHTTP.fakeHTTP()
        apiClient?.http = mockHTTP
        apiClient?.configurationLoader = MockConfigurationLoader(http: mockHTTP)
        
        let mockError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost)
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWithError: mockError)

        let expectation = expectation(description: "GET request")
        apiClient?.post("/example", parameters: nil) { body, response, error in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            XCTAssertEqual(mockError, error as NSError?)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)

    }
}
