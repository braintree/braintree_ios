#import "BTHTTP.h"
#import "BTSpecHelper.h"

#define kBTHTTPTestProtocolScheme @"bt-http-test"
#define kBTHTTPTestProtocolHost @"base.example.com"
#define kBTHTTPTestProtocolBasePath @"/base/path"
#define kBTHTTPTestProtocolPort @1234

@interface BTHTTPTestProtocol : NSURLProtocol
@end

@implementation BTHTTPTestProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {

    BOOL hasCorrectScheme = [request.URL.scheme isEqualToString:kBTHTTPTestProtocolScheme];
    BOOL hasCorrectHost = [request.URL.host isEqualToString:kBTHTTPTestProtocolHost];
    BOOL hasCorrectPort = [request.URL.port isEqual:kBTHTTPTestProtocolPort];
    BOOL hasCorrectBasePath = [request.URL.path rangeOfString:kBTHTTPTestProtocolBasePath].location != NSNotFound;

    return hasCorrectScheme && hasCorrectHost && hasCorrectPort && hasCorrectBasePath;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    id<NSURLProtocolClient> client = self.client;

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{@"Content-Type": @"application/json"}];

    NSData *archivedRequest = [NSKeyedArchiver archivedDataWithRootObject:self.request];
    NSString *base64ArchivedRequest = [archivedRequest base64EncodedStringWithOptions:0];

    NSData *requestBodyData;
    if (self.request.HTTPBodyStream) {
        NSInputStream *inputStream = self.request.HTTPBodyStream;
        [inputStream open];
        NSMutableData *mutableBodyData = [NSMutableData data];

        while ([inputStream hasBytesAvailable]) {
            uint8_t buffer[128];
            NSUInteger bytesRead = [inputStream read:buffer maxLength:128];
            [mutableBodyData appendBytes:buffer length:bytesRead];
        }
        [inputStream close];
        requestBodyData = [mutableBodyData copy];
    } else {
        requestBodyData = self.request.HTTPBody;
    }

    NSDictionary *responseBody = @{ @"request": base64ArchivedRequest,
                                    @"requestBody": [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding] };

    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    [client URLProtocol:self didLoadData:[NSJSONSerialization dataWithJSONObject:responseBody options:NSJSONWritingPrettyPrinted error:NULL]];

    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

+ (NSURL *)testBaseURL {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = kBTHTTPTestProtocolScheme;
    components.host = kBTHTTPTestProtocolHost;
    components.path = kBTHTTPTestProtocolBasePath;
    components.port = kBTHTTPTestProtocolPort;
    return components.URL;
}

+ (NSURLRequest *)parseRequestFromTestResponseBody:(BTJSON *)responseBody {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithBase64EncodedString:responseBody[@"request"].asString options:0]];
}

+ (NSString *)parseRequestBodyFromTestResponseBody:(BTJSON *)responseBody {
    return responseBody[@"requestBody"].asString;
}

@end

NSURL *validDataURL() {
    NSDictionary *validObject = @{@"clientId":@"a-client-id", @"nest": @{@"nested":@"nested-value"}};
    NSError *jsonSerializationError;
    NSData *configurationData = [NSJSONSerialization dataWithJSONObject:validObject
                                                                options:0
                                                                  error:&jsonSerializationError];
    NSString *base64EncodedConfigurationData = [configurationData base64EncodedStringWithOptions:0];
    NSString *dataURLString = [NSString stringWithFormat:@"data:application/json;base64,%@", base64EncodedConfigurationData];
    return [NSURL URLWithString:dataURLString];
}

NSDictionary *parameterDictionary() {
    return @{@"stringParameter": @"value",
             @"crazyStringParameter[]": @"crazy%20and&value",
             @"numericParameter": @42,
             @"trueBooleanParameter": @YES,
             @"falseBooleanParameter": @NO,
             @"dictionaryParameter":  @{ @"dictionaryKey": @"dictionaryValue" },
             @"arrayParameter": @[@"arrayItem1", @"arrayItem2"]
             };
}

