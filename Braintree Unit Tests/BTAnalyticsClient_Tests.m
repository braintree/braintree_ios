#import <XCTest/XCTest.h>

#import "BTAnalyticsClient_Internal.h"
#import "BTAPIClient_Internal.h"
#import "BTJSON.h"

@interface MockAPIClient : BTAPIClient
@property (nonatomic, copy) NSString *lastPOSTPath;
@property (nonatomic, strong) NSDictionary *lastPOSTParameters;
@property (nonatomic, strong) BTJSON *cannedConfigurationResponseBody;
@property (nonatomic, strong) NSError *cannedConfigurationResponseError;
@property (nonatomic, strong) BTJSON *cannedResponseBody;
@property (nonatomic, strong) NSError *cannedResponseError;
@property (nonatomic, strong) NSHTTPURLResponse *cannedHTTPURLResponse;
@property (nonatomic, strong) BTClientMetadata *metadata;
@end

@implementation MockAPIClient

@synthesize metadata = _metadata;

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(BTJSON *, NSHTTPURLResponse *, NSError *))completionBlock {
    self.lastPOSTPath = path;
    self.lastPOSTParameters = parameters;
    completionBlock(self.cannedResponseBody, self.cannedHTTPURLResponse, self.cannedResponseError);
}

- (void)fetchOrReturnRemoteConfiguration:(nonnull void (^)(BTJSON * __nullable, NSError * __nullable))completionBlock {
    completionBlock(self.cannedConfigurationResponseBody, self.cannedConfigurationResponseError);
}



@end

@interface StubBTHTTP : BTHTTP
@end

@implementation StubBTHTTP

- (void)POST:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    completionBlock(nil, nil, nil);
}

@end

@interface MockBTHTTP : BTHTTP

@property (nonatomic, copy) NSString *lastPOSTPath;
@property (nonatomic, strong) NSDictionary *lastPOSTParameters;

@end

@implementation MockBTHTTP

- (void)POST:(NSString *)endpoint parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    self.lastPOSTPath = endpoint;
    self.lastPOSTParameters = parameters;
    completionBlock(nil, nil, nil);
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

@interface BTAnalyticsClient_Tests : XCTestCase

@end

@implementation BTAnalyticsClient_Tests {
    BTAnalyticsClient *analyticsClient;
    MockAPIClient *mockAPIClient;
}

- (void)setUp {
    [super setUp];

    mockAPIClient = [[MockAPIClient alloc] initWithClientKey:@"test_api_client" error:NULL];
    analyticsClient = [[BTAnalyticsClient alloc] initWithAPIClient:mockAPIClient];
}

- (void)testPostAnalyticsEvent_whenRemoteConfigurationHasNoAnalyticsURL_doesNotSendEvent {
    mockAPIClient.cannedConfigurationResponseBody = [[BTJSON alloc] init];
    analyticsClient.analyticsHttp = [[StubBTHTTP alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [analyticsClient postAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertTrue(mockAPIClient.lastPOSTPath.length == 0);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPostAnalyticsEvent_whenRemoteConfigurationHasAnalyticsURL_setsUpAnalyticsHTTPToUseBaseURL {
    mockAPIClient.cannedConfigurationResponseBody = [[BTJSON alloc] initWithValue:@{
                                                                                    @"analytics" : @{
                                                                                            @"url" : @"test://do-not-send.url"
                                                                                            } }];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Uses analytics base URL"];
    [analyticsClient postAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertEqualObjects(analyticsClient.analyticsHttp.baseURL.absoluteString, @"test://do-not-send.url");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPostAnalyticsEvent_whenSuccessful_sendsAnalyticsEvent {
    mockAPIClient.cannedConfigurationResponseBody = [[BTJSON alloc] initWithValue:@{
                                                                                    @"analytics" : @{
                                                                                            @"url" : @"https://test.url"
                                                                                            } }];
    StubBTClientMetadata *stubMetadata = [[StubBTClientMetadata alloc] init];
    stubMetadata.sessionId = @"SessionID";
    stubMetadata.source = BTClientMetadataSourceUnknown;
    stubMetadata.integration = BTClientMetadataIntegrationCustom;
    mockAPIClient.metadata = stubMetadata;
    MockBTHTTP *mockHTTP = [[MockBTHTTP alloc] init];
    analyticsClient.analyticsHttp = mockHTTP;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [analyticsClient postAnalyticsEvent:@"an.analytics.event" completion:^(NSError *error) {
        XCTAssertEqualObjects(mockHTTP.lastPOSTPath, @"/");
        XCTAssertEqualObjects(mockHTTP.lastPOSTParameters[@"analytics"], @[ @{ @"kind" : @"an.analytics.event" } ]);
        XCTAssertEqualObjects(mockHTTP.lastPOSTParameters[@"_meta"][@"integration"], @"custom");
        XCTAssertEqualObjects(mockHTTP.lastPOSTParameters[@"_meta"][@"source"], @"unknown");
        XCTAssertEqualObjects(mockHTTP.lastPOSTParameters[@"_meta"][@"sessionId"], @"SessionID");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
