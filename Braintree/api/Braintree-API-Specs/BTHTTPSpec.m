#import "BTHTTP.h"
#import "BTSpecHelper.h"

#define kBTHTTPTestProtocolScheme @"bt-http-test"
#define kBTHTTPTestProtocolHost @"base.example.com"
#define kBTHTTPTestProtocolBasePath @"/base/path/"
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

+ (NSURLRequest *)parseRequestFromTestResponse:(BTHTTPResponse *)response {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithBase64EncodedString:response.object[@"request"] options:0]];
}

+ (NSString *)parseRequestBodyFromTestResponse:(BTHTTPResponse *)response {
    return response.object[@"requestBody"];
}

@end

SpecBegin(BTHTTP)

describe(@"performing a request", ^{
    __block BTHTTP *http;

    beforeEach(^{
        http = [[BTHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL]];
        [http setProtocolClasses:@[[BTHTTPTestProtocol class]]];
    });

    describe(@"base URL", ^{
        it(@"sends requests using the specified URL scheme", ^AsyncBlock{
            [http GET:@"200.json" completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];

                expect(httpRequest.URL.scheme).to.equal(@"bt-http-test");
                done();
            }];
        });

        it(@"sends requests to the host at the base URL", ^AsyncBlock{
            [http GET:@"200.json" completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.host).to.equal(@"base.example.com");

                done();
            }];
        });

        it(@"appends the path to the base URL", ^AsyncBlock{
            [http GET:@"200.json" completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];

                expect(httpRequest.URL.path).to.equal(@"/base/path/200.json");
                done();
            }];
        });
    });

    describe(@"HTTP methods", ^{
        it(@"sends a GET request", ^AsyncBlock{
            [http GET:@"200.json" completion:^(BTHTTPResponse *response, NSError *error){
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequest.HTTPMethod).to.equal(@"GET");
                expect(httpRequest.HTTPBody).to.beNil();
                done();
            }];
        });

        it(@"sends a GET request with parameters", ^AsyncBlock{
            [http GET:@"200.json" parameters:@{@"param": @"value"} completion:^(BTHTTPResponse *response, NSError *error){
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequest.URL.query).to.equal(@"param=value");
                expect(httpRequest.HTTPMethod).to.equal(@"GET");
                expect(httpRequest.HTTPBody).to.beNil();
                done();
            }];
        });

        it(@"sends a POST request", ^AsyncBlock{
            [http POST:@"200.json" completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequest.HTTPBody).to.beNil();
                expect(httpRequest.HTTPMethod).to.equal(@"POST");
                expect(httpRequest.URL.query).to.beNil();
                done();
            }];
        });

        it(@"sends a POST request with parameters", ^AsyncBlock{
            [http POST:@"200.json" parameters:@{@"param": @"value"} completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                NSString *httpRequestBody = [BTHTTPTestProtocol parseRequestBodyFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequestBody).to.equal(@"{\n  \"param\" : \"value\"\n}");
                expect(httpRequest.HTTPMethod).to.equal(@"POST");
                expect(httpRequest.URL.query).to.beNil();
                done();
            }];
        });

        it(@"sends a PUT request", ^AsyncBlock{
            [http PUT:@"200.json" completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"200.json$");
                expect(httpRequest.HTTPBody).to.beNil();
                expect(httpRequest.HTTPMethod).to.equal(@"PUT");
                expect(httpRequest.URL.query).to.beNil();
                done();
            }];
        });

        it(@"sends a PUT request with parameters", ^AsyncBlock{
            [http PUT:@"200.json" parameters:@{@"param": @"value"} completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                NSString *httpRequestBody = [BTHTTPTestProtocol parseRequestBodyFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"200.json$");
                expect(httpRequestBody).to.equal(@"{\n  \"param\" : \"value\"\n}");
                expect(httpRequest.HTTPMethod).to.equal(@"PUT");
                expect(httpRequest.URL.query).to.beNil();
                done();
            }];
        });


        it(@"sends a DELETE request", ^AsyncBlock{
            [http DELETE:@"200.json" completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                expect(httpRequest.URL.path).to.match(@"200.json$");
                expect(httpRequest.HTTPBody).to.beNil();
                expect(httpRequest.HTTPMethod).to.equal(@"DELETE");
                expect(httpRequest.URL.query).to.equal(@"");
                done();
            }];
        });

        it(@"sends a DELETE request with parameters", ^AsyncBlock{
            [http DELETE:@"200.json" parameters:@{@"param": @"value"} completion:^(BTHTTPResponse *response, NSError *error){
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];

                expect(httpRequest.URL.path).to.match(@"/200.json$");
                expect(httpRequest.URL.query).to.equal(@"param=value");
                expect(httpRequest.HTTPMethod).to.equal(@"DELETE");
                expect(httpRequest.HTTPBody).to.beNil();
                done();
            }];
        });
    });

    describe(@"default headers", ^{
        __block id<OHHTTPStubsDescriptor>stubDescriptor;

        beforeEach(^{
            stubDescriptor = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                NSData *jsonResponse = [NSJSONSerialization dataWithJSONObject:@{@"requestHeaders": [request allHTTPHeaderFields]} options:NSJSONWritingPrettyPrinted error:nil];
                return [OHHTTPStubsResponse responseWithData:jsonResponse statusCode:200 headers:@{@"Content-type": @"application/json"}];
            }];
        });

        afterEach(^{
            [OHHTTPStubs removeStub:stubDescriptor];
        });

        it(@"include Accept", ^AsyncBlock{
            [http GET:@"stub://200/resource" parameters:nil completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                expect(requestHeaders[@"Accept"]).to.equal(@"application/json");
                done();
            }];
        });

        it(@"include User-Agent", ^AsyncBlock{
            [http GET:@"stub://200/resource" parameters:nil completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                expect(requestHeaders[@"User-Agent"]).to.match(@"^braintree-api-ios/\\d+\\.\\d+\\.\\d+ (iPhone|iPad)/\\d+\\.\\d+ (\\w+|\\w+\\d,\\d)(\\(simulator\\))?/x86_64$");
                done();
            }];
        });

        it(@"include Accept-Language", ^AsyncBlock{
            [http GET:@"stub://200/resource" parameters:nil completion:^(BTHTTPResponse *response, NSError *error) {
                NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                NSDictionary *requestHeaders = httpRequest.allHTTPHeaderFields;
                expect(requestHeaders[@"Accept-Language"]).to.equal(@"en-US");
                done();
            }];
        });
    });

    describe(@"parameters", ^{
        __block NSDictionary *parameterDictionary;

        beforeEach(^{
            parameterDictionary = @{@"stringParameter": @"value",
                                    @"crazyStringParameter[]": @"crazy%20and&value",
                                    @"numericParameter": @42,
                                    @"trueBooleanParameter": @YES,
                                    @"falseBooleanParameter": @NO,
                                    @"dictionaryParameter":  @{ @"dictionaryKey": @"dictionaryValue" },
                                    @"arrayParameter": @[@"arrayItem1", @"arrayItem2"]
                                    };
        });

        describe(@"in GET requests", ^{
            it(@"transmits the parameters as URL encoded query parameters", ^AsyncBlock{
                NSString *encodedParameters = @"numericParameter=42&falseBooleanParameter=0&dictionaryParameter%5BdictionaryKey%5D=dictionaryValue&trueBooleanParameter=1&stringParameter=value&crazyStringParameter%5B%5D=crazy%2520and%26value&arrayParameter%5B%5D=arrayItem1&arrayParameter%5B%5D=arrayItem2";

                [http GET:@"200.json" parameters:parameterDictionary completion:^(BTHTTPResponse *response, NSError *error) {
                    NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                    expect(httpRequest.URL.query).to.equal(encodedParameters);
                    done();
                }];
            });
        });

        describe(@"in non-GET requests", ^{
            it(@"transmits the parameters as JSON", ^AsyncBlock{
                NSString *encodedParameters = @"{\n  \"numericParameter\" : 42,\n  \"falseBooleanParameter\" : false,\n  \"dictionaryParameter\" : {\n    \"dictionaryKey\" : \"dictionaryValue\"\n  },\n  \"trueBooleanParameter\" : true,\n  \"stringParameter\" : \"value\",\n  \"crazyStringParameter[]\" : \"crazy%20and&value\",\n  \"arrayParameter\" : [\n    \"arrayItem1\",\n    \"arrayItem2\"\n  ]\n}";

                [http POST:@"200.json" parameters:parameterDictionary completion:^(BTHTTPResponse *response, NSError *error) {
                    NSURLRequest *httpRequest = [BTHTTPTestProtocol parseRequestFromTestResponse:response];
                    NSString *httpRequestBody = [BTHTTPTestProtocol parseRequestBodyFromTestResponse:response];

                    expect([httpRequest valueForHTTPHeaderField:@"Content-type"]).to.equal(@"application/json; charset=utf-8");
                    expect(httpRequestBody).to.equal(encodedParameters);

                    done();
                }];
            });
        });
    });
});

