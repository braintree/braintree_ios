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
  
    func testGetConfig_whenCached_returnsConfigFromCache() async {
        let sampleJSON = ["test": "value", "environment": "fake-env1"]
        try? ConfigurationCache.shared.putInCache(authorization: "development_tokenization_key", configuration: BTConfiguration(json: BTJSON(value: sampleJSON)))
        
        do {
            let configuration = try await sut.getConfig()
            XCTAssertEqual(configuration.environment, "fake-env1")
            XCTAssertEqual(configuration.json?["test"].asString(), "value")
            XCTAssertNil(self.mockHTTP.lastRequestEndpoint)
        } catch {
            XCTFail("Should not fail")
        }
    }

    func testGetConfig_performsGETWithCorrectPayload() async {
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/v1/configuration", respondWith: [] as [Any?], statusCode: 200)

        do {
            let _ = try await sut.getConfig()
        } catch {
            // no-op
        }

        XCTAssertEqual(self.mockHTTP.lastRequestEndpoint, "v1/configuration")
        XCTAssertEqual(self.mockHTTP.lastRequestParameters?["configVersion"] as? String, "3")
    }

    func testGetConfig_canGetRemoteConfiguration() async {
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200

        do {
            let configuration = try await sut.getConfig()
            XCTAssertNotNil(configuration)
            XCTAssertGreaterThanOrEqual(self.mockHTTP.GETRequestCount, 1)
            guard let json = configuration.json else { return }
            XCTAssertTrue(json["test"].isTrue)
        } catch {
            XCTFail("Should not fail")
        }
    }

    func testGetConfig_whenServerRespondsWithNon200StatusCode_returnsAPIClientError() async {
        mockHTTP.stubRequest(
            withMethod: "GET",
            toEndpoint: "/client_api/v1/configuration",
            respondWith: ["error_message": "Something bad happened"],
            statusCode: 503
        )

        do {
            let _ = try await sut.getConfig()
        } catch {
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTAPIClientError.errorDomain)
            XCTAssertEqual(error.code, BTAPIClientError.configurationUnavailable.errorCode)
            XCTAssertEqual(error.localizedDescription, "The operation couldn’t be completed. Unable to fetch remote configuration from Braintree API at this time.")
        }
    }

    func testGetConfig_whenNetworkHasError_returnsNetworkErrorInCallback() async {
        ConfigurationCache.shared.cacheInstance.removeAllObjects()
        let mockError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost)
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWithError: mockError)

        do {
            let _ = try await sut.getConfig()
        } catch {
            // BTAPIClient fetches the config when initialized so there can potentially be 2 requests here
            XCTAssertLessThanOrEqual(self.mockHTTP.GETRequestCount, 2)
            XCTAssertEqual(error as NSError?, mockError)
        }
    }

    func testGetConfig_returnsConfiguration() async throws {
        mockHTTP.cannedConfiguration = BTJSON(value: ["test": true])
        mockHTTP.cannedStatusCode = 200
        
        let asyncTask = Task {
            return try await sut.getConfig()
        }
        
        let returnedConfig = try await asyncTask.value
        
        XCTAssertTrue(returnedConfig.json!["test"].isTrue)
    }
    
    func testGetConfig_returnsNetworkErrorInCallback() async throws  {
        let mockError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost)
        mockHTTP.stubRequest(withMethod: "GET", toEndpoint: "/client_api/v1/configuration", respondWithError: mockError)
        
        let asyncTask = Task {
            return try await sut.getConfig()
        }
        
        do {
            _ = try await asyncTask.value
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockError)
        }
    }
    
    func testGetConfig_whenCalledInQuickSequence_onlySendsOneNetworkRequest() async {
        do {
            async let functionOne = sut.getConfig()
            async let two = sut.getConfig()
            async let three = sut.getConfig()
            async let four = sut.getConfig()
            let _ = try await (functionOne, two, three, four)
        } catch {
            // no op
        }

        XCTAssertEqual(mockHTTP.GETRequestCount, 1)
    }
}