void withStub(void (^block)(void (^removeStub)(void))) {
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData *jsonResponse = [NSJSONSerialization dataWithJSONObject:@{@"requestHeaders": [request allHTTPHeaderFields]} options:NSJSONWritingPrettyPrinted error:nil];
        return [OHHTTPStubsResponse responseWithData:jsonResponse statusCode:200 headers:@{@"Content-Type": @"application/json"}];
    }];

    block(^{
        [OHHTTPStubs removeStub:stub];
    });
}

@interface BTHTTPSpec : XCTestCase
@end

@implementation BTHTTPSpec {
    BTHTTP *http;
    id<OHHTTPStubsDescriptor> stubDescriptor;
}

#pragma mark - performing a request

- (void)setUp {
    [super setUp];

    http = [[BTHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL] authorizationFingerprint:@"test-authorization-fingerprint"];
    NSURLSessionConfiguration *testConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [testConfiguration setProtocolClasses:@[[BTHTTPTestProtocol class]]];
    http.session = [NSURLSession sessionWithConfiguration:testConfiguration];

}

#pragma mark - base URL

- (void)test_sends_requests_using_the_specified_URL_scheme {
    waitUntil(^(DoneCallback done){
        [http GET:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];

            expect(httpRequest.URL.scheme).to.equal(@"bt-http-test");
            done();
        }];
    });
}

- (void)test_sends_requests_to_the_host_at_the_base_URL {
    ({
        waitUntil(^(DoneCallback done){
            [http GET:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
                expect(httpRequest.URL.host).to.equal(@"base.example.com");

                done();
            }];
        });
    });
}

- (void)test_appends_the_path_to_the_base_URL {
    ({
        waitUntil(^(DoneCallback done){
            [http GET:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];

                expect(httpRequest.URL.path).to.equal(@"/base/path/200.json");
                done();
            }];
        });
    });
}

- (void)test_hits_the_base_URL_if_the_path_is_nil {
    ({
        waitUntil(^(DoneCallback done){
            [http GET:nil completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];

                expect(httpRequest.URL.path).to.equal(@"/base/path");
                done();
            }];
        });
    });

    pending(@"returns a json serialization error if the parameters cannot be serialized");
    pending(@"appends the authorization fingerprint to all requests");
}

#pragma mark - data base URLs

- (void)test_returns_the_data {
    waitUntil(^(DoneCallback done) {
        http = [[BTHTTP alloc] initWithBaseURL:validDataURL() authorizationFingerprint:@"test-authorization-fingerprint"];

        [http GET:nil completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            expect(body[@"clientId"].asString).to.equal(@"a-client-id");
            expect(body[@"nest"][@"nested"].asString).to.equal(@"nested-value");
            done();
        }];
    });
}

