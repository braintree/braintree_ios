#import <XCTest/XCTest.h>
#import "BTAPIClient_Internal.h"
#import "BTHTTP.h"
#import "BTHTTPTestProtocol.h"

@interface FakeHTTP : BTHTTP

@property (nonatomic, assign) NSUInteger requestCount;

@property (nonatomic, copy) NSString *expectedEndpoint;
@property (nonatomic, strong) BTJSON *cannedResponse;
@property (nonatomic, assign) NSUInteger cannedStatusCode;
@property (nonatomic, strong) NSError *cannedError;

@end

@implementation FakeHTTP

- (void)expectGETRequestToEndpoint:(NSString *)endpoint respondWith:(id)value {
    [self expectGETRequestToEndpoint:endpoint respondWith:value statusCode:200];
}

- (void)expectGETRequestToEndpoint:(NSString *)endpoint respondWith:(id)value statusCode:(NSUInteger)statusCode {
    self.expectedEndpoint = endpoint;
    self.cannedResponse = [[BTJSON alloc] initWithValue:value];
    self.cannedStatusCode = statusCode;
}

- (void)expectGETRequestToEndpoint:(NSString *)endpoint respondWithError:(NSError *)error {
    self.expectedEndpoint = endpoint;
    self.cannedError = error;
}

- (void)GET:(NSString *)url parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    self.requestCount++;
    if (self.cannedError) {
        completionBlock(nil, nil, self.cannedError);
    } else {
        NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url]
                                                                      statusCode:self.cannedStatusCode
                                                                     HTTPVersion:nil
                                                                    headerFields:nil];
        completionBlock(self.cannedResponse, httpResponse, nil);
    }
}

@end

@interface BTAPIClient_Tests : XCTestCase
@end

@implementation BTAPIClient_Tests

- (void)testAPIClientHasAKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"test_client_key" error:NULL];
    XCTAssertEqualObjects(apiClient.clientKey, @"test_client_key");
}

- (void)testClientApiHTTP_infersBaseURLFromClientKey_sandbox {
    XCTestExpectation *expectation = [self expectationWithDescription:@"HTTP Response"];
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"sandbox_stuff_test_merchant_id" error:NULL];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [sessionConfiguration setProtocolClasses:@[[BTHTTPTestProtocol class]]];
    apiClient.http.session = [NSURLSession sessionWithConfiguration:sessionConfiguration];

    [apiClient.http GET:@"foo" completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        NSURLRequest *request = [BTHTTPTestProtocol parseRequestFromTestResponseBody:body];
        XCTAssertEqualObjects(request.URL.absoluteString, @"https://sandbox.braintreegateway.com/merchants/test_merchant_id/client_api/foo?authorization_fingerprint=sandbox_stuff_test_merchant_id");

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testAPIClientCanGetRemoteConfiguration {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"test_client_key" error:NULL];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES }];

    apiClient.http = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertTrue(remoteConfiguration[@"test"].isTrue);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testAPIClientBaseURL_isDeterminedByClientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"test_client_key" error:NULL];
    XCTAssertEqualObjects(apiClient.http.baseURL.absoluteString, @"https://test/merchants/key/client_api");
}

- (void)testAPIClientCanFailWhenTheServerRespondsWithANon200StatusCode {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"test_client_key" error:NULL];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"error_message": @"Something bad happened" } statusCode:503];

    apiClient.http = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertNil(remoteConfiguration);
        XCTAssertEqualObjects(error.domain, BTAPIClientErrorDomain);
        XCTAssertEqual(error.code, BTAPIClientErrorTypeConfigurationUnavailable);
        XCTAssertEqualObjects(error.localizedFailureReason, @"Unable to fetch remote configuration from Braintree API at this time.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testAPIClientFailsWhenNetworkHasError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"test_client_key" error:NULL];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    NSError *anError = [NSError errorWithDomain:NSURLErrorDomain
                                           code:NSURLErrorCannotConnectToHost
                                       userInfo:nil];
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWithError:anError];

    apiClient.http = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertNil(remoteConfiguration);
        XCTAssertEqual(error, anError);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testSerialInvocationsOfFetchConfigurationPerformOnlyOneRequest {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"test_client_key" error:NULL];

    FakeHTTP *fake = [[FakeHTTP alloc] init];
    [fake expectGETRequestToEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES }];
    apiClient.http = fake;

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"First fetch configuration"];

    [apiClient fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertTrue(remoteConfiguration[@"test"].isTrue);

        [expectation1 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Second fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTJSON *remoteConfiguration, NSError *error) {
        XCTAssertEqual(fake.requestCount, 1);
        XCTAssertTrue(remoteConfiguration[@"test"].isTrue);

        [expectation2 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInitialization_withInvalidClientKey_returnsError {
    NSError *error;
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"invalid-client-key" error:&error];
    XCTAssertNil(apiClient);
    XCTAssertEqualObjects(error.domain, BTAPIClientErrorDomain);
    XCTAssertEqual(error.code, BTAPIClientErrorTypeInvalidClientKey);
}

- (void)testInitialization_withInvalidEnvironment_returnsError {
    NSError *error;
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"foo_client_key" error:&error];
    XCTAssertNil(apiClient);
    XCTAssertEqualObjects(error.domain, BTAPIClientErrorDomain);
    XCTAssertEqual(error.code, BTAPIClientErrorTypeInvalidClientKey);
}

#pragma mark - Dispatch Queue

- (void)testDispatchQueueMainQueueByDefault {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"test_client_key" error:NULL];

    XCTAssertEqualObjects(apiClient.dispatchQueue, dispatch_get_main_queue());
}

- (void)testDispatchQueueMainQueueByDefaultWhenNilSpecified {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"test_client_key" dispatchQueue:nil error:NULL];

    XCTAssertEqualObjects(apiClient.dispatchQueue, dispatch_get_main_queue());
}

- (void)testDispatchQueueRetainedWhenSpecified {
    dispatch_queue_t q = dispatch_queue_create("com.braintreepayments.BTAPIClient_Tests.testDispatchQueueRetainedWhenSpecified", DISPATCH_QUEUE_SERIAL);
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"test_client_key" dispatchQueue:q error:NULL];

    XCTAssertEqualObjects(apiClient.dispatchQueue, q);
}


@end
