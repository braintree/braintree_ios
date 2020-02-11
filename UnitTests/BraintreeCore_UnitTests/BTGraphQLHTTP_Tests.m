#import "BTGraphQLHTTP.h"
#import "BTHTTPTestProtocol.h"
#import "BTSpecHelper.h"
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

@interface BTGraphQLHTTPTests : XCTestCase
@end

@implementation BTGraphQLHTTPTests {
    BTGraphQLHTTP *http;
}

- (void)setUp {
    [super setUp];

    http = [[BTGraphQLHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL] authorizationFingerprint:@"test-authorization-fingerprint"];
}

- (void)tearDown {
    [HTTPStubs removeAllStubs];
    [super tearDown];
}

- (NSURLSession *)fakeSession {
    NSURLSessionConfiguration *testConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [testConfiguration setProtocolClasses:@[[BTHTTPTestProtocol class]]];
    return [NSURLSession sessionWithConfiguration:testConfiguration];
}

#pragma mark - Basic request handling

- (void)testRequests_useTheHostAtTheBaseURL {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];
    http.session = [self fakeSession];

    [http POST:@"" completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];

        expect(httpRequest.URL.absoluteString).to.startWith(@"bt-http-test://base.example.com:1234/base/path");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testRequests_ignoreThePath {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];
    http.session = [self fakeSession];

    [http POST:@"hey/go/here.html" completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];

        XCTAssertEqualObjects(httpRequest.URL.absoluteString, @"bt-http-test://base.example.com:1234/base/path");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - Unsupported requests

