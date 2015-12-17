#import <XCTest/XCTest.h>
#import "BTAPIClient_Internal.h"
#import "BTHTTP.h"
#import "BTHTTPTestProtocol.h"
#import <BraintreeApplePay/BTConfiguration+ApplePay.h>
#import <BraintreePayPal/BTConfiguration+PayPal.h>
#import <BraintreeVenmo/BTConfiguration+Venmo.h>
#import "BTFakeHTTP.h"

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

static NSString * const ValidClientToken = @"eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI3ODJhZmFlNDJlZTNiNTA4NWUxNmMzYjhkZTY3OGQxNTJhODFlYzk5MTBmZDNhY2YyYWU4MzA2OGI4NzE4YWZhfGNyZWF0ZWRfYXQ9MjAxNS0wOC0yMFQwMjoxMTo1Ni4yMTY1NDEwNjErMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTM3OTU5QTE5LThCMjktNDVBNC1CNTA3LTRFQUNBM0VBOEM4Nlx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6dHJ1ZSwiY29pbmJhc2UiOnsiY2xpZW50SWQiOiIxMWQyNzIyOWJhNThiNTZkN2UzYzAxYTA1MjdmNGQ1YjQ0NmQ0ZjY4NDgxN2NiNjIzZDI1NWI1NzNhZGRjNTliIiwibWVyY2hhbnRBY2NvdW50IjoiY29pbmJhc2UtZGV2ZWxvcG1lbnQtbWVyY2hhbnRAZ2V0YnJhaW50cmVlLmNvbSIsInNjb3BlcyI6ImF1dGhvcml6YXRpb25zOmJyYWludHJlZSB1c2VyIiwicmVkaXJlY3RVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbS9jb2luYmFzZS9vYXV0aC9yZWRpcmVjdC1sYW5kaW5nLmh0bWwiLCJlbnZpcm9ubWVudCI6Im1vY2sifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ==";

#pragma mark - Initialization

- (void)testInitialization_withValidTokenizationKey_setsTokenizationKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    XCTAssertEqualObjects(apiClient.tokenizationKey, @"development_tokenization_key");
}

- (void)testInitialization_withInvalidTokenizationKey_returnsNil {
    XCTAssertNil([[BTAPIClient alloc] initWithAuthorization:@"not_a_valid_tokenization_key"]);
}

- (void)testInitialization_withValidClientToken_setsClientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:ValidClientToken];
    XCTAssertEqualObjects(apiClient.clientToken.originalValue, ValidClientToken);
}

- (void)testInitialization_withInvalidClientToken_returnsNil {
    XCTAssertNil([[BTAPIClient alloc] initWithAuthorization:@"invalidclienttoken"]);
}

#pragma mark - Environment Base URL

- (void)testBaseURL_isDeterminedByTokenizationKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    XCTAssertEqualObjects(apiClient.http.baseURL.absoluteString, @"http://localhost:3000/merchants/key/client_api");

    apiClient = [[BTAPIClient alloc] initWithAuthorization:@"sandbox_tokenization_key"];
    XCTAssertEqualObjects(apiClient.http.baseURL.absoluteString, @"https://sandbox.braintreegateway.com/merchants/key/client_api");

    apiClient = [[BTAPIClient alloc] initWithAuthorization:@"production_tokenization_key"];
    XCTAssertEqualObjects(apiClient.http.baseURL.absoluteString, @"https://api.braintreegateway.com:443/merchants/key/client_api");
}

#pragma mark - Configuration

