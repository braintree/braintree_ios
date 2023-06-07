import XCTest
import OHHTTPStubs
@testable import BraintreeCore

final class BTHTTP_Tests: XCTestCase {

    // MARK: - Properties

    var http: BTHTTP?
    var stubDescriptor: HTTPStubsDescriptor?

    var validDataURL: URL {
        let validObject: [String: Any] = [
            "clientId": "a-client-id",
            "nest": ["nested":"nested-value"]
        ]

        let configurationData: Data = try! JSONSerialization.data(withJSONObject: validObject)
        let base64EncodedConfigurationData: String = configurationData.base64EncodedString()
        let dataURLString: String = "data:application/json;base64,\(base64EncodedConfigurationData)"
        return URL(string: dataURLString)!
    }

    var parameterDictionary: [String: Any] {
        [
            "stringParameter": "value",
            "crazyStringParameter[]": "crazy%20and&value",
            "numericParameter": 42,
            "trueBooleanParameter": true,
            "falseBooleanParameter": false,
            "dictionaryParameter":  [ "dictionaryKey": "dictionaryValue" ],
            "arrayParameter": ["arrayItem1", "arrayItem2"]
        ]
    }

    var testURLSession: URLSession {
        let testConfiguration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        testConfiguration.protocolClasses = [BTHTTPTestProtocol.self]
        return URLSession(configuration: testConfiguration)
    }

    // MARK: - Configuration

