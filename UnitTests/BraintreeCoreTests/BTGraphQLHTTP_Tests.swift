import XCTest
import OHHTTPStubs
import BraintreeTestShared
@testable import BraintreeCore

final class BTGraphQLHTTP_Tests: XCTestCase {

    var http: BTGraphQLHTTP?

    var fakeSession: URLSession {
        let testConfiguration = URLSessionConfiguration.ephemeral
        testConfiguration.protocolClasses = [BTHTTPTestProtocol.self]
        return URLSession(configuration: testConfiguration)
    }

    var fakeConfiguration: BTConfiguration {
        let json = BTJSON(value: [
            "clientApiUrl": "https://fake-client-api-url.com/path",
            "graphQL": [
                "url": BTHTTPTestProtocol.testBaseURL().absoluteString
            ]
        ])
        return BTConfiguration(json: json)
    }

    override func setUp() {
        let fakeClientToken = try! BTClientToken(clientToken: TestClientTokenFactory.stubbedURLClientToken)
        http = BTGraphQLHTTP(authorization: fakeClientToken)
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }

    // MARK: - Basic request handling

    func testRequests_usesGraphQLURLFromConfig() async throws {
        http?.session = fakeSession
        let (body, _) = try await http!.post("", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertTrue(httpRequest.url!.absoluteString.contains("bt-http-test://base.example.com:1234/base/path"))
    }

    func testRequests_whenNilConfig_throwsError() async {
        http?.session = fakeSession
        do {
            _ = try await http!.post("")
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "com.braintreepayments.BTHTTPErrorDomain")
            XCTAssertEqual(error.code, 4)
        }
    }