- (void)test_ignores_POST_data {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform request"];

    http = [[BTHTTP alloc] initWithBaseURL:validDataURL() authorizationFingerprint:@"test-authorization-fingerprint"];

    [http POST:nil parameters:@{@"a-post-param":@"POST"} completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        expect(response.statusCode).to.equal(200);
        expect(error).to.beNil();
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)test_ignores_GET_parameters {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform request"];

    http = [[BTHTTP alloc] initWithBaseURL:validDataURL() authorizationFingerprint:@"test-authorization-fingerprint"];

    [http GET:nil parameters:@{@"a-get-param":@"GET"} completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        expect(response.statusCode).to.equal(200);
        expect(error).to.beNil();
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}
- (void)test_ignores_the_specified_path {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform request"];

    http = [[BTHTTP alloc] initWithBaseURL:validDataURL() authorizationFingerprint:@"test-authorization-fingerprint"];

    [http GET:@"/resource" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        expect(response.statusCode).to.equal(200);
        expect(error).to.beNil();
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)test_sets_the_Content_Type_header {
    NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;base64,SGVsbG8sIFdvcmxkIQo="];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform request"];

    http = [[BTHTTP alloc] initWithBaseURL:dataURL authorizationFingerprint:@"test-authorization-fingerprint"];

    [http GET:nil completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        expect(error.domain).to.equal(BTHTTPErrorDomain);
        expect(error.code).to.equal(BTHTTPErrorCodeResponseContentTypeNotAcceptable);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)test_sets_the_response_status_code {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform request"];

    http = [[BTHTTP alloc] initWithBaseURL:validDataURL() authorizationFingerprint:@"test-authorization-fingerprint"];

    [http GET:nil completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        expect(response.statusCode).notTo.beNil();
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)test_fails_like_an_HTTP_500_when_the_base64_encoded_data_is_invalid {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Perform request"];

    NSString *dataURLString = [NSString stringWithFormat:@"data:application/json;base64,%@", @"BAD-BASE-64-STRING"];

    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:dataURLString] authorizationFingerprint:@"test-authorization-fingerprint"];
    [http GET:nil completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        expect(response).to.beNil();
        expect(error).notTo.beNil();
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

#pragma mark - HTTP methods

- (void)test_sends_a_GET_request {
    waitUntil(^(DoneCallback done){
        [http GET:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error){
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
            expect(httpRequest.URL.path).to.match(@"/200.json$");
            expect(httpRequest.HTTPMethod).to.equal(@"GET");
            expect(httpRequest.HTTPBody).to.beNil();
            done();
        }];
    });
}

- (void)test_sends_a_GET_request_with_parameters {
    waitUntil(^(DoneCallback done){
        [http GET:@"200.json" parameters:@{@"param": @"value"} completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error){
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
            expect(httpRequest.URL.path).to.match(@"/200.json$");
            expect(httpRequest.URL.query).to.equal(@"param=value");
            expect(httpRequest.HTTPMethod).to.equal(@"GET");
            expect(httpRequest.HTTPBody).to.beNil();
            done();
        }];
    });
}

- (void)test_sends_a_POST_request {
    waitUntil(^(DoneCallback done){
        [http POST:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
            expect(httpRequest.URL.path).to.match(@"/200.json$");
            expect(httpRequest.HTTPBody).to.beNil();
            expect(httpRequest.HTTPMethod).to.equal(@"POST");
            expect(httpRequest.URL.query).to.beNil();
            done();
        }];
    });
}

- (void)test_sends_a_POST_request_with_parameters {
    waitUntil(^(DoneCallback done){
        [http POST:@"200.json" parameters:@{@"param": @"value"} completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
            NSString *httpRequestBody = [BTHTTPTestProtocol parseRequestBodyFromTestResponseBody:body];
            expect(httpRequest.URL.path).to.match(@"/200.json$");
            expect(httpRequestBody).to.equal(@"{\n  \"param\" : \"value\"\n}");
            expect(httpRequest.HTTPMethod).to.equal(@"POST");
            expect(httpRequest.URL.query).to.beNil();
            done();
        }];
    });
}

- (void)test_sends_a_PUT_request {
    waitUntil(^(DoneCallback done){
        [http PUT:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
            expect(httpRequest.URL.path).to.match(@"200.json$");
            expect(httpRequest.HTTPBody).to.beNil();
            expect(httpRequest.HTTPMethod).to.equal(@"PUT");
            expect(httpRequest.URL.query).to.beNil();
            done();
        }];
    });
}

- (void)test_sends_a_PUT_request_with_parameters {
    waitUntil(^(DoneCallback done){
        [http PUT:@"200.json" parameters:@{@"param": @"value"} completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
            NSString *httpRequestBody = [BTHTTPTestProtocol parseRequestBodyFromTestResponseBody:body];
            expect(httpRequest.URL.path).to.match(@"200.json$");
            expect(httpRequestBody).to.equal(@"{\n  \"param\" : \"value\"\n}");
            expect(httpRequest.HTTPMethod).to.equal(@"PUT");
            expect(httpRequest.URL.query).to.beNil();
            done();
        }];
    });
}


