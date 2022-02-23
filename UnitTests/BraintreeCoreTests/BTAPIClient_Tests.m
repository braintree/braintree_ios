#import "BTAnalyticsService.h"
#import "BTAPIClient_Internal.h"
@import BraintreeCore;
@import BraintreeTestShared;
@import XCTest;

@interface StubBTClientMetadata : BTClientMetadata

@property (nonatomic, assign) BTClientMetadataIntegrationType integration;
@property (nonatomic, assign) BTClientMetadataSourceType source;
@property (nonatomic, copy) NSString *sessionID;

@end

@implementation StubBTClientMetadata

@synthesize integration = _integration;
@synthesize source = _source;
@synthesize sessionID = _sessionID;

@end

@interface BTFakeAnalyticsService : BTAnalyticsService

@property (nonatomic, copy) NSString *lastEvent;
@property (nonatomic, assign) BOOL didLastFlush;

@end

@implementation BTFakeAnalyticsService

- (void)sendAnalyticsEvent:(NSString *)eventKind {
    self.lastEvent = eventKind;
    self.didLastFlush = NO;
}

- (void)sendAnalyticsEvent:(NSString *)eventKind completion:(__unused void (^)(NSError *))completionBlock {
    self.lastEvent = eventKind;
    self.didLastFlush = YES;
}

@end

@interface BTAPIClient_Tests : XCTestCase
@end

@implementation BTAPIClient_Tests

#pragma mark - Initialization

- (void)testInitialization_withValidTokenizationKey_setsTokenizationKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    XCTAssertEqualObjects(apiClient.tokenizationKey, @"development_tokenization_key");
}

- (void)testInitialization_withInvalidTokenizationKey_returnsNil {
    XCTAssertNil([[BTAPIClient alloc] initWithAuthorization:@"not_a_valid_tokenization_key" sendAnalyticsEvent:NO]);
}

- (void)testInitialization_withValidClientToken_setsClientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:TestClientTokenFactory.validClientToken sendAnalyticsEvent:NO];
    XCTAssertEqualObjects(apiClient.clientToken.originalValue, TestClientTokenFactory.validClientToken);
}

- (void)testInitialization_withInvalidClientToken_returnsNil {
    XCTAssertNil([[BTAPIClient alloc] initWithAuthorization:@"invalidclienttoken" sendAnalyticsEvent:NO]);
}

#pragma mark - Environment Base URL

- (void)testBaseURL_isDeterminedByTokenizationKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    XCTAssertEqualObjects(apiClient.configurationHTTP.baseURL.absoluteString, @"http://localhost:3000/merchants/key/client_api");

    apiClient = [[BTAPIClient alloc] initWithAuthorization:@"sandbox_tokenization_key" sendAnalyticsEvent:NO];
    XCTAssertEqualObjects(apiClient.configurationHTTP.baseURL.absoluteString, @"https://api.sandbox.braintreegateway.com/merchants/key/client_api");

    apiClient = [[BTAPIClient alloc] initWithAuthorization:@"production_tokenization_key" sendAnalyticsEvent:NO];
    XCTAssertEqualObjects(apiClient.configurationHTTP.baseURL.absoluteString, @"https://api.braintreegateway.com:443/merchants/key/client_api");
}

#pragma mark - Configuration

- (void)testAPIClient_canGetRemoteConfiguration {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    FakeHTTP *fakeConfigurationHTTP = [FakeHTTP fakeHTTP];
    fakeConfigurationHTTP.cannedConfiguration = [[BTJSON alloc] initWithValue:@{ @"test": @YES }];
    fakeConfigurationHTTP.cannedStatusCode = 200;
    apiClient.configurationHTTP = fakeConfigurationHTTP;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNotNil(configuration);
        XCTAssertNil(error);

        XCTAssertGreaterThanOrEqual(fakeConfigurationHTTP.GETRequestCount, 1);
        XCTAssertTrue([configuration.json[@"test"] isTrue]);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfiguration_whenServerRespondsWithNon200StatusCode_returnsAPIClientError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];

    FakeHTTP *fake = [FakeHTTP fakeHTTP];
    [fake stubRequestWithMethod:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"error_message": @"Something bad happened" } statusCode:503];
    apiClient.configurationHTTP = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        // Note: GETRequestCount will be 1 or 2 depending on whether the analytics event for the API client initialization
        // has failed yet
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

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];

    FakeHTTP *fake = [FakeHTTP fakeHTTP];
    NSError *anError = [NSError errorWithDomain:NSURLErrorDomain
                                           code:NSURLErrorCannotConnectToHost
                                       userInfo:nil];
    [fake stubRequestWithMethod:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWithError:anError];
    apiClient.configurationHTTP = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        // BTAPIClient fetches the config when initialized so there can potentially be 2 requests here
        XCTAssertLessThanOrEqual(fake.GETRequestCount, 2);
        XCTAssertNil(configuration);
        XCTAssertEqual(error, anError);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfigurationHTTP_byDefault_usesAnInMemoryCache {
    // We don't want configuration to cache configuration responses past the lifetime of the app
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    NSURLCache *cache = apiClient.configurationHTTP.session.configuration.URLCache;
    
    XCTAssertTrue(cache.diskCapacity == 0);
    XCTAssertTrue(cache.memoryCapacity > 0);
}

