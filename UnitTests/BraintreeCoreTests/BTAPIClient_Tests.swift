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

    // MARK: - fetchOrReturnRemoteConfiguration
    
    func testFetchOrReturnRemoteConfiguration_whenCached_returnsConfigFromCache() {
        let sampleJSON = ["test": "value", "environment": "fake-env1"]
        try? ConfigurationCache.shared.putInCache(authorization: "development_tokenization_key", configuration: BTConfiguration(json: BTJSON(value: sampleJSON)))
        let mockHTTP = FakeHTTP.fakeHTTP()

        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        apiClient?.http = mockHTTP

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchOrReturnRemoteConfiguration() { configuration, error in
            XCTAssertEqual(configuration?.environment, "fake-env1")
            XCTAssertEqual(configuration?.json?["test"].asString(), "value")
            XCTAssertNil(mockHTTP.lastRequestEndpoint)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetchOrReturnRemoteConfiguration_performsGETWithCorrectPayload() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let mockHTTP = FakeHTTP.fakeHTTP()
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/v1/configuration", respondWith: [] as [Any?], statusCode: 200)
        apiClient?.http = mockHTTP

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchOrReturnRemoteConfiguration() { _,_ in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/configuration")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["configVersion"] as? String, "3")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testAPIClient_canGetRemoteConfiguration() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP = FakeHTTP.fakeHTTP()
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        apiClient?.http = mockHTTP

        let expectation = expectation(description: "Fetch configuration")
        apiClient?.fetchOrReturnRemoteConfiguration() { configuration, error in
            XCTAssertNotNil(configuration)
            XCTAssertNil(error)
            XCTAssertGreaterThanOrEqual(mockHTTP.GETRequestCount, 1)

            guard let json = configuration?.json else { return }
            XCTAssertTrue(json["test"].isTrue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testConfiguration_whenServerRespondsWithNon200StatusCode_returnsAPIClientError() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP = FakeHTTP.fakeHTTP()
        mockHTTP.stubRequest(
            withMethod: "GET",
            toEndpoint: "/client_api/v1/configuration",
            respondWith: ["error_message": "Something bad happened"],
            statusCode: 503
        )
        apiClient?.http = mockHTTP

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchOrReturnRemoteConfiguration() { configuration, error in
            guard let error = error as NSError? else { return }
            XCTAssertNil(configuration)
            XCTAssertEqual(error.domain, BTAPIClientError.errorDomain)
            XCTAssertEqual(error.code, BTAPIClientError.configurationUnavailable.rawValue)
            XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. Unable to fetch remote configuration from Braintree API at this time.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testConfiguration_whenNetworkHasError_returnsNetworkErrorInCallback() {
        ConfigurationCache.shared.cacheInstance.removeAllObjects()
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP = FakeHTTP.fakeHTTP()
        let mockError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost)

        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWithError: mockError)
        apiClient?.http = mockHTTP

        let expectation = expectation(description: "Fetch configuration")
        apiClient?.fetchOrReturnRemoteConfiguration() { configuration, error in
            // BTAPIClient fetches the config when initialized so there can potentially be 2 requests here
            XCTAssertLessThanOrEqual(mockHTTP.GETRequestCount, 2)
            XCTAssertNil(configuration)
            XCTAssertEqual(error as NSError?, mockError)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // MARK: - fetchPaymentMethodNonces with v2 client token
    
    func testFetchPaymentMethodNonces_performsGETWithCorrectParameter() {
        let apiClient = BTAPIClient(authorization: TestClientTokenFactory.validClientToken)
        let mockHTTP = FakeHTTP.fakeHTTP()

        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        apiClient?.http = mockHTTP

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchPaymentMethodNonces() { _,_ in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["default_first"] as? String, "false")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["session_id"] as? String, apiClient?.metadata.sessionID)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetchPaymentMethodNonces_whenDefaultFirstIsTrue_performsGETWithCorrectParameters() {
        let apiClient = BTAPIClient(authorization: TestClientTokenFactory.validClientToken)
        let mockHTTP = FakeHTTP.fakeHTTP()

        apiClient?.http = mockHTTP
        apiClient?.http = mockHTTP
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchPaymentMethodNonces(true) { _,_ in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["default_first"] as? String, "true")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetchPaymentMethodNonces_whenDefaultFirstIsFalse_performsGETWithCorrectParameters() {
        let apiClient = BTAPIClient(authorization: TestClientTokenFactory.validClientToken)
        let mockHTTP = FakeHTTP.fakeHTTP()

        apiClient?.http = mockHTTP
        apiClient?.http = mockHTTP
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchPaymentMethodNonces(false) { _,_ in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["default_first"] as? String, "false")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetchPaymentMethodNonces_returnsPaymentMethodNonces() {
        let apiClient = BTAPIClient(authorization: TestClientTokenFactory.validClientToken)
        let stubHTTP = FakeHTTP.fakeHTTP()
        let stubbedResponse = [
            "paymentMethods": [
                [
                    "default" : true,
                    "details": [
                        "cardType": "American Express",
                        "lastTwo": "05"
                    ],
                    "nonce": "fake-nonce1",
                    "type": "CreditCard"
                ] as [String: Any?],
                [
                    "default" : false,
                    "description": "jane.doe@example.com",
                    "details": [] as [Any?],
                    "nonce": "fake-nonce2",
                    "type": "PayPalAccount"
                ]
            ]
        ]

        stubHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        stubHTTP.cannedStatusCode = 200
        stubHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: stubbedResponse, statusCode: 200)
        apiClient?.http = stubHTTP

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchPaymentMethodNonces() { paymentMethodNonces, error in
            guard let paymentMethodNonces = paymentMethodNonces else {
                XCTFail()
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(paymentMethodNonces.count, 2)

            let firstNonce = paymentMethodNonces[0];
            XCTAssertEqual(firstNonce.nonce, "fake-nonce1")
            XCTAssertEqual(firstNonce.type, "AMEX")

            let secondNonce = paymentMethodNonces[1]
            XCTAssertEqual(secondNonce.nonce, "fake-nonce2")
            XCTAssertEqual(secondNonce.type, "PayPal")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // MARK: - fetchPaymentMethodNonces with tokenization key

    func testFetchPaymentMethodNonces_withTokenizationKey_returnsError() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        apiClient?.http = mockConfigurationHTTP

        let expectation = expectation(description: "Error returned")
        apiClient?.fetchPaymentMethodNonces() { paymentMethodNonces, error in
            XCTAssertNil(paymentMethodNonces)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error._domain, BTAPIClientError.errorDomain)
            XCTAssertEqual(error._code, BTAPIClientError.notAuthorized.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // MARK: - fetchPaymentMethodNonces with v3 client token

    func testFetchPaymentMethodNonces_performsGETWithCorrectParameter_withV3ClientToken() {
        let clientToken = TestClientTokenFactory.token(withVersion: 3)
        let apiClient = BTAPIClient(authorization: clientToken)
        let mockHTTP = FakeHTTP.fakeHTTP()

        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [] as [Any?], statusCode: 200)
        apiClient?.http = mockHTTP

        XCTAssertEqual((apiClient?.authorization as! BTClientToken).json["version"].asIntegerOrZero(), 3)

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchPaymentMethodNonces() { _,_ in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["default_first"] as? String, "false")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["session_id"] as? String, apiClient?.metadata.sessionID)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetchPaymentMethodNonces_whenDefaultFirstIsTrue_performsGETWithCorrectParameter_withV3ClientToken() {
        let clientToken = TestClientTokenFactory.token(withVersion: 3)
        let apiClient = BTAPIClient(authorization: clientToken)
        let mockHTTP = FakeHTTP.fakeHTTP()

        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [] as [Any?], statusCode: 200)
        apiClient?.http = mockHTTP

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchPaymentMethodNonces(true) { _,_ in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["default_first"] as? String, "true")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetchPaymentMethodNonces_whenDefaultFirstIsFalse_performsGETWithCorrectParameter_withV3ClientToken() {
        let clientToken = TestClientTokenFactory.token(withVersion: 3)
        let apiClient = BTAPIClient(authorization: clientToken)
        let mockHTTP = FakeHTTP.fakeHTTP()

        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/payment_methods", respondWith: [] as [Any?], statusCode: 200)
        apiClient?.http = mockHTTP

        let expectation = expectation(description: "Callback invoked")
        apiClient?.fetchPaymentMethodNonces(false) { _,_ in
            XCTAssertEqual(mockHTTP.lastRequestEndpoint, "v1/payment_methods")
            XCTAssertEqual(mockHTTP.lastRequestParameters?["default_first"] as? String, "false")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // MARK: - Dispatch Queue

    func testCallbacks_useMainDispatchQueue() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP = FakeHTTP.fakeHTTP()

        // Override apiClient.http so that requests don't fail
        apiClient?.http = mockHTTP
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

    func testAnalyticsService_byDefault_isASingleton() {
        let firstAPIClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let secondAPIClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        XCTAssertEqual(firstAPIClient?.analyticsService, secondAPIClient?.analyticsService)
    }

    func testAnalyticsService_isCreatedDuringInitialization() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        XCTAssertTrue(apiClient?.analyticsService is BTAnalyticsService)
    }

    func testSendAnalyticsEvent_whenCalled_callsAnalyticsService() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let mockAnalyticsService = FakeAnalyticsService(apiClient: apiClient)

        apiClient.analyticsService = mockAnalyticsService
        apiClient.sendAnalyticsEvent("blahblah")

        XCTAssertEqual(mockAnalyticsService.lastEvent, "blahblah")
    }

    func testFetchAPITiming_whenConfigurationPathIsValid_sendsLatencyEvent() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let mockAnalyticsService = FakeAnalyticsService(apiClient: apiClient)
        apiClient.analyticsService = mockAnalyticsService

        apiClient.fetchAPITiming(path: "/merchants/1234567890/client_api/v1/configuration", startTime: 12345678, endTime: 0987654)

        XCTAssertEqual(mockAnalyticsService.lastEvent, "core:api-request-latency")
        XCTAssertEqual(mockAnalyticsService.endpoint, "/v1/configuration")
    }

    func testFetchAPITiming_whenPathIsBatchEvents_doesNotSendLatencyEvent() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let mockAnalyticsService = FakeAnalyticsService(apiClient: apiClient)
        apiClient.analyticsService = mockAnalyticsService

        apiClient.fetchAPITiming(path: "/v1/tracking/batch/events", startTime: 12345678, endTime: 0987654)

        XCTAssertNil(mockAnalyticsService.lastEvent)
        XCTAssertNil(mockAnalyticsService.endpoint)
    }

    func testFetchAPITiming_whenPathIsNotBatchEvents_sendLatencyEvent() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let mockAnalyticsService = FakeAnalyticsService(apiClient: apiClient)
        apiClient.analyticsService = mockAnalyticsService

        apiClient.fetchAPITiming(path: "/merchants/1234567890/client_api/v1/paypal_hermes/create_payment_resource", startTime: 12345678, endTime: 0987654)

        XCTAssertEqual(mockAnalyticsService.lastEvent, "core:api-request-latency")
        XCTAssertEqual(mockAnalyticsService.endpoint, "/v1/paypal_hermes/create_payment_resource")
    }

    // MARK: - Client SDK Metadata

    func testPOST_whenUsingGateway_includesMetadata() {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")
        let mockHTTP = FakeHTTP.fakeHTTP()
        let metadata = apiClient?.metadata

        apiClient?.http = mockHTTP
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
        let mockResponse = [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ] as [String: Any]
        ]

        apiClient?.graphQLHTTP = mockGraphQLHTTP
        apiClient?.http = mockHTTP
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
        let mockResponse = [
            "graphQL": [
                "url": "graphql://graphql",
                "features": ["tokenize_credit_cards"]
            ] as [String: Any]
        ]

        apiClient?.graphQLHTTP = mockGraphQLHTTP
        apiClient?.http = mockHTTP
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
        let fakeConfigurationHTTP: FakeHTTP = FakeHTTP.fakeHTTP()
        apiClient?.http = fakeConfigurationHTTP

        let mockError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost)
        fakeConfigurationHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWithError: mockError)

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
        let fakeConfigurationHTTP: FakeHTTP = FakeHTTP.fakeHTTP()
        apiClient?.http = fakeConfigurationHTTP

        let mockError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost)
        fakeConfigurationHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWithError: mockError)

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