- (void)test_sends_a_DELETE_request {
    waitUntil(^(DoneCallback done){
        [http DELETE:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
            expect(httpRequest.URL.path).to.match(@"200.json$");
            expect(httpRequest.HTTPBody).to.beNil();
            expect(httpRequest.HTTPMethod).to.equal(@"DELETE");
            expect(httpRequest.URL.query).to.equal(@"");
            done();
        }];
    });
}

- (void)test_sends_a_DELETE_request_with_parameters {
    waitUntil(^(DoneCallback done){
        [http DELETE:@"200.json" parameters:@{@"param": @"value"} completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error){
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];

            expect(httpRequest.URL.path).to.match(@"/200.json$");
            expect(httpRequest.URL.query).to.equal(@"param=value");
            expect(httpRequest.HTTPMethod).to.equal(@"DELETE");
            expect(httpRequest.HTTPBody).to.beNil();
            done();
        }];
    });
}

#pragma mark default headers

- (void)test_include_Accept {
    waitUntil(^(DoneCallback done){
        withStub(^(void (^removeStub)(void)){
            [http GET:@"stub://200/resource" parameters:nil completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
                NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                expect(requestHeaders[@"Accept"]).to.equal(@"application/json");
                removeStub();
                done();
            }];
        });
    });
}

- (void)test_include_User_Agent {
    waitUntil(^(DoneCallback done){
        withStub(^(void (^removeStub)(void)){
            [http GET:@"stub://200/resource" parameters:nil completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
                NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                expect(requestHeaders[@"User-Agent"]).to.match(@"^Braintree/iOS/\\d+\\.\\d+\\.\\d+(-[0-9a-zA-Z-]+)?$");
                removeStub();
                done();
            }];
        });
    });
}

- (void)test_include_Accept_Language {
    waitUntil(^(DoneCallback done){
        withStub(^(void (^removeStub)(void)){
            [http GET:@"stub://200/resource" parameters:nil completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
                NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                expect(requestHeaders[@"Accept-Language"]).to.equal(@"en-US");
                removeStub();
                done();
            }];
        });
    });
}


#pragma mark parameters

#pragma mark in GET requests
- (void)test_transmits_the_parameters_as_URL_encoded_query_parameters {
    waitUntil(^(DoneCallback done){
        NSArray *expectedQueryParameters = @[ @"numericParameter=42",
                                              @"falseBooleanParameter=0",
                                              @"dictionaryParameter%5BdictionaryKey%5D=dictionaryValue",
                                              @"trueBooleanParameter=1",
                                              @"stringParameter=value",
                                              @"crazyStringParameter%5B%5D=crazy%2520and%26value",
                                              @"arrayParameter%5B%5D=arrayItem1",
                                              @"arrayParameter%5B%5D=arrayItem2" ];

        [http GET:@"200.json" parameters:parameterDictionary() completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
            NSArray *actualQueryComponents = [httpRequest.URL.query componentsSeparatedByString:@"&"];

            for(NSString *expectedComponent in expectedQueryParameters){
                expect(actualQueryComponents).to.contain(expectedComponent);
            }

            done();
        }];
    });
}

#pragma mark in non-GET requests

- (void)test_transmits_the_parameters_as_JSON {
    waitUntil(^(DoneCallback done){
        NSDictionary *expectedParameters = @{ @"numericParameter": @42,
                                              @"falseBooleanParameter": @NO,
                                              @"dictionaryParameter": @{
                                                      @"dictionaryKey": @"dictionaryValue"
                                                      },
                                              @"trueBooleanParameter": @YES,
                                              @"stringParameter": @"value",
                                              @"crazyStringParameter[]": @"crazy%20and&value", @"arrayParameter": @[ @"arrayItem1", @"arrayItem2" ] };

        [http POST:@"200.json" parameters:parameterDictionary() completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
            NSString *httpRequestBody = [BTHTTPTestProtocol parseRequestBodyFromTestResponseBody:body];

            expect([httpRequest valueForHTTPHeaderField:@"Content-type"]).to.equal(@"application/json; charset=utf-8");
            NSDictionary *actualParameters = [NSJSONSerialization JSONObjectWithData:[httpRequestBody dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options:0
                                                                               error:NULL];
            expect(actualParameters).to.equal(expectedParameters);
            done();
        }];
    });
}