describe(@"interpreting responses", ^{
    __block BTHTTP *http;
    beforeEach(^{
        http = [[BTHTTP alloc] initWithBaseURL:[NSURL URLWithString:@"stub://stub"]];
    });

    describe(@"response code parser", ^{
        it(@"interprets 2xx as a completion with success", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{} options:NSJSONWritingPrettyPrinted error:NULL] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];

            [http GET:@"200.json" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.statusCode).to.equal(200);
                expect(response.isSuccess).to.beTruthy();

                expect(error).to.beNil();

                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });

        it(@"interprets 403 as an integration error", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{} options:NSJSONWritingPrettyPrinted error:NULL] statusCode:403 headers:@{@"Content-Type": @"application/json"}];
            }];

            [http GET:@"403.json" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.statusCode).to.equal(403);
                expect(response.isSuccess).to.beFalsy();
                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTMerchantIntegrationErrorUnauthorized);

                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });

        it(@"interprets 422 as an client error", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{} options:NSJSONWritingPrettyPrinted error:NULL] statusCode:422 headers:@{@"Content-Type": @"application/json"}];
            }];

            [http GET:@"422.json" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.statusCode).to.equal(422);
                expect(response.isSuccess).to.beFalsy();
                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });

        it(@"interprets 5xx as an error", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{} options:NSJSONWritingPrettyPrinted error:NULL] statusCode:503 headers:@{@"Content-Type": @"application/json"}];
            }];

            [http GET:@"503.json" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.statusCode).to.equal(503);
                expect(response.isSuccess).to.beFalsy();
                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTServerErrorGatewayUnavailable);
                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });

        it(@"interprets the network being down as an error", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil]];
            }];

            [http GET:@"network-down" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response).to.beNil();
                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTServerErrorNetworkUnavailable);
                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });

        it(@"interprets the server being unavailable as an error", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
            }];


            [http GET:@"gateway-down" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.isSuccess).to.beFalsy();

                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTServerErrorGatewayUnavailable);
                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });
    });

    describe(@"response body parser", ^{
        it(@"parses a JSON response body", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:[@"{\"status\": \"OK\"}" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];

            [http GET:@"200.json" completion:^(BTHTTPResponse *response, NSError *error){
                expect(response.object).to.equal(@{@"status": @"OK"});

                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });

        it(@"parses a JSON response body, even for a non-200 response", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:[@"{\"status\": \"ERROR\"}" dataUsingEncoding:NSUTF8StringEncoding] statusCode:422 headers:@{@"Content-Type": @"application/json"}];
            }];

            [http GET:@"422.json" completion:^(BTHTTPResponse *response, NSError *error){
                expect(response.object).to.equal(@{@"status": @"ERROR"});

                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });

        it(@"accepts empty responses", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:nil statusCode:200 headers:nil];
            }];

            [http GET:@"empty.json" completion:^(BTHTTPResponse *response, NSError *error){
                expect(response.statusCode).to.equal(200);
                expect(response.isSuccess).to.beTruthy();
                expect(response.object).to.beNil();

                expect(error).to.beNil();

                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });

        it(@"interprets invalid JSON responses as a server error", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:[@"{ really invalid json ]" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];

            [http GET:@"invalid.json" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response).to.beNil();

                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTServerErrorUnexpectedError);

                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });

        it(@"interprets valid but non-JSON responses as a server error", ^AsyncBlock{
            id<OHHTTPStubsDescriptor>stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:[@"<html>response</html>" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type": @"text/html"}];
            }];

            [http GET:@"200.html" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response).to.beNil();

                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTServerErrorUnexpectedError);

                [OHHTTPStubs removeStub:stub];
                done();
            }];
        });
    });

    it(@"noops for a nil completion block", ^AsyncBlock{
        setAsyncSpecTimeout(2);

        [http GET:@"200.json" parameters:nil completion:nil];

        wait_for_potential_async_exceptions(done);
    });
});

describe(@"protocolClasses property", ^{
    it(@"successfully intercepts requests", ^AsyncBlock{
        BTHTTP *http = [[BTHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL]];

        [http GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTServerErrorUnexpectedError);

            [http setProtocolClasses:@[[BTHTTPTestProtocol class]]];

            [http GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(error).to.beNil();
                expect(response.isSuccess).to.beTruthy();
                done();
            }];

        }];
    });

    it(@"only intercepts requests made by that instnace of BTHTTP", ^AsyncBlock{
        BTHTTP *httpWithTestProtocol = [[BTHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL]];
        
        [httpWithTestProtocol setProtocolClasses:@[[BTHTTPTestProtocol class]]];
        
        BTHTTP *httpWithoutTestProtocol = [[BTHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL]];
        
        [httpWithTestProtocol GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
            expect(response.isSuccess).to.beTruthy();
            [httpWithoutTestProtocol GET:@"/" completion:^(BTHTTPResponse *response, NSError *error) {
                expect(response.isSuccess).to.beFalsy();
                done();
            }];
        }];
    });
});

SpecEnd