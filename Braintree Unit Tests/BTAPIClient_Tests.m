#import <XCTest/XCTest.h>
#import "BTAPIClient_Internal.h"
#import "BTHTTP.h"
#import "BTHTTPTestProtocol.h"
#import <BraintreeApplePay/BTConfiguration+ApplePay.h>
#import <BraintreePayPal/BTConfiguration+PayPal.h>
#import <BraintreeVenmo/BTConfiguration+Venmo.h>

@interface FakeHTTP : BTHTTP

@property (nonatomic, assign) NSUInteger GETRequestCount;
@property (nonatomic, assign) NSUInteger POSTRequestCount;
@property (nonatomic, copy) NSString *lastRequestEndpoint;
@property (nonatomic, strong) NSDictionary *lastRequestParameters;
@property (nonatomic, copy) NSString *stubMethod;
@property (nonatomic, copy) NSString *stubEndpoint;
@property (nonatomic, strong) BTJSON *cannedResponse;
@property (nonatomic, assign) NSUInteger cannedStatusCode;
@property (nonatomic, strong) NSError *cannedError;

+ (instancetype)fakeHTTP;

@end

@implementation FakeHTTP

+ (instancetype)fakeHTTP {
    return [[FakeHTTP alloc] initWithBaseURL:[[NSURL alloc] init] authorizationFingerprint:@""];
}

- (void)stubRequest:(NSString *)httpMethod toEndpoint:(NSString *)endpoint respondWith:(id)value statusCode:(NSUInteger)statusCode {
    self.stubMethod = httpMethod;
    self.stubEndpoint = endpoint;
    self.cannedResponse = [[BTJSON alloc] initWithValue:value];
    self.cannedStatusCode = statusCode;
}

- (void)stubRequest:(NSString *)httpMethod toEndpoint:(NSString *)endpoint respondWithError:(NSError *)error {
    self.stubMethod = httpMethod;
    self.stubEndpoint = endpoint;
    self.cannedError = error;
}

- (void)GET:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *, NSHTTPURLResponse *, NSError *))completionBlock {
    self.GETRequestCount++;
    self.lastRequestEndpoint = endpoint;
    self.lastRequestParameters = parameters;

    if (self.cannedError) {
        [self dispatchBlock:^{
            completionBlock(nil, nil, self.cannedError);
        }];
    } else {
        NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:endpoint]
                                                                      statusCode:self.cannedStatusCode
                                                                     HTTPVersion:nil
                                                                    headerFields:nil];
        [self dispatchBlock:^{
            completionBlock(self.cannedResponse, httpResponse, nil);
        }];
    }
}

- (void)POST:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(void (^)(BTJSON *, NSHTTPURLResponse *, NSError *))completionBlock {
    self.POSTRequestCount++;
    self.lastRequestEndpoint = endpoint;
    self.lastRequestParameters = parameters;
    
    if (self.cannedError) {
        [self dispatchBlock:^{
            completionBlock(nil, nil, self.cannedError);
        }];
    } else {
        NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:endpoint]
                                                                      statusCode:self.cannedStatusCode
                                                                     HTTPVersion:nil
                                                                    headerFields:nil];
        [self dispatchBlock:^{
            completionBlock(self.cannedResponse, httpResponse, nil);
        }];
    }
}

/// Helper method to dispatch callbacks to dispatchQueue
- (void)dispatchBlock:(void(^)())block {
    if (self.dispatchQueue) {
        dispatch_async(self.dispatchQueue, ^{
            block();
        });
    } else {
        block();
    }
}

@end

@interface StubBTClientMetadata : BTClientMetadata
@property (nonatomic, assign) BTClientMetadataIntegrationType integration;
@property (nonatomic, assign) BTClientMetadataSourceType source;
@property (nonatomic, copy) NSString *sessionId;
@end

@implementation StubBTClientMetadata
@synthesize integration = _integration;
@synthesize source = _source;
@synthesize sessionId = _sessionId;
@end

@interface BTAPIClient_Tests : XCTestCase
@end

@implementation BTAPIClient_Tests

#pragma mark - Initialization

- (void)testInitialization_setsClientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];
    XCTAssertEqualObjects(apiClient.clientKey, @"development_client_key");
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

#pragma mark - Environment Base URL

- (void)testBaseURL_isDeterminedByClientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];
    XCTAssertEqualObjects(apiClient.http.baseURL.absoluteString, @"http://localhost:3000/merchants/key/client_api");

    apiClient = [[BTAPIClient alloc] initWithClientKey:@"sandbox_client_key" error:NULL];
    XCTAssertEqualObjects(apiClient.http.baseURL.absoluteString, @"https://sandbox.braintreegateway.com/merchants/key/client_api");

    apiClient = [[BTAPIClient alloc] initWithClientKey:@"production_client_key" error:NULL];
    XCTAssertEqualObjects(apiClient.http.baseURL.absoluteString, @"https://braintreegateway.com/merchants/key/client_api");
}