#pragma mark interpreting responses

- (void)testCallsBackOnMainQueue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"receive callback"];
    [http GET:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        expect(dispatch_get_current_queue()).to.equal(dispatch_get_main_queue());
#pragma clang diagnostic pop
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCallsBackOnSpecifiedQueue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"receive callback"];
    http.dispatchQueue = dispatch_queue_create("com.braintreepayments.BTHTTPSpec.callbackQueueTest", DISPATCH_QUEUE_SERIAL);
    [http GET:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        expect(dispatch_get_current_queue()).to.equal(http.dispatchQueue);
#pragma clang diagnostic pop
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

#pragma mark response code parser

- (void)test_interprets_2xx_as_a_completion_with_success {
    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"] authorizationFingerprint:@"test-authorization-fingerprint"];

    waitUntil(^(DoneCallback done){
        id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{} options:NSJSONWritingPrettyPrinted error:NULL] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];

        [http GET:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            expect(response.statusCode).to.equal(200);

            expect(error).to.beNil();

            [OHHTTPStubs removeStub:stub];
            done();
        }];
    });
}

- (void)test_interprets_403_as_an_HTTP_success {
    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"] authorizationFingerprint:@"test-authorization-fingerprint"];

    waitUntil(^(DoneCallback done){
        id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{} options:NSJSONWritingPrettyPrinted error:NULL] statusCode:403 headers:@{@"Content-Type": @"application/json"}];
        }];

        [http GET:@"403.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            expect(body).notTo.beNil();
            expect(response.statusCode).to.equal(403);
            expect(error).to.beNil();

            [OHHTTPStubs removeStub:stub];
            done();
        }];
    });
}

- (void)test_interprets_the_network_being_down_as_an_error {
    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"] authorizationFingerprint:@"test-authorization-fingerprint"];

    waitUntil(^(DoneCallback done){
        id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil]];
        }];

        [http GET:@"network-down" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            expect(body).to.beNil();
            expect(response).to.beNil();
            expect(error.domain).to.equal(NSURLErrorDomain);
            expect(error.code).to.equal(NSURLErrorNotConnectedToInternet);
            [OHHTTPStubs removeStub:stub];
            done();
        }];
    });
}

- (void)test_interprets_the_server_being_unavailable_as_an_error {
    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"] authorizationFingerprint:@"test-authorization-fingerprint"];

    waitUntil(^(DoneCallback done){
        id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
        }];


        [http GET:@"gateway-down" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            expect(body).to.beNil();
            expect(response).to.beNil();
            expect(error.domain).to.equal(NSURLErrorDomain);
            expect(error.code).to.equal(NSURLErrorCannotConnectToHost);
            [OHHTTPStubs removeStub:stub];
            done();
        }];
    });
}

#pragma mark response body parser

- (void)test_parses_a_JSON_response_body {
    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"] authorizationFingerprint:@"test-authorization-fingerprint"];

    waitUntil(^(DoneCallback done){
        id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:[@"{\"status\": \"OK\"}" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];

        [http GET:@"200.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error){
            expect(body[@"status"].asString).to.equal(@"OK");

            [OHHTTPStubs removeStub:stub];
            done();
        }];
    });
}

- (void)test_accepts_empty_responses {
    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"] authorizationFingerprint:@"test-authorization-fingerprint"];

    waitUntil(^(DoneCallback done){
        id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:nil statusCode:200 headers:nil];
        }];

        [http GET:@"empty.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error){
            expect(response.statusCode).to.equal(200);
            expect(body).to.beKindOf([BTJSON class]);
            expect(body.isObject).to.beTruthy();
            expect(error).to.beNil();

            [OHHTTPStubs removeStub:stub];
            done();
        }];
    });
}