#pragma mark - Dispatch Queue

- (void)testCallbacks_useMainDispatchQueue {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    FakeHTTP *fake = [FakeHTTP fakeHTTP];
    // Override apiClient.http so that requests don't fail
    apiClient.configurationHTTP = fake;
    apiClient.http = fake;
    [fake stubRequestWithMethod:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith: @{ } statusCode:200];

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration *configuration, __unused NSError *error) {
        XCTAssert([NSThread isMainThread]);
        [expectation1 fulfill];
    }];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"GET request"];
    [apiClient GET:@"/endpoint" parameters:@{} completion:^(__unused BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNotNil(response);
        XCTAssertNil(error);

        XCTAssert([NSThread isMainThread]);
        [expectation2 fulfill];
    }];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"POST request"];
    [apiClient POST:@"/endpoint" parameters:@{} completion:^(__unused BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNotNil(response);
        XCTAssertNil(error);

        XCTAssert([NSThread isMainThread]);
        [expectation3 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Analytics tests

- (void)testAnalyticsService_isCreatedDuringInitialization {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    XCTAssertTrue([apiClient.analyticsService isKindOfClass:[BTAnalyticsService class]]);
}

- (void)testSendAnalyticsEvent_whenCalled_callsAnalyticsService_doesFlush {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    BTFakeAnalyticsService *mockAnalyticsService = [[BTFakeAnalyticsService alloc] init];
    apiClient.analyticsService = mockAnalyticsService;

    [apiClient sendAnalyticsEvent:@"blahblah"];

    XCTAssertEqualObjects(mockAnalyticsService.lastEvent, @"blahblah");
    XCTAssertTrue(mockAnalyticsService.didLastFlush);
}

- (void)testQueueAnalyticsEvent_whenCalled_callsAnalyticsService_doesNotFlush {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    BTFakeAnalyticsService *mockAnalyticsService = [[BTFakeAnalyticsService alloc] init];
    apiClient.analyticsService = mockAnalyticsService;

    [apiClient queueAnalyticsEvent:@"blahblahqueue"];

    XCTAssertEqualObjects(mockAnalyticsService.lastEvent, @"blahblahqueue");
    XCTAssertFalse(mockAnalyticsService.didLastFlush);
}

#pragma mark - Client SDK Metadata

- (void)testPOST_whenUsingGateway_includesMetadata {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    apiClient = [apiClient copyWithSource:BTClientMetadataSourcePayPalApp integration:BTClientMetadataIntegrationDropIn];
    FakeHTTP *mockHTTP = [FakeHTTP fakeHTTP];
    apiClient.http = mockHTTP;
    FakeHTTP *stubConfigurationHTTP = [FakeHTTP fakeHTTP];
    apiClient.configurationHTTP = stubConfigurationHTTP;
    [stubConfigurationHTTP stubRequestWithMethod:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith: @{} statusCode:200];

    BTClientMetadata *metadata = apiClient.metadata;

    XCTestExpectation *expectation = [self expectationWithDescription:@"POST callback"];
    [apiClient POST:@"/" parameters:@{} httpType:BTAPIClientHTTPTypeGateway completion:^(__unused BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        XCTAssertEqualObjects(mockHTTP.lastRequestParameters[@"_meta"][@"integration"], metadata.integrationString);
        XCTAssertEqualObjects(mockHTTP.lastRequestParameters[@"_meta"][@"source"], metadata.sourceString);
        XCTAssertEqualObjects(mockHTTP.lastRequestParameters[@"_meta"][@"sessionId"], metadata.sessionID);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPOST_whenUsingBraintreeAPI_doesNotIncludeMetadata {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    apiClient = [apiClient copyWithSource:BTClientMetadataSourcePayPalApp integration:BTClientMetadataIntegrationDropIn];
    FakeAPIHTTP *mockAPIHTTP = [FakeAPIHTTP fakeHTTP];
    apiClient.braintreeAPI = mockAPIHTTP;
    FakeHTTP *stubConfigurationHTTP = [FakeHTTP fakeHTTP];
    apiClient.configurationHTTP = stubConfigurationHTTP;
    [stubConfigurationHTTP stubRequestWithMethod:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith: @{} statusCode:200];

    XCTestExpectation *expectation = [self expectationWithDescription:@"POST callback"];
    [apiClient POST:@"/" parameters:@{} httpType:BTAPIClientHTTPTypeBraintreeAPI completion:^(__unused BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        XCTAssertEqualObjects(mockAPIHTTP.lastRequestParameters, @{});
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPOST_whenUsingGraphQLAPI_includesMetadata {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    apiClient = [apiClient copyWithSource:BTClientMetadataSourcePayPalApp integration:BTClientMetadataIntegrationDropIn];
    FakeGraphQLHTTP *mockGraphQLHTTP = [FakeGraphQLHTTP fakeHTTP];
    apiClient.graphQL = mockGraphQLHTTP;
    FakeHTTP *stubConfigurationHTTP = [FakeHTTP fakeHTTP];
    apiClient.configurationHTTP = stubConfigurationHTTP;
    [stubConfigurationHTTP stubRequestWithMethod:@"GET"
                            toEndpoint:@"/client_api/v1/configuration"
                           respondWith:@{
                                         @"graphQL": @{
                                                 @"url": @"graphql://graphql",
                                                 @"features": @[@"tokenize_credit_cards"]                                                                                   }
                                         }
                            statusCode:200];

    BTClientMetadata *metadata = apiClient.metadata;

    XCTestExpectation *expectation = [self expectationWithDescription:@"POST callback"];
    [apiClient POST:@"/" parameters:@{} httpType:BTAPIClientHTTPTypeGraphQLAPI completion:^(__unused BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
        XCTAssertEqualObjects(mockGraphQLHTTP.lastRequestParameters[@"clientSdkMetadata"], metadata.parameters);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - Timeouts

- (void)testGETCallback_returnFetchConfigErrors {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];

    FakeHTTP *fakeConfigurationHTTP = [FakeHTTP fakeHTTP];
    apiClient.configurationHTTP = fakeConfigurationHTTP;
    FakeHTTP *fakeHTTP = [FakeHTTP fakeHTTP];
    apiClient.http = fakeHTTP;

    NSError *anError = [NSError errorWithDomain:NSURLErrorDomain
                                           code:NSURLErrorCannotConnectToHost
                                       userInfo:nil];
    [fakeConfigurationHTTP stubRequestWithMethod:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWithError:anError];

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"GET request"];

    [apiClient GET:@"/example" parameters:@{} completion:^(__unused BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNil(response);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(anError, error);

        [expectation1 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testPOSTCallback_returnFetchConfigErrors {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    FakeHTTP *fakeConfigurationHTTP = [FakeHTTP fakeHTTP];
    apiClient.configurationHTTP = fakeConfigurationHTTP;
    FakeHTTP *fakeHTTP = [FakeHTTP fakeHTTP];
    apiClient.http = fakeHTTP;

    NSError *anError = [NSError errorWithDomain:NSURLErrorDomain
                                           code:NSURLErrorCannotConnectToHost
                                       userInfo:nil];
    [fakeConfigurationHTTP stubRequestWithMethod:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWithError:anError];

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"GET request"];

    [apiClient POST:@"/example" parameters:@{} completion:^(__unused BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNil(response);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(anError, error);

        [expectation1 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testGraphQLURLForEnvironment_returnsSandboxURL {
    NSURL *sandboxURL = [BTAPIClient graphQLURLForEnvironment:@"sandbox"];
    XCTAssertEqualObjects(sandboxURL.absoluteString, @"https://payments.sandbox.braintree-api.com/graphql");
}

- (void)testGraphQLURLForEnvironment_returnsDevelopmentURL {
    NSURL *developmentURL = [BTAPIClient graphQLURLForEnvironment:@"development"];
    XCTAssertEqualObjects(developmentURL.absoluteString, @"http://localhost:8080/graphql");
}

- (void)testGraphQLURLForEnvironment_returnsProductionURL {
    NSURL *productionURL = [BTAPIClient graphQLURLForEnvironment:@"production"];
    XCTAssertEqualObjects(productionURL.absoluteString, @"https://payments.braintree-api.com/graphql");
}

- (void)testGraphQLURLForEnvironment_returnsProductionURL_asDefault {
    NSURL *defaultURL = [BTAPIClient graphQLURLForEnvironment:@"unknown"];
    XCTAssertEqualObjects(defaultURL.absoluteString, @"https://payments.braintree-api.com/graphql");
}

@end
