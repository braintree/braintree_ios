import XCTest
import BraintreeTestShared
import OHHTTPStubs
@testable import BraintreeCore

final class BTHTTP_Tests: XCTestCase {

    // MARK: - Properties

    var http: BTHTTP?
    var stubDescriptor: HTTPStubsDescriptor?

    var testURLSession: URLSession {
        let testConfiguration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        testConfiguration.protocolClasses = [BTHTTPTestProtocol.self]
        return URLSession(configuration: testConfiguration)
    }

    let fakeClientToken = try! BTClientToken(clientToken: TestClientTokenFactory.stubbedURLClientToken)
    let fakeTokenizationKey = try! TokenizationKey("development_tokenization_key")

    var fakeConfiguration: BTConfiguration {
        let json = BTJSON(value: [
            "clientApiUrl": "https://fake-client-api-url.com/base/path"
        ])
        return BTConfiguration(json: json)
    }

    // MARK: - Configuration

    override func setUp() {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: BTHTTPTestProtocol.testBaseURL())
        http?.session = testURLSession
        URLCache.shared.removeAllCachedResponses()
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Base URL tests

    func testRequests_whenNoConfigurationSet_usesConfigURLOnAuthorization() async throws {
        let http = BTHTTP(authorization: fakeTokenizationKey)
        http.session = testURLSession

        let (body, _) = try await http.httpRequest(method: .get, path: "200.json")
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.host, fakeTokenizationKey.configURL.host)
        XCTAssertEqual(httpRequest.url?.path, fakeTokenizationKey.configURL.path)
        XCTAssertEqual(httpRequest.url?.scheme, fakeTokenizationKey.configURL.scheme)
    }

    func testRequests_whenNoConfigurationSet_doesNotAppendPath() async throws {
        let http = BTHTTP(authorization: fakeTokenizationKey)
        http.session = testURLSession

        let (body, _) = try await http.httpRequest(method: .get, path: "/some-really-long-path")
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.path, fakeTokenizationKey.configURL.path)
    }

    func testRequests_whenConfigurationSet_usesClientAPIURLOnConfig() async throws {
        let http = BTHTTP(authorization: fakeTokenizationKey)
        http.session = testURLSession

        let (body, _) = try await http.httpRequest(method: .get, path: "", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.scheme, fakeConfiguration.clientAPIURL?.scheme)
        XCTAssertEqual(httpRequest.url?.host, fakeConfiguration.clientAPIURL?.host)
    }

    func testRequests_whenConfigurationSet_appendsPath() async throws {
        let (body, _) = try await http!.httpRequest(method: .get, path: "/some-really-long-path", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.path, "\(fakeConfiguration.clientAPIURL!.path)/some-really-long-path")
    }

    func testRequests_useTheSpecifiedURLScheme() async throws {
        let (body, _) = try await http!.get("200.json")
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.scheme, "bt-http-test")
    }

    // MARK: - HTTP Method tests

    func testSendsGETRequest() async throws {
        let (body, response) = try await http!.get("200.json", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
        XCTAssertEqual(httpRequest.httpMethod, "GET")
        XCTAssertNil(httpRequest.httpBody)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testSendsGETRequestWithParameters() async throws {
        let (body, response) = try await http!.get("200.json", configuration: fakeConfiguration, parameters: ["param": "value"])
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
        XCTAssertEqual(httpRequest.url?.query, "param=value&authorization_fingerprint=test-authorization-fingerprint")
        XCTAssertEqual(httpRequest.httpMethod, "GET")
        XCTAssertNil(httpRequest.httpBody)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testSendsPOSTRequest() async throws {
        let (body, response) = try await http!.post("200.json", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
        XCTAssertEqual(httpRequest.httpMethod, "POST")
        XCTAssertNil(httpRequest.url?.query)
        XCTAssertNil(httpRequest.httpBody)
        XCTAssertEqual(response.statusCode, 200)
    }

    func testSendsPOSTRequestWithCodableParameters() async throws {
        struct FakeCodable: Codable {
            let param: String
        }
        let parameters = FakeCodable(param: "value")

        let (body, response) = try await http!.post("200.json", configuration: fakeConfiguration, parameters: parameters)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
        XCTAssertEqual(httpRequest.httpMethod, "POST")
        XCTAssertNil(httpRequest.url?.query)
        XCTAssertEqual(response.statusCode, 200)

        guard let bodyData = httpRequestBody.data(using: .utf8) else { return XCTFail("Failed to encode request body as UTF-8") }
        let json = BTJSON(data: bodyData)
        XCTAssertEqual(json["param"].asString(), "value")
    }

    func testSendsPOSTRequestWithDictionaryParameters() async throws {
        let (body, response) = try await http!.post("200.json", configuration: fakeConfiguration, parameters: ["param": "value"])
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
        XCTAssertEqual(httpRequest.httpMethod, "POST")
        XCTAssertNil(httpRequest.url?.query)
        XCTAssertEqual(response.statusCode, 200)

        guard let bodyData = httpRequestBody.data(using: .utf8) else { return XCTFail("Failed to encode request body as UTF-8") }
        let json = BTJSON(data: bodyData)
        XCTAssertEqual(json["param"].asString(), "value")
    }

    // MARK: - Authentication

    func testGETRequests_whenBTHTTPInitializedWithAuthorizationFingerprint_sendAuthorizationInQueryParams() async throws {
        let (body, _) = try await http!.get("200.json", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url?.query, "authorization_fingerprint=test-authorization-fingerprint")
    }

    func testGETRequests_whenBTHTTPInitializedWithTokenizationKey_sendTokenizationKeyInHeader() async throws {
        http = BTHTTP(authorization: fakeTokenizationKey)
        http?.session = testURLSession

        let (body, _) = try await http!.get("200.json")
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.allHTTPHeaderFields?["Client-Key"], "development_tokenization_key")
    }

    func testPOSTRequests_whenBTHTTPInitializedWithAuthorizationFingerprint_sendAuthorizationInBody() async throws {
        let (body, _) = try await http!.post("200.json", configuration: fakeConfiguration)
        let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body)
        XCTAssertEqual(httpRequestBody, "{\"authorization_fingerprint\":\"test-authorization-fingerprint\"}")
    }

    func testPOSTRequests_whenBTHTTPInitializedWithPayPalAPIURL_sendsAuthorizationInHeader() async throws {
        let http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "https://api.paypal.com")!)
        http.session = testURLSession

        let (body, _) = try await http.post("200.json")
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.allHTTPHeaderFields?["Authorization"], "Bearer test-authorization-fingerprint")
    }

    func testPOSTRequests_whenBTHTTPInitializedWithTokenizationKey_sendAuthorization() async throws {
        http = BTHTTP(authorization: fakeTokenizationKey)
        http?.session = testURLSession

        let (body, _) = try await http!.post("200.json")
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.allHTTPHeaderFields?["Client-Key"], "development_tokenization_key")
    }

    // MARK: - Default headers tests

    func testIncludeAccept() async throws {
        // BTHTTPTestProtocol echoes request headers back in the response body — no stub needed
        let (body, _) = try await http!.get("200.json", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.allHTTPHeaderFields?["Accept"], "application/json")
    }

    func testIncludeUserAgent() async throws {
        let (body, _) = try await http!.get("200.json", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.allHTTPHeaderFields?["User-Agent"], "Braintree/iOS/\(BTCoreConstants.braintreeSDKVersion)")
    }

    func testIncludeAcceptLanguage() async throws {
        let (body, _) = try await http!.get("200.json", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        let locale = Locale.current
        let countryCode = (locale as NSLocale).object(forKey: .countryCode) as? String
        let expectedLanguageString = "\(locale.language.languageCode?.identifier ?? "")-\(countryCode ?? "")"
        XCTAssertEqual(httpRequest.allHTTPHeaderFields?["Accept-Language"], expectedLanguageString)
    }

    // MARK: - Parameters tests

    struct SampleRequest: Encodable {
        enum CodingKeys: String, CodingKey {
            case stringParameter
            case crazyStringParameter = "crazyStringParameter[]"
            case numericParameter
            case trueBooleanParameter
            case falseBooleanParameter
            case dictionaryParameter
            case arrayParameter
        }

        let stringParameter = "value"
        let crazyStringParameter = "crazy%20and&value"
        let numericParameter = 42
        let trueBooleanParameter = true
        let falseBooleanParameter = false
        let dictionaryParameter = ["dictionaryKey": "dictionaryValue"]
        let arrayParameter = ["arrayItem1", "arrayItem2"]
    }

    func testTransmitsTheParametersAsURLEncodedQueryParameters() async throws {
        let expectedQueryParameters = [
            "numericParameter=42",
            "falseBooleanParameter=0",
            "dictionaryParameter%5BdictionaryKey%5D=dictionaryValue",
            "trueBooleanParameter=1",
            "stringParameter=value",
            "crazyStringParameter%5B%5D=crazy%2520and%26value",
            "arrayParameter%5B%5D=arrayItem1",
            "arrayParameter%5B%5D=arrayItem2"
        ]

        let (body, _) = try await http!.get("200.json", parameters: SampleRequest())
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        let actualQueryComponents = httpRequest.url?.query?.components(separatedBy: "&")
        expectedQueryParameters.forEach { expectedComponent in
            XCTAssertTrue(actualQueryComponents!.contains(expectedComponent))
        }
    }

    func testTransmitsTheParametersAsJSON() async throws {
        let expectedParameters: [String: Any] = [
            "numericParameter": 42,
            "falseBooleanParameter": false,
            "dictionaryParameter": ["dictionaryKey": "dictionaryValue"],
            "trueBooleanParameter": true,
            "stringParameter": "value",
            "crazyStringParameter[]": "crazy%20and&value",
            "arrayParameter": ["arrayItem1", "arrayItem2"],
            "authorization_fingerprint": "test-authorization-fingerprint"
        ]

        let (body, _) = try await http!.post("200.json", parameters: SampleRequest())
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")

        guard let bodyData = httpRequestBody.data(using: .utf8) else { return XCTFail("Failed to encode request body as UTF-8") }
        let actualParameters = (try? JSONSerialization.jsonObject(with: bodyData)) as? [String: Any] ?? [:]
        XCTAssertTrue(actualParameters == expectedParameters)
    }

    // MARK: - DispatchQueue tests

    func testCallsBackOnMainQueue() async throws {
        let (_, _) = try await http!.get("200.json")
        await MainActor.run {
            XCTAssertTrue(Thread.isMainThread)
        }
    }

    // MARK: - Response Code Parser tests

    func testInterprets2xxAsACompletionWithSuccess() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: [] as [Any?], options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        let (_, response) = try await http!.get("200.json")
        XCTAssertEqual(response.statusCode, 200)
    }

    func testResponseCodeParsing_whenStatusCodeIs4xx_returnsError() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let errorBody: [String: Any] = ["error": ["message": "This is an error message from the gateway"]]
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: errorBody, options: .prettyPrinted),
                statusCode: 403,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.get("403.json")
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.clientError([:]).errorCode)
            XCTAssertEqual(error.localizedDescription, "This is an error message from the gateway")
            XCTAssertNotNil(error.userInfo[NSLocalizedFailureReasonErrorKey])
        }
    }

    func testResponseCodeParsing_whenStatusCodeIs429_returnsRateLimitError() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: [:] as [String: Any?], options: .prettyPrinted),
                statusCode: 429,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.get("429.json")
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.rateLimitError([:]).errorCode)
            XCTAssertEqual(error.userInfo[NSLocalizedDescriptionKey] as! String, "You are being rate-limited.")
            XCTAssertEqual(error.userInfo[NSLocalizedRecoverySuggestionErrorKey] as! String, "Please try again in a few minutes.")
            XCTAssertNotNil(error.userInfo[NSLocalizedFailureReasonErrorKey])
        }
    }

    func testResponseCodeParsing_whenStatusCodeIs5xx_returnsError() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let errorBody: [String: Any] = ["error": ["message": "This is an error message from the gateway"]]
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: errorBody, options: .prettyPrinted),
                statusCode: 503,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.get("503.json")
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.serverError([:]).errorCode)
            XCTAssertTrue(error.userInfo[BTCoreConstants.urlResponseKey] is HTTPURLResponse)
            XCTAssertEqual(error.localizedDescription, "This is an error message from the gateway")
            XCTAssertEqual(error.localizedRecoverySuggestion, "Please try again later.")
            XCTAssertNotNil(error.userInfo[NSLocalizedFailureReasonErrorKey])
        }
    }

    func testInterpretsTheNetworkBeingDownAsAnError() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(error: NSError(domain: URLError.errorDomain, code: URLError.notConnectedToInternet.rawValue))
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.get("network-down")
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, URLError.errorDomain)
            XCTAssertEqual(error.code, URLError.notConnectedToInternet.rawValue)
        }
    }

    func testInterpretsTheServerBeingUnavailableAsAnError() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(error: NSError(domain: URLError.errorDomain, code: URLError.cannotConnectToHost.rawValue))
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.get("gateway-down")
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, URLError.errorDomain)
            XCTAssertEqual(error.code, URLError.cannotConnectToHost.rawValue)
        }
    }

    // MARK: - Response Body Parser tests

    func testParsesAJSONResponseBody() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(data: "{\"status\": \"OK\"}".data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        defer { HTTPStubs.removeStub(stub) }

        let (body, response) = try await http!.get("200.json")
        XCTAssertEqual(body["status"].asString(), "OK")
        XCTAssertEqual(response.statusCode, 200)
    }

    func testAcceptsEmptyResponses() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        defer { HTTPStubs.removeStub(stub) }

        let (body, response) = try await http!.get("empty.json")
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(body.asDictionary()?.count, 0)
    }

    func testInterpretsInvalidJSONResponsesAsAJSONError() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(data: "{ really invalid json ]".data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.get("invalid.json")
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, NSCocoaErrorDomain)
        }
    }

    func testInterpretsNonJSONResponsesAsAContentTypeNotAcceptableError() async throws {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(data: "<html>response</html>".data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "text/html"])
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.get("200.html")
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.responseContentTypeNotAcceptable([:]).errorCode)
        }
    }

    // MARK: - URLSession metrics tests

    @available(iOS, deprecated: 13.0, message: "Required for mocking URLSessionTaskMetrics in tests")
    func testURLSessionTaskDidFinishCollectingMetrics() {
        let mockDelegate = MockNetworkTimingDelegate()
        http?.networkTimingDelegate = mockDelegate

        var originalRequest = URLRequest(url: URL(string: "https://example.com/graphql")!)
        originalRequest.httpBody = """
            {
                "operationName": "TestMutation",
                "query": "mutation TestMutation()"
            }
            """.data(using: .utf8)
        let task = testURLSession.dataTask(with: originalRequest)

        let transactionMetrics = MockURLSessionTaskTransactionMetrics()
        transactionMetrics.mockConnectStartDate = Date()
        transactionMetrics.mockFetchStartDate = Date()
        transactionMetrics.mockResponseEndDate = Date().addingTimeInterval(1)
        transactionMetrics.mockRequest = URLRequest(url: URL(string: "https://example.com/graphql")!)

        let metrics = MockURLSessionTaskMetrics(transactionMetrics: [transactionMetrics])

        http?.urlSession(testURLSession, task: task, didFinishCollecting: metrics)

        XCTAssertTrue(mockDelegate.didCallFetchAPITiming)
        XCTAssertEqual(mockDelegate.receivedPath, "mutation TestMutation")
        XCTAssertNotNil(mockDelegate.receivedConnectionStartTime)
        XCTAssertNotNil(mockDelegate.receivedRequestStartTime)
        XCTAssertNotNil(mockDelegate.receivedStartTime)
        XCTAssertNotNil(mockDelegate.receivedEndTime)
    }

    func testURLSessionConfiguration_hasCustomTimeoutSettings() {
        let sut = BTHTTP(authorization: fakeTokenizationKey)
        XCTAssertEqual(sut.session.configuration.timeoutIntervalForRequest, 30)
        XCTAssertEqual(sut.session.configuration.timeoutIntervalForResource, 30)
    }
}

extension [String: Any] {
    static func ==(lhs: [String: Any], rhs: [String: Any]) -> Bool {
        return NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }
}