- (void)test_interprets_invalid_JSON_responses_as_a_server_error {
    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"] authorizationFingerprint:@"test-authorization-fingerprint"];

    waitUntil(^(DoneCallback done){
        id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:[@"{ really invalid json ]" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];

        [http GET:@"invalid.json" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            expect(response).to.beNil();
            expect(body).to.beNil();
            expect(error.domain).to.equal(NSCocoaErrorDomain);

            [OHHTTPStubs removeStub:stub];
            done();
        }];
    });
}

- (void)test_interprets_valid_but_non_JSON_responses_as_a_server_error {
    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"] authorizationFingerprint:@"test-authorization-fingerprint"];

    waitUntil(^(DoneCallback done){
        id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            return [OHHTTPStubsResponse responseWithData:[@"<html>response</html>" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type": @"text/html"}];
        }];

        [http GET:@"200.html" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
            expect(response).to.beNil();

            expect(error.domain).to.equal(BTHTTPErrorDomain);
            expect(error.code).to.equal(BTHTTPErrorCodeResponseContentTypeNotAcceptable);

            [OHHTTPStubs removeStub:stub];
            done();
        }];
    });
}

- (void)test_noops_for_a_nil_completion_block {
    http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"] authorizationFingerprint:@"test-authorization-fingerprint"];

    waitUntil(^(DoneCallback done){
        setAsyncSpecTimeout(2);

        [http GET:@"200.json" parameters:nil completion:nil];

        wait_for_potential_async_exceptions(done);
    });
}

#pragma mark isEqual:

- (void)test_returns_YES_if_BTHTTPs_have_the_same_baseURL_and_authorizationFingerprint {
    NSURL *baseURL = [NSURL URLWithString:@"an-url://hi"];
    BTHTTP *http1  = [[BTHTTP alloc] initWithBaseURL:baseURL authorizationFingerprint:@"test-authorization-fingerprint"];
    BTHTTP *http2  = [[BTHTTP alloc] initWithBaseURL:baseURL authorizationFingerprint:@"test-authorization-fingerprint"];

    expect(http1).to.equal(http2);
}

- (void)test_returns_NO_if_BTHTTPs_do_not_have_the_same_baseURL {

    NSURL *baseURL1 = [NSURL URLWithString:@"an-url://hi"];
    NSURL *baseURL2 = [NSURL URLWithString:@"an-url://hi-again"];
    BTHTTP *http1  = [[BTHTTP alloc] initWithBaseURL:baseURL1 authorizationFingerprint:@"test-authorization-fingerprint"];
    BTHTTP *http2  = [[BTHTTP alloc] initWithBaseURL:baseURL2 authorizationFingerprint:@"test-authorization-fingerprint"];

    expect(http1).notTo.equal(http2);
}

- (void)test_returns_NO_if_BTHTTPs_do_not_have_the_same_authorizationFingerprint {

    NSURL *baseURL1 = [NSURL URLWithString:@"an-url://hi"];
    BTHTTP *http1  = [[BTHTTP alloc] initWithBaseURL:baseURL1 authorizationFingerprint:@"test-authorization-fingerprint"];
    BTHTTP *http2  = [[BTHTTP alloc] initWithBaseURL:baseURL1 authorizationFingerprint:@"OTHER"];

    expect(http1).notTo.equal(http2);
}

#pragma mark copy

- (void)test_returns_a_different_instance {
    http = [[BTHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL] authorizationFingerprint:@"test-authorization-fingerprint"];

    expect(http).toNot.beIdenticalTo([http copy]);
}

- (void)test_returns_an_equal_instance {
    http = [[BTHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL] authorizationFingerprint:@"test-authorization-fingerprint"];

    expect([http copy]).to.equal(http);
}

- (void)test_returned_instance_has_the_same_certificates {
    http = [[BTHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL] authorizationFingerprint:@"test-authorization-fingerprint"];

    BTHTTP *copiedHTTP = [http copy];
    expect(copiedHTTP.pinnedCertificates).to.equal(http.pinnedCertificates);
}

@end
