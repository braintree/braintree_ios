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

    func testRequests_usesGraphQLURLFromConfig() {
        let expectation = expectation(description: "GET callback")
        http?.session = fakeSession

        http?.post("", configuration: fakeConfiguration) { body, _, _ in
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)

            XCTAssertTrue(httpRequest.url!.absoluteString.contains("bt-http-test://base.example.com:1234/base/path"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
    
    func testRequests_whenNilConfig_throwsError() {
        let expectation = expectation(description: "callback")
        http?.session = fakeSession

        http?.post("") { _, _, error in
            let error = error! as NSError
            XCTAssertEqual(error.domain, "com.braintreepayments.BTHTTPErrorDomain")
            XCTAssertEqual(error.code, 4)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testRequests_whenConfigMissingGraphQLURL_throwsError() {
        let json = BTJSON(value: [
            "clientApiUrl": "https://fake-client-api-url.com/path",
            "graphQL": [ ]
        ])
        let fakeConfiguration = BTConfiguration(json: json)
        
        let expectation = expectation(description: "callback")
        http?.session = fakeSession

        http?.post("", configuration: fakeConfiguration) { _, _, error in
            let error = error! as NSError
            XCTAssertEqual(error.domain, "com.braintreepayments.BTHTTPErrorDomain")
            XCTAssertEqual(error.code, 4)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testRequests_ignoreThePath() {
        let expectation = expectation(description: "GET callback")
        http?.session = fakeSession

        http?.post("hey/go/here.html", configuration: fakeConfiguration) { body, _, _ in
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)

            XCTAssertEqual(httpRequest.url!.absoluteString, "bt-http-test://base.example.com:1234/base/path")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Unsupported requests

    func testGETRequests_areUnsupported() {
        do {
            try BTExceptionCatcher.catchException {
                self.http?.get("") { _, _, _ in
                    // no-op
                }
            }
        } catch let error as NSError {
            XCTAssertEqual(error.userInfo["ExceptionReason"] as! String, "GET is unsupported")
        }
    }

    // MARK: - POST requests
    
    func testPOSTRequests_sendsParametersInBody() {
        let expectation = expectation(description: "POST callback")
        http?.session = fakeSession

        http?.post("", configuration: fakeConfiguration, parameters: ["hey": "now"]) { body, _, error in
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            let bodyJSONData = BTHTTPTestProtocol.parseRequestBodyFromTestResponseBody(body!).data(using: .utf8)

            let bodyJSON = try? JSONSerialization.jsonObject(with: bodyJSONData!) as? [String: String] ?? [:]

            XCTAssertEqual(httpRequest.url!.absoluteString, "bt-http-test://base.example.com:1234/base/path")
            XCTAssertEqual(bodyJSON, ["hey": "now"])
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testPOSTRequests_whenSuccessful_returnsData() {
        let expectation = expectation(description: "POST callback")
        let stubResponseData: [String: Any] = ["success": true]

        HTTPStubs.stubRequests { request in
            return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubResponseData, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.post("", configuration: fakeConfiguration, parameters: ["hey": "now"]) { body, _, _ in
            XCTAssertEqual(body?.asDictionary(), stubResponseData as NSDictionary)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Headers

    func testRequests_sendUserAgentHeader() {
        let expectation = expectation(description: "POST callback")
        http?.session = fakeSession

        http?.post("", configuration: fakeConfiguration, parameters: nil) { body, _, _ in
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            let requestHeaders = httpRequest.allHTTPHeaderFields
            XCTAssertTrue((requestHeaders!["User-Agent"])!.matches("^Braintree/iOS/\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$"))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testRequests_sendBraintreeVersionHeader() {
        let expectation = expectation(description: "POST callback")
        http?.session = fakeSession

        http?.post("", configuration: fakeConfiguration, parameters: nil) { body, _, _ in
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            let requestHeaders = httpRequest.allHTTPHeaderFields
            XCTAssertEqual(requestHeaders!["Braintree-Version"], "2018-03-06")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testRequests_whenUsingTokenizationKey_sendsItInHeaders() {
        let expectation = expectation(description: "POST callback")
        let fakeTokenizationKey = try! TokenizationKey("development_testing_key")
        http = BTGraphQLHTTP(authorization: fakeTokenizationKey, customBaseURL: BTHTTPTestProtocol.testBaseURL())
        http?.session = fakeSession

        http?.post("", parameters: nil) { body, _, _ in
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            let requestHeaders = httpRequest.allHTTPHeaderFields
            XCTAssertEqual(requestHeaders!["Authorization"], "Bearer development_testing_key")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testRequests_whenUsingAuthorizationFingerprint_sendsItInHeaders() {
        let expectation = expectation(description: "POST callback")
        http?.session = fakeSession

        http?.post("", configuration: fakeConfiguration, parameters: nil) { body, _, _ in
            let httpRequest = BTHTTPTestProtocol.parseRequestFromTestResponseBody(body!)
            let requestHeaders = httpRequest.allHTTPHeaderFields
            XCTAssertEqual(requestHeaders!["Authorization"], "Bearer test-authorization-fingerprint")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Error handling

    func testErrorResponse_whenErrorTypeIsUserError_containsExpectedError() {
        let expectation = expectation(description: "POST callback")
        let stubGraphQLErrorResponse: [String: Any?] = [
            "data": ["tokenizeCreditCard": nil] as [String: Any?],
            "errors": [
                [
                    "message": "Expiration month is invalid",
                    "path": ["tokenizeCreditCard"],
                    "locations": [
                        ["line": 1, "column": 66]
                    ],
                    "extensions": [
                        "errorType": "user_error",
                        "legacyCode": "81712",
                        "inputPath": ["input", "creditCard", "expirationMonth"]
                    ] as [String: Any]
                ] as [String: Any],
                [
                    "message": "Expiration year is invalid",
                    "path": ["tokenizeCreditCard"],
                    "locations": [
                        ["line": 1, "column": 66]
                    ],
                    "extensions": [
                        "errorType": "user_error",
                        "legacyCode": "81713",
                        "inputPath": ["input", "creditCard", "expirationYear"]
                    ] as [String: Any]
                ],
                [
                    "message": "CVV verification failed",
                    "path": ["tokenizeCreditCard"],
                    "locations": [
                        ["line": 1, "column": 66]
                    ],
                    "extensions": [
                        "errorType": "user_error",
                        "legacyCode": "81736",
                        "inputPath": ["input", "creditCard", "cvv"]
                    ] as [String: Any]
                ],
                [
                    "message": "Street address verification failed",
                    "path": ["tokenizeCreditCard"],
                    "locations": [
                        ["line": 1, "column": 66]
                    ],
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
                        [
                            "field": "expirationMonth",
                            "code": "81712",
                            "message": "Expiration month is invalid"
                        ],
                        [
                            "field": "expirationYear",
                            "code": "81713",
                            "message": "Expiration year is invalid"
                        ],
                        [
                            "field": "cvv",
                            "code": "81736",
                            "message": "CVV verification failed"
                        ] as [String: Any],
                        [
                            "field": "billingAddress",
                            "fieldErrors": [
                                [
                                    "field": "streetAddress",
                                    "code": "12345",
                                    "message": "Street address verification failed"
                                ]
                            ]
                        ]
                    ]
                ] as [String: Any]
            ]
        ]

        HTTPStubs.stubRequests { request in
          return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.post("", configuration: fakeConfiguration) { body, _, error in
            XCTAssertEqual(body?.asDictionary(), expectedErrorBody as NSDictionary)

            let error = error as NSError?
            let errorDictionary = error?.userInfo[BTCoreConstants.jsonResponseBodyKey] as AnyObject
            XCTAssertEqual(errorDictionary.asDictionary(), expectedErrorBody as NSDictionary)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testErrorResponse_whenErrorTypeIsNotUserError_containsExpectedError() {
        let expectation = expectation(description: "POST callback")
        let stubGraphQLErrorResponse: [String: Any?] = [
            "data": ["tokenizeCard": nil] as [String: Any?],
            "errors": [
                [
                    "message": "Validation is not supported for requests authorized with a tokenization key.",
                    "locations": [
                        ["line": 2, "column": 9]
                    ],
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

        HTTPStubs.stubRequests { request in
          return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.post("", configuration: fakeConfiguration) { body, _, error in
            XCTAssertEqual(body?.asDictionary(), expectedErrorBody as NSDictionary)

            let error = error as NSError?
            let errorDictionary = error?.userInfo[BTCoreConstants.jsonResponseBodyKey] as AnyObject
            XCTAssertEqual(errorDictionary.asDictionary(), expectedErrorBody as NSDictionary)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testErrorResponse_withNoErrorType_containsGenericMessage() {
        let expectation = expectation(description: "POST callback")
        let stubGraphQLErrorResponse: [String: Any] = [
            "data": NSNull(), "errors": [["message": "This is a bad error message"]]
        ]

        let expectedErrorBody = ["error": ["message": "An unexpected error occurred"]]

        HTTPStubs.stubRequests { request in
          return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.post("", configuration: fakeConfiguration) { body, _, error in
            XCTAssertEqual(body?.asDictionary(), expectedErrorBody as NSDictionary)

            let error = error as NSError?
            let errorDictionary = error?.userInfo[BTCoreConstants.jsonResponseBodyKey] as AnyObject
            XCTAssertEqual(errorDictionary.asDictionary(), expectedErrorBody as NSDictionary)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testErrorResponse_withGarbage_containsGenericMessage() {
        let expectation = expectation(description: "POST callback")
        let stubGraphQLErrorResponse = "something went wrong"

        let expectedErrorBody = ["error": ["message": "An unexpected error occurred"]]

        HTTPStubs.stubRequests { request in
          return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: stubGraphQLErrorResponse.data(using: .utf8)!,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.post("", configuration: fakeConfiguration) { body, _, error in
            XCTAssertEqual(body?.asDictionary(), expectedErrorBody as NSDictionary)

            let error = error as NSError?
            let errorDictionary = error?.userInfo[BTCoreConstants.jsonResponseBodyKey] as AnyObject
            XCTAssertEqual(errorDictionary.asDictionary(), expectedErrorBody as NSDictionary)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testErrorResponse_correctlyMapsErrorTypeToStatusCode() {
        let errorTypes = ["user_error": 422, "developer_error": 403, "unknown_error": 500]
        let errorCodes: [String: Int] = [
            "user_error": BTHTTPError.clientError([:]).errorCode,
            "developer_error": BTHTTPError.clientError([:]).errorCode,
            "unknown_error": BTHTTPError.serverError([:]).errorCode
        ]

        for (errorType, _) in errorTypes {
            let expectedStatusCode = errorTypes[errorType]
            let stubGraphQLErrorResponse = [
                "errors": [
                    [
                        "extensions": ["errorType": errorType]
                    ]
                ]
            ]

            HTTPStubs.stubRequests { request in
              return true
            } withStubResponse: { request in
                return HTTPStubsResponse(
                    data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
            }

            let expectation = expectation(description: "POST callback")
            http?.post("", configuration: fakeConfiguration) { body, _, error in
                let error = error as NSError?
                let errorDictionary = error!.userInfo[BTCoreConstants.urlResponseKey] as! HTTPURLResponse
                XCTAssertEqual(errorDictionary.statusCode, expectedStatusCode)
                XCTAssertEqual(error?.domain, BTHTTPError.errorDomain)
                XCTAssertEqual(error?.code, errorCodes[errorType])

                expectation.fulfill()
            }

            waitForExpectations(timeout: 2)
        }
    }

    func testErrorResponse_whenErrorIsMissingLegacyCode_doesNotSetCodeNumber() {
        let expectation = expectation(description: "POST callback")
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
            ],
        ]

        let expectedErrorBody: [String: Any?] = [
            "error": ["message": "Input is invalid"],
            "fieldErrors": [
                [
                    "field": "creditCard",
                    "fieldErrors": [
                        [
                            "field": "expirationMonth",
                            "message": "Expiration month is invalid"
                        ]
                    ]
                ] as [String: Any]
            ]
        ]

        HTTPStubs.stubRequests { request in
          return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.post("", configuration: fakeConfiguration) { body, _, error in
            XCTAssertEqual(body?.asDictionary(), expectedErrorBody as NSDictionary)

            let error = error as NSError?
            let errorDictionary = error?.userInfo[BTCoreConstants.jsonResponseBodyKey] as AnyObject
            XCTAssertEqual(errorDictionary.asDictionary(), expectedErrorBody as NSDictionary)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testErrorResponse_withNoErrorTypeAndContainsExtension_sendsErrorMessage() {
        let expectation = expectation(description: "POST callback")
        let stubGraphQLErrorResponse: [String: Any?] = [
            "errors": [["message": "Error message that is helpful"]],
            "extensions": ["requestId": "a-fake-request-id"]
        ]

        let expectedErrorBody = ["error": ["message": "Error message that is helpful"]]

        HTTPStubs.stubRequests { request in
          return true
        } withStubResponse: { request in
            return HTTPStubsResponse(
                data: try! JSONSerialization.data(withJSONObject: stubGraphQLErrorResponse, options: .prettyPrinted),
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            )
        }

        http?.post("", configuration: fakeConfiguration) { body, _, error in
            XCTAssertEqual(body?.asDictionary(), expectedErrorBody as NSDictionary)

            let error = error as NSError?
            let errorDictionary = error?.userInfo[BTCoreConstants.jsonResponseBodyKey] as AnyObject
            XCTAssertEqual(errorDictionary.asDictionary(), expectedErrorBody as NSDictionary)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testNetworkError_returnsError() {
        let expectation = expectation(description: "POST callback")

        HTTPStubs.stubRequests { request in
          return true
        } withStubResponse: { request in
            return HTTPStubsResponse(error: NSError(domain: URLError.errorDomain, code: -1002, userInfo: [:]))
        }

        http?.post("", configuration: fakeConfiguration) { body, response, error in
            XCTAssertNil(body)
            XCTAssertNil(response)

            let error = error as NSError?
            XCTAssertEqual(error?.domain, URLError.errorDomain)
            XCTAssertEqual(error?.code, -1002)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testHttpError_withEmptyDataAndNoError_returnsError() {
        http?.handleRequestCompletion(data: nil, response: nil, error: nil) { _, _, error in
            let error = error as NSError?
            XCTAssertEqual(error?.localizedDescription, "Unable to create HTTPURLResponse from response data.")
            XCTAssertEqual(error?.domain, BTHTTPError.errorDomain)
            XCTAssertEqual(error?.code, BTHTTPError.httpResponseInvalid.errorCode)
        }
    }
}