    func testRequests_whenConfigMissingGraphQLURL_throwsError() async {
        let json = BTJSON(value: [
            "clientApiUrl": "https://fake-client-api-url.com/path",
            "graphQL": []
        ])
        let fakeConfiguration = BTConfiguration(json: json)
        http?.session = fakeSession

        do {
            _ = try await http!.post("", configuration: fakeConfiguration)
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, "com.braintreepayments.BTHTTPErrorDomain")
            XCTAssertEqual(error.code, 4)
        }
    }

    func testRequests_ignoreThePath() async throws {
        http?.session = fakeSession
        let (body, _) = try await http!.post("hey/go/here.html", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.url!.absoluteString, "bt-http-test://base.example.com:1234/base/path")
    }

    // MARK: - Unsupported requests

    func testGETRequests_areUnsupported() async {
        do {
            _ = try await http!.get("")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? BTGraphQLHTTPError, BTGraphQLHTTPError.unsupportedOperation)
        }
    }

    // MARK: - POST requests

    func testPOSTRequests_sendsParametersInBody() async throws {
        http?.session = fakeSession
        let (body, _) = try await http!.post("", configuration: fakeConfiguration, parameters: ["hey": "now"])
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        let bodyJSONData = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body).data(using: .utf8)
        let bodyJSON = try? JSONSerialization.jsonObject(with: bodyJSONData!) as? [String: String] ?? [:]

        XCTAssertEqual(httpRequest.url!.absoluteString, "bt-http-test://base.example.com:1234/base/path")
        XCTAssertEqual(bodyJSON, ["hey": "now"])
    }

    func testPOSTRequests_whenSuccessful_returnsData() async throws {
        let stubResponseData: [String: Any] = ["success": true]
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubResponseData, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        let (body, _) = try await http!.post("", configuration: fakeConfiguration, parameters: ["hey": "now"])
        XCTAssertEqual(body.asDictionary(), stubResponseData as NSDictionary)
    }

    // MARK: - Headers

    func testRequests_sendUserAgentHeader() async throws {
        http?.session = fakeSession
        let (body, _) = try await http!.post("", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertTrue((httpRequest.allHTTPHeaderFields!["User-Agent"])!.matches("^Braintree/iOS/\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$"))
    }

    func testRequests_sendBraintreeVersionHeader() async throws {
        http?.session = fakeSession
        let (body, _) = try await http!.post("", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.allHTTPHeaderFields!["Braintree-Version"], "2018-03-06")
    }

    func testRequests_whenUsingTokenizationKey_sendsItInHeaders() async throws {
        let fakeTokenizationKey = try! TokenizationKey("development_testing_key")
        http = BTGraphQLHTTP(authorization: fakeTokenizationKey, customBaseURL: BTHTTPTestProtocol.testBaseURL())
        http?.session = fakeSession

        let (body, _) = try await http!.post("", parameters: nil)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.allHTTPHeaderFields!["Authorization"], "Bearer development_testing_key")
    }

    func testRequests_whenUsingAuthorizationFingerprint_sendsItInHeaders() async throws {
        http?.session = fakeSession
        let (body, _) = try await http!.post("", configuration: fakeConfiguration)
        let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body)
        XCTAssertEqual(httpRequest.allHTTPHeaderFields!["Authorization"], "Bearer test-authorization-fingerprint")
    }

    // MARK: - Error handling

    func testErrorResponse_whenErrorTypeIsUserError_containsExpectedError() async {
        let stubGraphQLErrorResponse: [String: Any?] = [
            "data": ["tokenizeCreditCard": nil] as [String: Any?],
            "errors": [
                [
                    "message": "Expiration month is invalid",
                    "path": ["tokenizeCreditCard"],
                    "locations": [["line": 1, "column": 66]],
                    "extensions": [
                        "errorType": "user_error",
                        "legacyCode": "81712",
                        "inputPath": ["input", "creditCard", "expirationMonth"]
                    ] as [String: Any]
                ] as [String: Any],
                [
                    "message": "Expiration year is invalid",
                    "path": ["tokenizeCreditCard"],
                    "locations": [["line": 1, "column": 66]],
                    "extensions": [
                        "errorType": "user_error",
                        "legacyCode": "81713",
                        "inputPath": ["input", "creditCard", "expirationYear"]
                    ] as [String: Any]
                ],
                [
                    "message": "CVV verification failed",
                    "path": ["tokenizeCreditCard"],
                    "locations": [["line": 1, "column": 66]],
                    "extensions": [
                        "errorType": "user_error",
                        "legacyCode": "81736",
                        "inputPath": ["input", "creditCard", "cvv"]
                    ] as [String: Any]
                ],
                [
                    "message": "Street address verification failed",
                    "path": ["tokenizeCreditCard"],
                    "locations": [["line": 1, "column": 66]],
                    "extensions": [
                        "errorType": "user_error",
                        "legacyCode": "12345",
                        "inputPath": ["input", "creditCard", "billingAddress", "streetAddress"]
                    ] as [String: Any]
                ]
            ],
            "extensions": ["requestId": "de1f7c67-4861-455f-89bb-1d208915f270"]
        ]

        let expectedErrorBody: [String: Any] = [
            "error": ["message": "Input is invalid"],
            "fieldErrors": [
                [
                    "field": "creditCard",
                    "fieldErrors": [
                        ["field": "expirationMonth", "code": "81712", "message": "Expiration month is invalid"],
                        ["field": "expirationYear", "code": "81713", "message": "Expiration year is invalid"],
                        ["field": "cvv", "code": "81736", "message": "CVV verification failed"] as [String: Any],
                        [
                            "field": "billingAddress",
                            "fieldErrors": [
                                ["field": "streetAddress", "code": "12345", "message": "Street address verification failed"]
                            ]
                        ]
                    ]
                ] as [String: Any]
            ]
        ]

        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.post("", configuration: fakeConfiguration)
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error.code, BTHTTPError.clientError([:]).errorCode)
            if let errorJSON = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON {
                XCTAssertEqual(errorJSON.asDictionary(), expectedErrorBody as NSDictionary)
            } else {
                XCTFail("Expected JSON response body in error userInfo")
            }
        }
    }

    func testErrorResponse_whenErrorTypeIsNotUserError_containsExpectedError() async {
        let stubGraphQLErrorResponse: [String: Any?] = [
            "data": ["tokenizeCard": nil] as [String: Any?],
            "errors": [
                [
                    "message": "Validation is not supported for requests authorized with a tokenization key.",
                    "locations": [["line": 2, "column": 9]],
                    "path": ["tokenizeCreditCard"],
                    "extensions": [
                        "errorType": "developer_error",
                        "legacyCode": "50000",
                        "inputPath": ["input", "options", "validate"]
                    ] as [String: Any]
                ] as [String: Any]
            ]
        ]

        let expectedErrorBody = [
            "error": ["message": "Validation is not supported for requests authorized with a tokenization key."]
        ]

        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.post("", configuration: fakeConfiguration)
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
            if let errorJSON = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON {
                XCTAssertEqual(errorJSON.asDictionary(), expectedErrorBody as NSDictionary)
            } else {
                XCTFail("Expected JSON response body in error userInfo")
            }
        }
    }

    func testErrorResponse_withNoErrorType_containsGenericMessage() async {
        let stubGraphQLErrorResponse: [String: Any] = [
            "data": NSNull(), "errors": [["message": "This is a bad error message"]]
        ]
        let expectedErrorBody = ["error": ["message": "An unexpected error occurred"]]

        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.post("", configuration: fakeConfiguration)
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            if let errorJSON = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON {
                XCTAssertEqual(errorJSON.asDictionary(), expectedErrorBody as NSDictionary)
            } else {
                XCTFail("Expected JSON response body in error userInfo")
            }
        }
    }

    func testErrorResponse_withGarbage_containsGenericMessage() async {
        let expectedErrorBody = ["error": ["message": "An unexpected error occurred"]]

        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: "something went wrong".data(using: .utf8)!,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.post("", configuration: fakeConfiguration)
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            if let errorJSON = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON {
                XCTAssertEqual(errorJSON.asDictionary(), expectedErrorBody as NSDictionary)
            } else {
                XCTFail("Expected JSON response body in error userInfo")
            }
        }
    }

    func testErrorResponse_correctlyMapsErrorTypeToStatusCode() async {
        let errorTypes = ["user_error": 422, "developer_error": 403, "unknown_error": 500]
        let errorCodes: [String: Int] = [
            "user_error": BTHTTPError.clientError([:]).errorCode,
            "developer_error": BTHTTPError.clientError([:]).errorCode,
            "unknown_error": BTHTTPError.serverError([:]).errorCode
        ]

        for (errorType, expectedStatusCode) in errorTypes {
            HTTPStubs.removeAllStubs()

            let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
                let body = ["errors": [["extensions": ["errorType": errorType]]]]
                return HTTPStubsResponse(
                    data: try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
            }
            defer { HTTPStubs.removeStub(stub) }

            let fakeClientToken = try! BTClientToken(clientToken: TestClientTokenFactory.stubbedURLClientToken)
            let testHttp = BTGraphQLHTTP(authorization: fakeClientToken)

            do {
                _ = try await testHttp.post("", configuration: fakeConfiguration)
                XCTFail("Expected error for errorType: \(errorType)")
            } catch let error as NSError {
                guard let urlResponse = error.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse else {
                    XCTFail("Expected urlResponseKey in error.userInfo for errorType: \(errorType)")
                    continue
                }
                XCTAssertEqual(urlResponse.statusCode, expectedStatusCode, "Mismatch for errorType: \(errorType)")
                XCTAssertEqual(error.domain, BTHTTPError.errorDomain)
                XCTAssertEqual(error.code, errorCodes[errorType])
            }
        }
    }

    func testErrorResponse_whenErrorIsMissingLegacyCode_doesNotSetCodeNumber() async {
        let stubGraphQLErrorResponse: [String: Any?] = [
            "data": ["tokenizeCreditCard": nil] as [String: Any?],
            "errors": [
                [
                    "message": "Expiration month is invalid",
                    "path": ["tokenizeCreditCard"],
                    "extensions": [
                        "errorType": "user_error",
                        "inputPath": ["input", "creditCard", "expirationMonth"]
                    ] as [String: Any]
                ] as [String: Any]
            ]
        ]

        let expectedErrorBody: [String: Any?] = [
            "error": ["message": "Input is invalid"],
            "fieldErrors": [
                [
                    "field": "creditCard",
                    "fieldErrors": [
                        ["field": "expirationMonth", "message": "Expiration month is invalid"]
                    ]
                ] as [String: Any]
            ]
        ]

        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.post("", configuration: fakeConfiguration)
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            if let errorJSON = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON {
                XCTAssertEqual(errorJSON.asDictionary(), expectedErrorBody as NSDictionary)
            } else {
                XCTFail("Expected JSON response body in error userInfo")
            }
        }
    }

    func testErrorResponse_withNoErrorTypeAndContainsExtension_sendsErrorMessage() async {
        let stubGraphQLErrorResponse: [String: Any?] = [
            "errors": [["message": "Error message that is helpful"]],
            "extensions": ["requestId": "a-fake-request-id"]
        ]
        let expectedErrorBody = ["error": ["message": "Error message that is helpful"]]

        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.post("", configuration: fakeConfiguration)
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            if let errorJSON = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON {
                XCTAssertEqual(errorJSON.asDictionary(), expectedErrorBody as NSDictionary)
            } else {
                XCTFail("Expected JSON response body in error userInfo")
            }
        }
    }

    func testNetworkError_returnsError() async {
        let stub = HTTPStubs.stubRequests { _ in true } withStubResponse: { _ in
            HTTPStubsResponse(error: NSError(domain: URLError.errorDomain, code: -1002, userInfo: [:]))
        }
        defer { HTTPStubs.removeStub(stub) }

        do {
            _ = try await http!.post("", configuration: fakeConfiguration)
            XCTFail("Expected error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, URLError.errorDomain)
            XCTAssertEqual(error.code, -1002)
        }
    }
}
