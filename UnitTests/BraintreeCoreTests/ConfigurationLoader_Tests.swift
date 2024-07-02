import XCTest
import BraintreeTestShared
@testable import BraintreeCore

class ConfigurationLoader_Tests: XCTestCase {
    
    var mockHTTP: FakeHTTP!
    var sut: ConfigurationLoader!
    
    override func setUp() {
        super.setUp()
        mockHTTP = FakeHTTP.fakeHTTP()
        ConfigurationCache.shared.cacheInstance.removeAllObjects()
        sut = ConfigurationLoader(http: mockHTTP)
    }
    
    override func tearDown() {
        mockHTTP = nil
        sut = nil
        super.tearDown()
    }
  
    func testFetchOrReturnRemoteConfiguration_whenCached_returnsConfigFromCache() {
        let sampleJSON = ["test": "value", "environment": "fake-env1"]
        try? ConfigurationCache.shared.putInCache(authorization: "development_tokenization_key", configuration: BTConfiguration(json: BTJSON(value: sampleJSON)))
        let mockClientAuthorization = MockClientAuthorization(bearer: "development_tokenization_key")
        
        let expectation = expectation(description: "Callback invoked")
        sut.getConfig(mockClientAuthorization) { configuration, error in
            XCTAssertEqual(configuration?.environment, "fake-env1")
            XCTAssertEqual(configuration?.json?["test"].asString(), "value")
            XCTAssertNil(self.mockHTTP.lastRequestEndpoint)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testFetchOrReturnRemoteConfiguration_performsGETWithCorrectPayload() {
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/v1/configuration", respondWith: [] as [Any?], statusCode: 200)
        let mockClientAuthorization = MockClientAuthorization()

        let expectation = expectation(description: "Callback invoked")
        sut.getConfig(mockClientAuthorization) { _,_ in
            XCTAssertEqual(self.mockHTTP.lastRequestEndpoint, "v1/configuration")
            XCTAssertEqual(self.mockHTTP.lastRequestParameters?["configVersion"] as? String, "3")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testAPIClient_canGetRemoteConfiguration() {
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        let mockClientAuthorization = MockClientAuthorization()
        
        let expectation = expectation(description: "Fetch configuration")
        sut.getConfig(mockClientAuthorization) { configuration, error in
            XCTAssertNotNil(configuration)
            XCTAssertNil(error)
            XCTAssertGreaterThanOrEqual(self.mockHTTP.GETRequestCount, 1)

            guard let json = configuration?.json else { return }
            XCTAssertTrue(json["test"].isTrue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testConfiguration_whenServerRespondsWithNon200StatusCode_returnsAPIClientError() {
        mockHTTP.stubRequest(
            withMethod: "GET",
            toEndpoint: "/client_api/v1/configuration",
            respondWith: ["error_message": "Something bad happened"],
            statusCode: 503
        )
        let mockClientAuthorization = MockClientAuthorization()

        let expectation = expectation(description: "Callback invoked")
        sut.getConfig(mockClientAuthorization) { configuration, error in
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
        let mockError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost)
        let mockClientAuthorization = MockClientAuthorization()
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWithError: mockError)

        let expectation = expectation(description: "Fetch configuration")
        sut.getConfig(mockClientAuthorization) { configuration, error in
            // BTAPIClient fetches the config when initialized so there can potentially be 2 requests here
            XCTAssertLessThanOrEqual(self.mockHTTP.GETRequestCount, 2)
            XCTAssertNil(configuration)
            XCTAssertEqual(error as NSError?, mockError)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testGetConfig_returnsConfiguration() async throws {
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        let mockClientAuthorization = MockClientAuthorization()
        
        let asyncTask = Task {
            return try await sut.getConfig(mockClientAuthorization)
        }
        
        let returnedConfig = try await asyncTask.value
        
        XCTAssertTrue(returnedConfig.json!["test"].isTrue)
    }
    
    func testGetConfig_returnsNetworkErrorInCallback() async throws  {
        let mockError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost)
        let mockClientAuthorization = MockClientAuthorization()
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWithError: mockError)
        
        let asyncTask = Task {
            return try await sut.getConfig(mockClientAuthorization)
        }
        
        do {
            _ = try await asyncTask.value
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockError)
        }
    }
}