- (void)testAPIClient_canGetRemoteConfiguration {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];

    BTFakeHTTP *fake = [BTFakeHTTP fakeHTTP];
    [fake stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES } statusCode:200];

    apiClient.http = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNotNil(configuration);
        XCTAssertNil(error);

        XCTAssertEqual(fake.GETRequestCount, (NSUInteger)1);
        XCTAssertTrue([configuration.json[@"test"] isTrue]);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfiguration_whenServerRespondsWithNon200StatusCode_returnsAPIClientError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];

    BTFakeHTTP *fake = [BTFakeHTTP fakeHTTP];
    [fake stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"error_message": @"Something bad happened" } statusCode:503];
    apiClient.http = fake;

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

    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];

    BTFakeHTTP *fake = [BTFakeHTTP fakeHTTP];
    NSError *anError = [NSError errorWithDomain:NSURLErrorDomain
                                           code:NSURLErrorCannotConnectToHost
                                       userInfo:nil];
    [fake stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWithError:anError];
    apiClient.http = fake;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertEqual(fake.GETRequestCount, (NSUInteger)1);
        XCTAssertNil(configuration);
        XCTAssertEqual(error, anError);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testConfiguration_whenCalledSerially_performOnlyOneRequest {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];

    BTFakeHTTP *fake = [BTFakeHTTP fakeHTTP];
    [fake stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith:@{ @"test": @YES } statusCode:200];
    apiClient.http = fake;

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"First fetch configuration"];

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);

        XCTAssertEqual(fake.GETRequestCount, (NSUInteger)1);
        XCTAssertTrue([configuration.json[@"test"] isTrue]);

        [expectation1 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];

    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Second fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);

        XCTAssertEqual(fake.GETRequestCount, (NSUInteger)1);
        XCTAssertTrue([configuration.json[@"test"] isTrue]);

        [expectation2 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Dispatch Queue

- (void)testCallbacks_useMainDispatchQueue {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    BTFakeHTTP *fake = [[BTFakeHTTP alloc] initWithBaseURL:apiClient.http.baseURL authorizationFingerprint:@""];
    // Override apiClient.http so that requests don't fail
    apiClient.http = fake;

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(__unused BTConfiguration *configuration, __unused NSError *error) {
        XCTAssert([NSThread isMainThread]);
        [expectation1 fulfill];
    }];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"GET request"];
    [apiClient GET:@"" parameters:@{} completion:^(__unused BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNotNil(response);
        XCTAssertNil(error);

        XCTAssert([NSThread isMainThread]);
        [expectation2 fulfill];
    }];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"POST request"];
    [apiClient POST:@"" parameters:@{} completion:^(__unused BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNotNil(response);
        XCTAssertNil(error);

        XCTAssert([NSThread isMainThread]);
        [expectation3 fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Payment option categories

- (void)testIsVenmoEnabledIsFalse_withAccessToken_withBetaOverrideFalse {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"payWithVenmo": @{@"accessToken" : @"access-token"}}];
    [BTConfiguration enableVenmo:false];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);

        XCTAssertFalse(configuration.isVenmoEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsVenmoEnabledIsTrue_withAccessToken_withBetaOverrideTrue {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"payWithVenmo": @{@"accessToken" : @"access-token"}}];
    [BTConfiguration enableVenmo:true];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertTrue(configuration.isVenmoEnabled);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsVenmoEnabledIsFalse_withoutAccessToken_withBetaOverrideFalse {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"payWithVenmo": @{}}];
    [BTConfiguration enableVenmo:false];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertFalse(configuration.isVenmoEnabled);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsVenmoEnabledIsTrue_withoutAccessToken_withBetaOverrideTrue {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"payWithVenmo": @{}}];
    [BTConfiguration enableVenmo:true];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertFalse(configuration.isVenmoEnabled);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsPayPalEnabled_whenEnabled_returnsTrue {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"paypalEnabled": @(YES) }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);

        XCTAssertTrue(configuration.isPayPalEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsPayPalEnabled_whenDisabled_returnsFalse {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"paypalEnabled": @(NO) }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);

        XCTAssertFalse(configuration.isPayPalEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsApplePayEnabled_whenEnabled_returnsTrue {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"applePay": @{ @"status": @"production" } }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);

        XCTAssertTrue(configuration.isApplePayEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testIsApplePayEnabled_whenDisabled_returnsFalse {
    BTAPIClient *apiClient = [self clientThatReturnsConfiguration:@{ @"applePay": @{ @"status": @"off" } }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertNil(error);

        XCTAssertFalse(configuration.isApplePayEnabled);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Analytics tests

- (void)testSendAnalyticsEvent_whenRemoteConfigurationHasNoAnalyticsURL_doesNotSendEvent {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    BTFakeHTTP *stubConfigurationHTTP = [BTFakeHTTP fakeHTTP];
    apiClient.http = stubConfigurationHTTP;
    BTFakeHTTP *mockAnalyticsHttp = [BTFakeHTTP fakeHTTP];
    apiClient.analyticsHttp = mockAnalyticsHttp;
    [stubConfigurationHTTP stubRequest:@"GET" toEndpoint:@"/client_api/v1/configuration" respondWith:@{} statusCode:200];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [apiClient sendAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertTrue(mockAnalyticsHttp.POSTRequestCount == 0);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testSendAnalyticsEvent_whenRemoteConfigurationHasAnalyticsURL_setsUpAnalyticsHTTPToUseBaseURL {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    BTFakeHTTP *stubConfigurationHTTP = [BTFakeHTTP fakeHTTP];
    apiClient.http = stubConfigurationHTTP;
    [stubConfigurationHTTP stubRequest:@"GET"
                            toEndpoint:@"/client_api/v1/configuration"
                           respondWith:@{
                                         @"analytics" : @{
                                                 @"url" : @"test://do-not-send.url"
                                                 } }
                            statusCode:200];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Uses analytics base URL"];
    [apiClient sendAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertEqualObjects(apiClient.analyticsHttp.baseURL.absoluteString, @"test://do-not-send.url");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testSendAnalyticsEvent_whenSuccessful_sendsAnalyticsEvent {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    apiClient = [apiClient copyWithSource:BTClientMetadataSourcePayPalBrowser integration:BTClientMetadataIntegrationCustom];
    BTFakeHTTP *mockAnalyticsHTTP = [BTFakeHTTP fakeHTTP];
    BTFakeHTTP *stubConfigurationHTTP = [BTFakeHTTP fakeHTTP];
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
    [apiClient sendAnalyticsEvent:@"an.analytics.event" completion:^(NSError *error) {
        XCTAssertNil(error);
        
        XCTAssertEqual(metadata.source, BTClientMetadataSourcePayPalBrowser);
        XCTAssertEqual(metadata.integration, BTClientMetadataIntegrationCustom);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestEndpoint, @"/");
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"kind"], @"an.analytics.event");
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"_meta"][@"integration"], metadata.integrationString);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"_meta"][@"source"], metadata.sourceString);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"_meta"][@"sessionId"], metadata.sessionId);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPOST_usesMetadataSourceAndIntegration {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    apiClient = [apiClient copyWithSource:BTClientMetadataSourcePayPalApp integration:BTClientMetadataIntegrationDropIn];
    BTFakeHTTP *mockHTTP = [BTFakeHTTP fakeHTTP];
    BTFakeHTTP *stubAnalyticsHTTP = [BTFakeHTTP fakeHTTP];
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
        XCTAssertNotNil(body);
        XCTAssertNotNil(response);
        XCTAssertNil(error);

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
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    BTFakeHTTP *fake = [BTFakeHTTP fakeHTTP];
    fake.cannedResponse = [[BTJSON alloc] initWithValue:configurationDictionary];
    fake.cannedStatusCode = 200;
    apiClient.http = fake;

    return apiClient;
}

@end