#pragma mark - Configuration

- (void)testAPIClient_canGetRemoteConfiguration {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];

    FakeHTTP *fake = [FakeHTTP fakeHTTP];
    [fake stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES } statusCode:200];

    apiClient.http = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertEqual(fake.GETRequestCount, 1);
        XCTAssertTrue(configuration.json[@"test"].isTrue);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfiguration_whenServerRespondsWithNon200StatusCode_returnsAPIClientError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];

    FakeHTTP *fake = [FakeHTTP fakeHTTP];
    [fake stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"error_message": @"Something bad happened" } statusCode:503];
    apiClient.http = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertEqual(fake.GETRequestCount, 1);
        XCTAssertNil(configuration);
        XCTAssertEqualObjects(error.domain, BTAPIClientErrorDomain);
        XCTAssertEqual(error.code, BTAPIClientErrorTypeConfigurationUnavailable);
        XCTAssertEqualObjects(error.localizedFailureReason, @"Unable to fetch remote configuration from Braintree API at this time.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfiguration_whenNetworkHasError_returnsNetworkErrorInCallback {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];

    FakeHTTP *fake = [FakeHTTP fakeHTTP];
    NSError *anError = [NSError errorWithDomain:NSURLErrorDomain
                                           code:NSURLErrorCannotConnectToHost
                                       userInfo:nil];
    [fake stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWithError:anError];
    apiClient.http = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertEqual(fake.GETRequestCount, 1);
        XCTAssertNil(configuration);
        XCTAssertEqual(error, anError);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfiguration_whenCalledSerially_performOnlyOneRequest {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];

    FakeHTTP *fake = [FakeHTTP fakeHTTP];
    [fake stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES } statusCode:200];
    apiClient.http = fake;

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"First fetch configuration"];

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertEqual(fake.GETRequestCount, 1);
        XCTAssertTrue(configuration.json[@"test"].isTrue);

        [expectation1 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Second fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertEqual(fake.GETRequestCount, 1);
        XCTAssertTrue(configuration.json[@"test"].isTrue);

        [expectation2 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Dispatch Queue

- (void)testDispatchQueueMainQueueByDefault {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];

    XCTAssertEqualObjects(apiClient.dispatchQueue, dispatch_get_main_queue());
}

- (void)testDispatchQueueMainQueueByDefaultWhenNilSpecified {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" dispatchQueue:nil error:NULL];

    XCTAssertEqualObjects(apiClient.dispatchQueue, dispatch_get_main_queue());
}

- (void)testDispatchQueueRetainedWhenSpecified {
    dispatch_queue_t q = dispatch_queue_create("com.braintreepayments.BTAPIClient_Tests.testDispatchQueueRetainedWhenSpecified", DISPATCH_QUEUE_SERIAL);
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" dispatchQueue:q error:NULL];

    XCTAssertEqualObjects(apiClient.dispatchQueue, q);
}

- (void)testCallbacks_useDispatchQueue {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key"
                                                      dispatchQueue:dispatch_get_main_queue()
                                                              error:NULL];
    FakeHTTP *fake = [[FakeHTTP alloc] initWithBaseURL:apiClient.http.baseURL authorizationFingerprint:@""];
    fake.dispatchQueue = dispatch_queue_create("not.the.main.queue", DISPATCH_QUEUE_SERIAL);
    apiClient.http = fake;

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        [NSThread isMainThread];
        [expectation1 fulfill];
    }];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"GET request"];
    [apiClient GET:@"" parameters:@{} completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        [NSThread isMainThread];
        [expectation2 fulfill];
    }];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"POST request"];
    [apiClient POST:@"" parameters:@{} completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        [NSThread isMainThread];
        [expectation3 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Payment option categories

- (void)testIsVenmoEnabled_whenEnabled_returnsTrue {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"venmo": @"production" }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertTrue(configuration.isVenmoEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsVenmoEnabled_whenDisabled_returnsFalse {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"venmo": @"off" }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertFalse(configuration.isVenmoEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsPayPalEnabled_whenEnabled_returnsTrue {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"paypalEnabled": @(YES) }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertTrue(configuration.isPayPalEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsPayPalEnabled_whenDisabled_returnsFalse {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"paypalEnabled": @(NO) }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertFalse(configuration.isPayPalEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsApplePayEnabled_whenEnabled_returnsTrue {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"applePay": @{ @"status": @"production" } }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertTrue(configuration.isApplePayEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsApplePayEnabled_whenDisabled_returnsFalse {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"applePay": @{ @"status": @"off" } }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertFalse(configuration.isApplePayEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Analytics tests

- (void)testPostAnalyticsEvent_whenRemoteConfigurationHasNoAnalyticsURL_doesNotSendEvent {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];
    FakeHTTP *stubConfigurationHTTP = [FakeHTTP fakeHTTP];
    apiClient.http = stubConfigurationHTTP;
    FakeHTTP *mockAnalyticsHttp = [FakeHTTP fakeHTTP];
    apiClient.analyticsHttp = mockAnalyticsHttp;
    [stubConfigurationHTTP stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith:@{} statusCode:200];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [apiClient postAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertTrue(mockAnalyticsHttp.POSTRequestCount == 0);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPostAnalyticsEvent_whenRemoteConfigurationHasAnalyticsURL_setsUpAnalyticsHTTPToUseBaseURL {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];
    FakeHTTP *stubConfigurationHTTP = [FakeHTTP fakeHTTP];
    apiClient.http = stubConfigurationHTTP;
    [stubConfigurationHTTP stubRequest:@"GET"
                            toEndpoint:@"/client_api/v1/configuration"
                           respondWith:@{
                                         @"analytics" : @{
                                                 @"url" : @"test://do-not-send.url"
                                                 } }
                            statusCode:200];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Uses analytics base URL"];
    [apiClient postAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertEqualObjects(apiClient.analyticsHttp.baseURL.absoluteString, @"test://do-not-send.url");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPostAnalyticsEvent_whenSuccessful_sendsAnalyticsEvent {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];
    apiClient = [apiClient copyWithSource:BTClientMetadataSourceCoinbaseApp integration:BTClientMetadataIntegrationCustom];
    FakeHTTP *mockAnalyticsHTTP = [FakeHTTP fakeHTTP];
    FakeHTTP *stubConfigurationHTTP = [FakeHTTP fakeHTTP];
    apiClient.analyticsHttp = mockAnalyticsHTTP;
    apiClient.http = stubConfigurationHTTP;
    [stubConfigurationHTTP stubRequest:@"GET"
                            toEndpoint:@"/client_api/v1/configuration"
                           respondWith:@{
                                         @"analytics" : @{
                                                 @"url" : @"test://do-not-send.url"
                                                 } }
                            statusCode:200];
    BTClientMetadata *metadata = apiClient.metadata;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [apiClient postAnalyticsEvent:@"an.analytics.event" completion:^(NSError *error) {
        XCTAssertEqual(metadata.source, BTClientMetadataSourceCoinbaseApp);
        XCTAssertEqual(metadata.integration, BTClientMetadataIntegrationCustom);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestEndpoint, @"/");
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"], @[ @{ @"kind" : @"an.analytics.event" } ]);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"_meta"][@"integration"], metadata.integrationString);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"_meta"][@"source"], metadata.sourceString);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"_meta"][@"sessionId"], metadata.sessionId);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)POST_usesMetadataSourceAndIntegration {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];
    apiClient = [apiClient copyWithSource:BTClientMetadataSourcePayPalApp integration:BTClientMetadataIntegrationDropIn];
    FakeHTTP *mockHTTP = [FakeHTTP fakeHTTP];
    FakeHTTP *stubAnalyticsHTTP = [FakeHTTP fakeHTTP];
    apiClient.http = mockHTTP;
    apiClient.analyticsHttp = stubAnalyticsHTTP;
    [mockHTTP stubRequest:@"GET"
               toEndpoint:@"/client_api/v1/configuration"
              respondWith:@{
                            @"analytics" : @{
                                    @"url" : @"test://do-not-send.url"
                                    } }
               statusCode:200];
    BTClientMetadata *metadata = apiClient.metadata;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [apiClient POST:@"/" parameters:@{} completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertEqualObjects(mockHTTP.lastRequestEndpoint, @"/");
        XCTAssertEqual(apiClient.metadata.source, BTClientMetadataSourcePayPalApp);
        XCTAssertEqual(apiClient.metadata.integration, BTClientMetadataIntegrationDropIn);
        XCTAssertEqualObjects(mockHTTP.lastRequestParameters[@"_meta"][@"integration"], metadata.integrationString);
        XCTAssertEqualObjects(mockHTTP.lastRequestParameters[@"_meta"][@"source"], metadata.sourceString);
        XCTAssertEqualObjects(mockHTTP.lastRequestParameters[@"_meta"][@"sessionId"], metadata.sessionId);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];

}

#pragma mark - Helpers

- (BTAPIClient *)clientThatReturnsConfiguration:(NSDictionary *)configurationDictionary {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_client_key" error:NULL];
    FakeHTTP *fake = [FakeHTTP fakeHTTP];
    fake.cannedResponse = [[BTJSON alloc] initWithValue:configurationDictionary];
    fake.cannedStatusCode = 200;
    apiClient.http = fake;

    return apiClient;
}

@end