- (void)testGETRequests_areUnsupported {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];

    @try {
        [http GET:@"" completion:^(__unused BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, __unused NSError * _Nullable error) {
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"GET is unsupported");
        [expectation fulfill];
    }

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPUTRequests_areUnsupported {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];

    @try {
        [http PUT:@"" completion:^(__unused BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, __unused NSError * _Nullable error) {
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"PUT is unsupported");
        [expectation fulfill];
    }

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testDELETERequests_areUnsupported {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];

    @try {
        [http DELETE:@"" completion:^(__unused BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, __unused NSError * _Nullable error) {
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"DELETE is unsupported");
        [expectation fulfill];
    }

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - POST requests

- (void)testPOSTRequests_sendsParametersInBody {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];
    http.session = [self fakeSession];

    [http POST:@"" parameters:@{@"hey": @"now"} completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
        NSData *bodyJSONData = [[BTHTTPTestProtocol parseRequestBodyFromTestResponseBody:body] dataUsingEncoding:NSUTF8StringEncoding];
        id bodyJSON = [NSJSONSerialization JSONObjectWithData:bodyJSONData options:0 error:NULL];

        XCTAssertEqualObjects(httpRequest.URL.absoluteString, @"bt-http-test://base.example.com:1234/base/path");
        XCTAssertEqualObjects(bodyJSON, @{@"hey": @"now"});
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPOSTRequests_whenSuccessful_returnsData {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];
    id stubResponseData = @{@"success": @YES};

    [HTTPStubs stubRequestsPassingTest:^BOOL(__unused NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(__unused NSURLRequest *request) {
        return [HTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:stubResponseData options:NSJSONWritingPrettyPrinted error:NULL] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
    }];

    [http POST:@"" parameters:@{@"hey": @"now"} completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        XCTAssertEqualObjects([body asDictionary], stubResponseData);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - Headers

- (void)testRequests_sendUserAgentHeader {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];
    http.session = [self fakeSession];

    [http POST:@"" parameters:nil completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
        NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
        expect(requestHeaders[@"User-Agent"]).to.match(@"^Braintree/iOS/\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testRequests_sendBraintreeVersionHeader {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];
    http.session = [self fakeSession];

    [http POST:@"" parameters:nil completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
        NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
        XCTAssertEqualObjects(requestHeaders[@"Braintree-Version"], @"2018-03-06");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testRequests_whenUsingTokenizationKey_sendsItInHeaders {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];

    http = [[BTGraphQLHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL] tokenizationKey:@"development_testing_key"];
    http.session = [self fakeSession];

    [http POST:@"" parameters:nil completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
        NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
        XCTAssertEqualObjects(requestHeaders[@"Authorization"], @"Bearer development_testing_key");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testRequests_whenUsingAuthorizationFingerprint_sendsItInHeaders {
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];
    http.session = [self fakeSession];

    [http POST:@"" parameters:nil completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
        NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
        XCTAssertEqualObjects(requestHeaders[@"Authorization"], @"Bearer test-authorization-fingerprint");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - Error handling

- (void)testErrorResponse_whenErrorTypeIsUserError_containsExpectedError {
    id stubGraphQLErrorResponse = @{
                                    @"data": @{@"tokenizeCreditCard": NSNull.null},
                                    @"errors": @[
                                            @{
                                                @"message": @"Expiration month is invalid",
                                                @"path": @[@"tokenizeCreditCard"],
                                                @"locations": @[
                                                        @{@"line": @(1), @"column": @(66)}
                                                        ],
                                                @"extensions": @{
                                                        @"errorType": @"user_error",
                                                        @"legacyCode": @"81712",
                                                        @"inputPath": @[@"input", @"creditCard", @"expirationMonth"]
                                                        }
                                                },
                                            @{
                                                @"message": @"Expiration year is invalid",
                                                @"path": @[@"tokenizeCreditCard"],
                                                @"locations": @[
                                                        @{@"line": @(1), @"column": @(66)}
                                                        ],
                                                @"extensions": @{
                                                        @"errorType": @"user_error",
                                                        @"legacyCode": @"81713",
                                                        @"inputPath": @[@"input", @"creditCard", @"expirationYear"]
                                                        }
                                                },
                                            @{
                                                @"message": @"CVV verification failed",
                                                @"path": @[@"tokenizeCreditCard"],
                                                @"locations": @[
                                                        @{@"line": @(1), @"column": @(66)}
                                                        ],
                                                @"extensions": @{
                                                        @"errorType": @"user_error",
                                                        @"legacyCode": @"81736",
                                                        @"inputPath": @[@"input", @"creditCard", @"cvv"]
                                                        }
                                                },
                                            @{
                                                @"message": @"Street address verification failed",
                                                @"path": @[@"tokenizeCreditCard"],
                                                @"locations": @[
                                                        @{@"line": @(1), @"column": @(66)}
                                                        ],
                                                @"extensions": @{
                                                        @"errorType": @"user_error",
                                                        @"legacyCode": @"12345",
                                                        @"inputPath": @[@"input", @"creditCard", @"billingAddress", @"streetAddress"]
                                                        }
                                                }
                                            ],
                                    @"extensions": @{@"requestId": @"de1f7c67-4861-455f-89bb-1d208915f270"}
                                    };
    id expectedErrorBody = @{
                                 @"error": @{@"message": @"Input is invalid"},
                                 @"fieldErrors": @[
                                         @{
                                             @"field": @"creditCard",
                                             @"fieldErrors": @[
                                                     @{
                                                         @"field": @"expirationMonth",
                                                         @"code": @"81712",
                                                         @"message": @"Expiration month is invalid"
                                                         },
                                                     @{
                                                         @"field": @"expirationYear",
                                                         @"code": @"81713",
                                                         @"message": @"Expiration year is invalid"
                                                         },
                                                     @{
                                                         @"field": @"cvv",
                                                         @"code": @"81736",
                                                         @"message": @"CVV verification failed"
                                                         },
                                                     @{
                                                         @"field": @"billingAddress",
                                                         @"fieldErrors": @[
                                                                 @{
                                                                     @"field": @"streetAddress",
                                                                     @"code": @"12345",
                                                                     @"message": @"Street address verification failed"
                                                                     }
                                                                 ]
                                                         }
                                                     ]
                                             }
                                         ]
                                 };

    [HTTPStubs stubRequestsPassingTest:^BOOL(__unused NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(__unused NSURLRequest *request) {
        return [HTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:stubGraphQLErrorResponse options:NSJSONWritingPrettyPrinted error:NULL] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
    }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];
    [http POST:@"" completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        XCTAssertEqualObjects(body.asDictionary, expectedErrorBody);
        XCTAssertEqualObjects([error.userInfo[BTHTTPJSONResponseBodyKey] asDictionary], expectedErrorBody);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testErrorResponse_whenErrorTypeIsNotUserError_containsExpectedError {
    id stubGraphQLErrorResponse = @{
                                    @"data": @{@"tokenizeCard": NSNull.null},
                                    @"errors": @[
                                            @{
                                                @"message": @"Validation is not supported for requests authorized with a tokenization key.",
                                                @"locations": @[
                                                              @{
                                                                  @"line": @(2),
                                                                  @"column": @(9)
                                                              }
                                                              ],
                                                @"path": @[
                                                         @"tokenizeCreditCard"
                                                         ],
                                                @"extensions": @{
                                                    @"errorType": @"developer_error",
                                                    @"legacyCode": @"50000",
                                                    @"inputPath": @[@"input", @"options", @"validate"]
                                                }
                                            }
                                            ]
                                    };
    id expectedErrorBody = @{
                             @"error": @{@"message": @"Validation is not supported for requests authorized with a tokenization key."}
                             };

    [HTTPStubs stubRequestsPassingTest:^BOOL(__unused NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(__unused NSURLRequest *request) {
        return [HTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:stubGraphQLErrorResponse options:NSJSONWritingPrettyPrinted error:NULL] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
    }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];
    [http POST:@"" completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        XCTAssertEqualObjects(body.asDictionary, expectedErrorBody);
        XCTAssertEqualObjects([error.userInfo[BTHTTPJSONResponseBodyKey] asDictionary], expectedErrorBody);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testErrorResponse_withNoErrorType_containsGenericMessage {
    id stubGraphQLErrorResponse = @{
                                    @"data": NSNull.null,
                                    @"errors": @[
                                            @{@"message": @"This is a bad error message"}
                                            ]
                                    };
    id expectedNestedErrorBody = @{
                                   @"error": @{@"message": @"An unexpected error occurred"}
                                   };

    [HTTPStubs stubRequestsPassingTest:^BOOL(__unused NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(__unused NSURLRequest *request) {
        return [HTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:stubGraphQLErrorResponse options:NSJSONWritingPrettyPrinted error:NULL] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
    }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];
    [http POST:@"" completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        XCTAssertEqualObjects(body.asDictionary, expectedNestedErrorBody);
        XCTAssertEqualObjects([error.userInfo[BTHTTPJSONResponseBodyKey] asDictionary], expectedNestedErrorBody);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testErrorResponse_withGarbage_containsGenericMessage {
    id stubGraphQLErrorResponse = @"something went wrong";
    id expectedErrorBody = @{
                             @"error": @{@"message": @"An unexpected error occurred"}
                             };

    [HTTPStubs stubRequestsPassingTest:^BOOL(__unused NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(__unused NSURLRequest *request) {
        return [HTTPStubsResponse responseWithData:[stubGraphQLErrorResponse dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type": @"text/plain; charset=UTF-8"}];
    }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];
    [http POST:@"" completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
        XCTAssertEqualObjects(body.asDictionary, expectedErrorBody);
        XCTAssertEqualObjects([error.userInfo[BTHTTPJSONResponseBodyKey] asDictionary], expectedErrorBody);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testErrorResponse_correctlyMapsErrorTypeToStatusCode {
    NSDictionary *errorTypes = @{
                                 @"user_error": @(422),
                                 @"developer_error": @(403),
                                 @"unknown_error": @(500)
                                 };
    NSDictionary <NSString *, NSNumber *> *errorCodes = @{
                                 @"user_error": @(BTHTTPErrorCodeClientError),
                                 @"developer_error": @(BTHTTPErrorCodeClientError),
                                 @"unknown_error": @(BTHTTPErrorCodeServerError)
                                 };

    for (NSString *errorType in errorTypes) {
        NSNumber *expectedStatusCode = errorTypes[errorType];
        id stubGraphQLErrorResponse = @{
                                        @"errors": @[
                                                @{
                                                    @"extensions": @{
                                                            @"errorType": errorType
                                                            }
                                                    }
                                                ]
                                        };


        id stub = [HTTPStubs stubRequestsPassingTest:^BOOL(__unused NSURLRequest *request) {
            return YES;
        } withStubResponse:^HTTPStubsResponse *(__unused NSURLRequest *request) {
            return [HTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:stubGraphQLErrorResponse options:NSJSONWritingPrettyPrinted error:NULL] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];

        XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];
        [http POST:@"" completion:^(__unused BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
            NSHTTPURLResponse *nestedResponse = error.userInfo[BTHTTPURLResponseKey];
            XCTAssertEqual(nestedResponse.statusCode, expectedStatusCode.longValue);

            XCTAssertEqualObjects(error.domain, BTHTTPErrorDomain);
            XCTAssertEqual(error.code, errorCodes[errorType].longValue);

            [HTTPStubs removeStub:stub];
            [expectation fulfill];
        }];

        [self waitForExpectationsWithTimeout:2 handler:nil];
    }
}

- (void)testNetworkError_returnsError {
    [HTTPStubs stubRequestsPassingTest:^BOOL(__unused NSURLRequest *request) {
        return YES;
    } withStubResponse:^HTTPStubsResponse *(__unused NSURLRequest *request) {
        return [HTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:-1002 userInfo:@{}]];
    }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"callback invoked"];
    [http POST:@"" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNil(body);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, -1002);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}


// TODO - add test for getRequestSslCertificateSuccessful, getRequestBadCertificateCheck for sandbox/prod in integration tests

@end
