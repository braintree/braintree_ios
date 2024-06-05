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
        http = BTHTTP(authorization: fakeClientToken)
        http?.session = testURLSession
        URLCache.shared.removeAllCachedResponses()
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Base URL tests
        
    func testRequests_whenNoConfigurationSet_usesConfigURLOnAuthorization() {
        let http = BTHTTP(authorization: fakeTokenizationKey)
        http.session = testURLSession
        let expectation = expectation(description: "GET callback")

        http.httpRequest(method: "ANY", path: "200.json") { body, _, error in
            XCTAssertNil(error)
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.host, self.fakeTokenizationKey.configURL.host)
            XCTAssertEqual(httpRequest.url?.path, self.fakeTokenizationKey.configURL.path)
            XCTAssertEqual(httpRequest.url?.scheme, self.fakeTokenizationKey.configURL.scheme)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testRequests_whenNoConfigurationSet_doesNotAppendPath() {
        let expectation = expectation(description: "callback")

        http?.httpRequest(method: "ANY", path: "/some-really-long-path") { body, _, error in
            XCTAssertNil(error)
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, self.fakeClientToken.configURL.path)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testRequests_whenConfigurationSet_usesClientAPIURLOnConfig() {
        let http = BTHTTP(authorization: fakeTokenizationKey)
        http.session = testURLSession
        let expectation = expectation(description: "callback")

        http.httpRequest(method: "ANY", path: "", configuration: fakeConfiguration) { body, _, error in
            XCTAssertNil(error)
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.scheme, self.fakeConfiguration.clientAPIURL?.scheme)
            XCTAssertEqual(httpRequest.url?.host, self.fakeConfiguration.clientAPIURL?.host)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testRequests_whenConfigurationSet_appendsPath() {
        let expectation = expectation(description: "callback")

        http?.httpRequest(method: "ANY", path: "/some-really-long-path", configuration: fakeConfiguration) { body, _, error in
            XCTAssertNil(error)
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url!.path, "\(self.fakeConfiguration.clientAPIURL!.path)/some-really-long-path")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testRequests_useTheSpecifiedURLScheme() {
        let expectation = expectation(description: "GET callback")

        http?.get("200.json") { body, _, error in
            XCTAssertNil(error)
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.scheme, "bt-http-test")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - HTTP Method tests

    func testSendsGETRequest() {
        let expectation = expectation(description: "GET request")
        
        http?.get("200.json", configuration: fakeConfiguration) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            XCTAssertEqual(httpRequest.httpMethod, "GET")
            XCTAssertNil(httpRequest.httpBody)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSendsGETRequestWithParameters() {
        let expectation = expectation(description: "GET request")

        http?.get("200.json", configuration: fakeConfiguration, parameters: ["param": "value"]) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            XCTAssertEqual(httpRequest.url?.query, "param=value&authorization_fingerprint=test-authorization-fingerprint")
            XCTAssertEqual(httpRequest.httpMethod, "GET")
            XCTAssertNil(httpRequest.httpBody)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSendsPOSTRequest() {
        let expectation = expectation(description: "POST request")

        http?.post("200.json", configuration: fakeConfiguration) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            XCTAssertEqual(httpRequest.httpMethod, "POST")
            XCTAssertNil(httpRequest.url?.query)
            XCTAssertNil(httpRequest.httpBody)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
    
    func testSendsPOSTRequestWithCodableParameters() {
        struct FakeCodable: Codable {
            let param: String
        }
        let parameters = FakeCodable(param: "value")
        
        let expectation = expectation(description: "POST request")

        http?.post("200.json", configuration: fakeConfiguration, parameters: parameters) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            XCTAssertEqual(httpRequest.httpMethod, "POST")
            XCTAssertNil(httpRequest.url?.query)

            let json = BTJSON(data: httpRequestBody.data(using: .utf8)!)
            XCTAssertEqual(json["param"].asString(), "value")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSendsPOSTRequestWithDictionaryParameters() {
        let expectation = expectation(description: "POST request")

        http?.post("200.json", configuration: fakeConfiguration, parameters: ["param": "value"]) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            XCTAssertEqual(httpRequest.httpMethod, "POST")
            XCTAssertNil(httpRequest.url?.query)

            let json = BTJSON(data: httpRequestBody.data(using: .utf8)!)
            XCTAssertEqual(json["param"].asString(), "value")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Authentication

    func testGETRequests_whenBTHTTPInitializedWithAuthorizationFingerprint_sendAuthorizationInQueryParams() {
        let expectation = expectation(description: "Request with authorization")

        http?.get("200.json", configuration: fakeConfiguration) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.query, "authorization_fingerprint=test-authorization-fingerprint")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testGETRequests_whenBTHTTPInitializedWithTokenizationKey_sendTokenizationKeyInHeader() {
        http = BTHTTP(authorization: fakeTokenizationKey)
        http?.session = testURLSession

        let expectation = expectation(description: "GET callback")
        http?.get("200.json") {body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.allHTTPHeaderFields?["Client-Key"], "development_tokenization_key")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testPOSTRequests_whenBTHTTPInitializedWithAuthorizationFingerprint_sendAuthorizationInBody() {
        let expectation = expectation(description: "POST callback")

        http?.post("200.json", configuration: fakeConfiguration) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body!)
            XCTAssertEqual(httpRequestBody, "{\"authorization_fingerprint\":\"test-authorization-fingerprint\"}")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
    
    func testPOSTRequests_whenBTHTTPInitializedWithPayPalAPIURL_sendsAuthorizationInHeader() {
        let expectation = expectation(description: "POST callback")

        let http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "https://api.paypal.com")!)
        http.session = testURLSession
        
        http.post("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.allHTTPHeaderFields?["Authorization"], "Bearer test-authorization-fingerprint")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testPOSTRequests_whenBTHTTPInitializedWithTokenizationKey_sendAuthorization() {
        http = BTHTTP(authorization: fakeTokenizationKey)
        http?.session = testURLSession

        let expectation = expectation(description: "POST callback")
        http?.post("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.allHTTPHeaderFields?["Client-Key"], "development_tokenization_key")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Default headers tests

    func testIncludeAccept() {
        withStub() {
            http?.get("stub://200/resource") { body, response, error in
                XCTAssertNotNil(body)
                XCTAssertNotNil(response)
                XCTAssertNil(error)

                let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
                let requestHeaders = httpRequest.allHTTPHeaderFields
                XCTAssertEqual(requestHeaders?["Accept"], "application/json")
            }
        }
    }

    func testIncludeUserAgent() {
        withStub {
            http?.get("stub://200/resource") { body, response, error in
                XCTAssertNotNil(body)
                XCTAssertNotNil(response)
                XCTAssertNil(error)

                let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
                let requestHeaders = httpRequest.allHTTPHeaderFields
                XCTAssertEqual(requestHeaders?["User-Agent"], "Braintree/iOS/\(BTCoreConstants.braintreeSDKVersion)")
            }
        }
    }

    func testIncludeAcceptLanguage() {
        withStub {
            http?.get("stub://200/resource") { body, response, error in
                XCTAssertNotNil(body)
                XCTAssertNotNil(response)
                XCTAssertNil(error)

                let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
                let requestHeaders = httpRequest.allHTTPHeaderFields
                let locale = Locale.current
                let countryCode = (locale as NSLocale).object(forKey: .countryCode) as? String
                let expectedLanguageString = "\(locale.languageCode ?? "")-\(countryCode ?? "")"
                XCTAssertEqual(requestHeaders?["Accept-Language"], expectedLanguageString)
            }
        }
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

    func testTransmitsTheParametersAsURLEncodedQueryParameters() {
        let expectation = expectation(description: "GET request")
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

        http?.get("200.json", parameters: SampleRequest()) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            let actualQueryComponents = httpRequest.url?.query?.components(separatedBy: "&")

            expectedQueryParameters.forEach { expectedComponent in
                XCTAssertTrue(actualQueryComponents!.contains(expectedComponent))
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testTransmitsTheParametersAsJSON() {
        let expectation = expectation(description: "POST request")
        let expectedParameters: [String: Any] = [
            "numericParameter": 42,
            "falseBooleanParameter": false,
            "dictionaryParameter": ["dictionaryKey": "dictionaryValue"],
            "trueBooleanParameter": true,
            "stringParameter": "value",
            "crazyStringParameter[]": "crazy%20and&value",
            "arrayParameter": [ "arrayItem1", "arrayItem2" ],
            "authorization_fingerprint": "test-authorization-fingerprint"
        ]

        http?.post("200.json", parameters: SampleRequest()) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")

            let actualParameters = try? JSONSerialization.jsonObject(with: httpRequestBody.data(using: .utf8)!) as? [String: Any] ?? [:]
            XCTAssertTrue(actualParameters! == expectedParameters)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - DispatchQueue tests

    func testCallsBackOnMainQueue() {
        let expectation = expectation(description: "Receive callback")

        http?.get("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let name = __dispatch_queue_get_label(nil)
            let currentQueue = String(cString: name, encoding: .utf8)
            XCTAssertEqual(currentQueue, DispatchQueue.main.label)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testCallsBackOnSpecifiedQueue() {
        let expectation = expectation(description: "Receive callback")
        http?.dispatchQueue = DispatchQueue(label: "com.braintreepayments.BTHTTPSpec.callbackQueueTest")

        http?.get("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let name = __dispatch_queue_get_label(nil)
            let currentQueue = String(cString: name, encoding: .utf8)
            XCTAssertEqual(currentQueue, self.http?.dispatchQueue.label)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Response Code Parser tests

    func testInterprets2xxAsACompletionWithSuccess() {
        let expectation = expectation(description: "GET callback")
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: [] as [Any?], options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.get("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.statusCode, 200)
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testResponseCodeParsing_whenStatusCodeIs4xx_returnsError() {
        let expectation = expectation(description: "GET callback")
        let errorBody: [String: Any] = ["error": ["message": "This is an error message from the gateway"]]
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: errorBody, options: .prettyPrinted),
                statusCode: 403,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.get("403.json") { body, response, error in
            XCTAssertEqual(body?.asDictionary(), errorBody as NSDictionary)
            XCTAssertNotNil(response)

            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.clientError([:]).errorCode)
            XCTAssertEqual(error.localizedDescription, "This is an error message from the gateway")
            XCTAssertNotNil(error.userInfo[NSLocalizedFailureReasonErrorKey])
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testResponseCodeParsing_whenStatusCodeIs429_returnsRateLimitError() {
        let expectation = expectation(description: "GET callback")
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: [:] as [String: Any?], options: .prettyPrinted),
                statusCode: 429,
                headers: ["Content-Type": "application/json"]
                )
        }

        http?.get("429.json") { body, response, error in
            XCTAssertEqual(body?.asDictionary(), [:])
            XCTAssertNotNil(response)

            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.rateLimitError([:]).errorCode)
            XCTAssertEqual(error.userInfo[NSLocalizedDescriptionKey] as! String, "You are being rate-limited.")
            XCTAssertEqual(error.userInfo[NSLocalizedRecoverySuggestionErrorKey] as! String, "Please try again in a few minutes.")
            XCTAssertNotNil(error.userInfo[NSLocalizedFailureReasonErrorKey])
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testResponseCodeParsing_whenStatusCodeIs5xx_returnsError() {
        let expectation = expectation(description: "GET callback")
        let errorBody: [String: Any] = ["error": ["message": "This is an error message from the gateway"]]
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: errorBody, options: .prettyPrinted),
                statusCode: 503,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.get("503.json") { body, response, error in
            XCTAssertEqual(body?.asDictionary(), errorBody as NSDictionary)
            XCTAssertNotNil(response)

            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.serverError([:]).errorCode)
            XCTAssertTrue(error.userInfo[BTCoreConstants.urlResponseKey] is HTTPURLResponse)
            XCTAssertEqual(error.localizedDescription, "This is an error message from the gateway")
            XCTAssertEqual(error.localizedRecoverySuggestion, "Please try again later.")
            XCTAssertNotNil(error.userInfo[NSLocalizedFailureReasonErrorKey])
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testInterpretsTheNetworkBeingDownAsAnError() {
        let expectation = expectation(description: "GET callback")
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(error: NSError(domain: URLError.errorDomain, code: URLError.notConnectedToInternet.rawValue))
        }

        http?.get("network-down") { body, response, error in
            XCTAssertNil(body)
            XCTAssertNil(response)

            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, URLError.errorDomain)
            XCTAssertEqual(error.code, URLError.notConnectedToInternet.rawValue)
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testInterpretsTheServerBeingUnavailableAsAnError() {
        let expectation = expectation(description: "GET callback")
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(error: NSError(domain: URLError.errorDomain, code: URLError.cannotConnectToHost.rawValue))
        }

        http?.get("gateway-down") { body, response, error in
            XCTAssertNil(body)
            XCTAssertNil(response)

            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, URLError.errorDomain)
            XCTAssertEqual(error.code, URLError.cannotConnectToHost.rawValue)
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Response Body Parser tests

    func testParsesAJSONResponseBody() {
        let expectation = expectation(description: "GET callback")
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(data: "{\"status\": \"OK\"}".data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        http?.get("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(body?["status"].asString(), "OK")
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testAcceptsEmptyResponses() {
        let expectation = expectation(description: "GET callback")
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        http?.get("empty.json") { body, response, error in
            XCTAssertEqual(response?.statusCode, 200)
            XCTAssertNotNil(body)
            XCTAssertEqual(body?.asDictionary()?.count, 0)
            XCTAssertNil(error)
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testInterpretsInvalidJSONResponsesAsAJSONError() {
        let expectation = expectation(description: "GET callback")
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(data: "{ really invalid json ]".data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        http?.get("invalid.json") { body, response, error in
            XCTAssertNil(body)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, NSCocoaErrorDomain)
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testInterpretsNonJSONResponsesAsAContentTypeNotAcceptableError() {
        let expectation = expectation(description: "GET callback")
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(data: "<html>response</html>".data(using: .utf8)!, statusCode: 200, headers: ["Content-Type": "text/html"])
        }

        http?.get("200.html") { body, response, error in
            XCTAssertNil(body)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.responseContentTypeNotAcceptable([:]).errorCode)
            HTTPStubs.removeStub(stub)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testNoopsForANilCompletionBlock() {
        http = BTHTTP(authorization: fakeClientToken, customBaseURL: URL(string: "stub://stub")!)

        http?.get("200.json") { body, response, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                // no-op
            }
        }
    }

    // MARK: - Helper Methods

    func withStub(_ completion: () -> Void) {
        let stub = HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            let jsonResponse: Data = try! JSONSerialization.data(
                withJSONObject: ["requestHeaders": request.allHTTPHeaderFields],
                options: .prettyPrinted
            )

            return HTTPStubsResponse(data: jsonResponse, statusCode: 200, headers: ["Content-Type": "application/json"])
        }

        HTTPStubs.removeStub(stub)
        completion()
    }
}

extension [String: Any] {
    static func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
        return NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }
}