    override func setUp() {
        http = BTHTTP(url: BTHTTPTestProtocol.testBaseURL(), authorizationFingerprint: "test-authorization-fingerprint")
        http?.session = testURLSession
        URLCache.shared.removeAllCachedResponses()
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Base URL tests

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

    func testRequests_useTheHostAtTheBaseURL() {
        let expectation = expectation(description: "GET callback")

        http?.get("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.absoluteString, "bt-http-test://base.example.com:1234/base/path/200.json?authorization_fingerprint=test-authorization-fingerprint")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testItAppendsThePathToTheBaseURL() {
        let expectation = expectation(description: "GET callback")

        http?.get("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func test_whenThePathIsNil_itHitsTheBaseURL() {
        let expectation = expectation(description: "GET callback")

        http?.get("/") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - data base URLs

    func testReturnsTheData() {
        let expectation = expectation(description: "GET callback")
        http = BTHTTP(url: validDataURL, authorizationFingerprint: "test-authorization-fingerprint")

        http?.get("/") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(body?["clientId"].asString(), "a-client-id")
            XCTAssertEqual(body?["nest"]["nested"].asString(), "nested-value")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testIgnoresPOSTData() {
        let expectation = expectation(description: "Perform request")
        http = BTHTTP(url: validDataURL, authorizationFingerprint: "test-authorization-fingerprint")

        http?.post("/", parameters: ["a-post-param": "POST"]) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testIgnoresGETParameters() {
        let expectation = expectation(description: "Perform request")
        http = BTHTTP(url: validDataURL, authorizationFingerprint: "test-authorization-fingerprint")

        http?.get("/", parameters: ["a-get-param": "GET"]) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testIgnoresTheSpecifiedPath() {
        let expectation = expectation(description: "Perform request")
        http = BTHTTP(url: validDataURL, authorizationFingerprint: "test-authorization-fingerprint")

        http?.get("/resource") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSetsTheContentTypeHeader() {
        let dataURL: URL = URL(string: "data:text/plain;base64,SGVsbG8sIFdvcmxkIQo=")!
        let expectation = expectation(description: "Perform request")
        http = BTHTTP(url: dataURL, authorizationFingerprint: "test-authorization-fingerprint")

        http?.get("/") { body, response, error in
            XCTAssertNil(body)
            XCTAssertNil(response)
            guard let error = error as NSError? else { return }
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.responseContentTypeNotAcceptable([:]).errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSetsTheResponseStatusCode() {
        let expectation = expectation(description: "Perform request")
        http = BTHTTP(url: validDataURL, authorizationFingerprint: "test-authorization-fingerprint")

        http?.get("/") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertNotNil(response?.statusCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testFailsLikeAnHTTP500WhenTheBase64EncodedDataIsInvalid() {
        let expectation = expectation(description: "Perform request")
        let dataStringURL = "data:application/json;base64,BAD-BASE-64-STRING"
        http = BTHTTP(url: URL(string: dataStringURL)!, authorizationFingerprint: "test-authorization-fingerprint")

        http?.get("/") { body, response, error in
            XCTAssertNil(body)
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - HTTP Method tests

    func testSendsGETRequest() {
        let expectation = expectation(description: "GET request")

        http?.get("200.json") { body, response, error in
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

        http?.get("200.json", parameters: ["param": "value"]) { body, response, error in
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

        http?.post("200.json") { body, response, error in
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

        http?.post("200.json", parameters: parameters) { body, response, error in
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

        http?.post("200.json", parameters: ["param": "value"]) { body, response, error in
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

    func testSendsPUTRequest() {
        let expectation = expectation(description: "PUT request")

        http?.put("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            XCTAssertEqual(httpRequest.httpMethod, "PUT")
            XCTAssertNil(httpRequest.httpBody)
            XCTAssertNil(httpRequest.url?.query)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSendsPUTRequestWithParameters() {
        let expectation = expectation(description: "PUT request")

        http?.put("200.json", parameters: ["param": "value"]) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            XCTAssertEqual(httpRequest.httpMethod, "PUT")
            XCTAssertNil(httpRequest.url?.query)

            let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body!)
            let json = BTJSON(data: httpRequestBody.data(using: .utf8)!)
            XCTAssertEqual(json["param"].asString(), "value")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSendsADELETERequest() {
        let expectation = expectation(description: "DELETE request")

        http?.delete("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            XCTAssertEqual(httpRequest.httpMethod, "DELETE")
            XCTAssertNil(httpRequest.httpBody)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testSendsDELETERequestWithParameters() {
        let expectation = expectation(description: "DELETE request")

        http?.delete("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.path, "/base/path/200.json")
            XCTAssertEqual(httpRequest.url?.query, "authorization_fingerprint=test-authorization-fingerprint")
            XCTAssertEqual(httpRequest.httpMethod, "DELETE")
            XCTAssertNil(httpRequest.httpBody)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Configuration tests

    func testGETRequests_whenShouldCache_cachesConfiguration() {
        URLCache.shared.removeAllCachedResponses()
        let expectation = expectation(description: "Fetches configuration")

        http?.get("/configuration", parameters: ["configVersion": "3"], shouldCache: true) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertNotNil(URLCache.shared.cachedResponse(for: httpRequest))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
        URLCache.shared.removeAllCachedResponses()
    }

    func testGETRequests_whenShouldNotCache_doesNotStoreInCache() {
        URLCache.shared.removeAllCachedResponses()
        let expectation = expectation(description: "Fetches configuration")

        http?.get("/configuration", parameters: ["configVersion": "3"], shouldCache: false) { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertNil(URLCache.shared.cachedResponse(for: httpRequest))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Authentication

    func testGETRequests_whenBTHTTPInitializedWithAuthorizationFingerprint_sendAuthorizationInQueryParams() {
        let expectation = expectation(description: "Request with authorization")

        http?.get("200.json") { body, response, error in
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
        http = BTHTTP(url: BTHTTPTestProtocol.testBaseURL(), tokenizationKey: "development_tokenization_key")
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

        http?.post("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body!)
            XCTAssertEqual(httpRequestBody, "{\"authorization_fingerprint\":\"test-authorization-fingerprint\"}")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
    
    func testPOSTRequests_whenBTHTTPInitializedWithPayPalAPIURL_doesNotSendAuthorizationInBody() {
        let expectation = expectation(description: "POST callback")

        let http = BTHTTP(url: URL(string: "https://api-m.paypal.com")!, authorizationFingerprint: "test-authorization-fingerprint")
        http.session = testURLSession
        
        http.post("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body!)
            XCTAssertFalse(httpRequestBody.contains("authorization_fingerprint"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testPOSTRequests_whenBTHTTPInitializedWithTokenizationKey_sendAuthorization() {
        http = BTHTTP(url: BTHTTPTestProtocol.testBaseURL(), tokenizationKey: "development_tokenization_key")
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

    func testPUTRequests_whenBTHTTPInitializedWithAuthorizationFingerprint_sendAuthorizationInBody() {
        let expectation = expectation(description: "PUT callback")

        http?.put("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequestBody = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body!)
            XCTAssertEqual(httpRequestBody, "{\"authorization_fingerprint\":\"test-authorization-fingerprint\"}")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testPUTRequests_whenBTHTTPInitializedWithTokenizationKey_sendAuthorization() {
        http = BTHTTP(url: BTHTTPTestProtocol.testBaseURL(), tokenizationKey: "development_tokenization_key")
        http?.session = testURLSession

        let expectation = expectation(description: "POST callback")
        http?.put("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.allHTTPHeaderFields?["Client-Key"], "development_tokenization_key")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testDELETERequests_whenBTHTTPInitializedWithAuthorizationFingerprint_sendAuthorizationInQueryParams() {
        let expectation = expectation(description: "DELETE callback")

        http?.delete("200.json") { body, response, error in
            XCTAssertNotNil(body)
            XCTAssertNotNil(response)
            XCTAssertNil(error)

            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            XCTAssertEqual(httpRequest.url?.query, "authorization_fingerprint=test-authorization-fingerprint")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testDELETERequests_whenBTHTTPInitializedWithTokenizationKey_sendAuthorization() {
        http = BTHTTP(url: BTHTTPTestProtocol.testBaseURL(), tokenizationKey: "development_tokenization_key")
        http?.session = testURLSession

        let expectation = expectation(description: "DELETE callback")
        http?.delete("200.json") { body, response, error in
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

        http?.get("200.json", parameters: parameterDictionary) { body, response, error in
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

        http?.post("200.json", parameters: parameterDictionary) { body, response, error in
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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

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
        http = BTHTTP(url: URL(string: "stub://stub")!, authorizationFingerprint: "test-authorization-fingerprint")

        http?.get("200.json") { body, response, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                // no-op
            }
        }
    }

    // MARK: - IsEqual tests

    func testReturnsTrueIfBTHTTPsHaveTheSameBaseURLAndAuthorizationFingerprint() {
        let baseURL: URL = URL(string: "an-url://hi")!
        let authorizationFingerprint: String = "test-authorization-fingerprint"
        let http1: BTHTTP = BTHTTP(url: baseURL, authorizationFingerprint: authorizationFingerprint)
        let http2: BTHTTP = BTHTTP(url: baseURL, authorizationFingerprint: authorizationFingerprint)
        XCTAssertEqual(http1, http2)
    }

    func testReturnsFalseIfBTHTTPsDoNotHaveTheSameBaseURL() {
        let baseURL1: URL = URL(string: "an-url://hi")!
        let baseURL2: URL = URL(string: "an-url://hi-again")!
        let authorizationFingerprint: String = "test-authorization-fingerprint"
        let http1: BTHTTP = BTHTTP(url: baseURL1, authorizationFingerprint: authorizationFingerprint)
        let http2: BTHTTP = BTHTTP(url: baseURL2, authorizationFingerprint: authorizationFingerprint)
        XCTAssertNotEqual(http1, http2)
    }

    func testReturnsFalseIfBTHTTPsDoNotHaveTheSameAuthorizationFingerprint() {
        let baseURL: URL = URL(string: "an-url://hi")!
        let authorizationFingerprint1: String = "test-authorization-fingerprint"
        let authorizationFingerprint2: String = "OTHER"
        let http1: BTHTTP = BTHTTP(url: baseURL, authorizationFingerprint: authorizationFingerprint1)
        let http2: BTHTTP = BTHTTP(url: baseURL, authorizationFingerprint: authorizationFingerprint2)
        XCTAssertNotEqual(http1, http2)
    }

    // MARK: - Copy tests

    func testReturnsAnEqualInstance() {
        http = BTHTTP(url: BTHTTPTestProtocol.testBaseURL(), authorizationFingerprint: "test-authorization-fingerprint")
        XCTAssertEqual(http, http?.copy() as? BTHTTP)
    }

    func testReturnedInstanceHasTheSameCertificates() {
        http = BTHTTP(url: BTHTTPTestProtocol.testBaseURL(), authorizationFingerprint: "test-authorization-fingerprint")
        let copiedHTTP = http?.copy() as? BTHTTP
        XCTAssertEqual(http?.pinnedCertificates, copiedHTTP?.pinnedCertificates)
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
