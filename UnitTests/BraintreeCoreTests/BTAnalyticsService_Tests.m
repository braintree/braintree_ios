#import "BTAnalyticsService.h"
#import "Braintree-Version.h"
@import BraintreeCore;
@import BraintreeTestShared;
@import BraintreeCoreSwift;
@import XCTest;
#import <sys/sysctl.h>
#import <sys/utsname.h>

@interface BTAnalyticsService_Tests : XCTestCase

@property (nonatomic, assign) uint64_t currentTime;
@property (nonatomic, assign) uint64_t oneSecondLater;

@end

@implementation BTAnalyticsService_Tests

#pragma mark - Analytics tests

- (void)setUp {
    [super setUp];
    self.currentTime = (uint64_t)([[NSDate date] timeIntervalSince1970] * 1000);
    self.oneSecondLater = (uint64_t)(([[NSDate date] timeIntervalSince1970] * 1000) + 999);
}

- (void)testSendAnalyticsEvent_whenRemoteConfigurationHasNoAnalyticsURL_returnsError {
    MockAPIClient *stubAPIClient = [self stubbedAPIClientWithAnalyticsURL:nil];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [analyticsService sendAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertEqual(error.domain, BTAnalyticsServiceErrorDomain);
        XCTAssertEqual(error.code, (NSInteger)BTAnalyticsServiceErrorTypeMissingAnalyticsURL);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testSendAnalyticsEvent_whenRemoteConfigurationHasAnalyticsURL_setsUpAnalyticsHTTPToUseBaseURL {
    MockAPIClient *stubAPIClient = [self stubbedAPIClientWithAnalyticsURL:@"test://do-not-send.url"];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [analyticsService sendAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertEqualObjects(analyticsService.http.baseURL.absoluteString, @"test://do-not-send.url");
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testSendAnalyticsEvent_whenNumberOfQueuedEventsMeetsThreshold_sendsAnalyticsEvent {
    MockAPIClient *stubAPIClient = [self stubbedAPIClientWithAnalyticsURL:@"test://do-not-send.url"];
    FakeHTTP *mockAnalyticsHTTP = [FakeHTTP fakeHTTP];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];
    analyticsService.flushThreshold = 1;
    analyticsService.http = mockAnalyticsHTTP;

    [analyticsService sendAnalyticsEvent:@"an.analytics.event"];
    // Pause briefly to allow analytics service to dispatch async blocks
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestEndpoint, @"/");
    XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"kind"], @"an.analytics.event");
    XCTAssertGreaterThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"timestamp"] unsignedIntegerValue], self.currentTime);
    XCTAssertLessThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"timestamp"] unsignedIntegerValue], self.oneSecondLater);

    [self validateMetaParameters:mockAnalyticsHTTP.lastRequestParameters[@"_meta"]];
}

- (void)testSendAnalyticsEvent_whenFlushThresholdIsGreaterThanNumberOfBatchedEvents_doesNotSendAnalyticsEvent {
    MockAPIClient *stubAPIClient = [self stubbedAPIClientWithAnalyticsURL:@"test://do-not-send.url"];
    FakeHTTP *mockAnalyticsHTTP = [FakeHTTP fakeHTTP];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];
    analyticsService.flushThreshold = 2;
    analyticsService.http = mockAnalyticsHTTP;
    
    [analyticsService sendAnalyticsEvent:@"an.analytics.event"];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    XCTAssertTrue(mockAnalyticsHTTP.POSTRequestCount == 0);
}

- (void)testSendAnalyticsEventCompletion_whenCalled_sendsAllEvents {
    MockAPIClient *stubAPIClient = [self stubbedAPIClientWithAnalyticsURL:@"test://do-not-send.url"];
    FakeHTTP *mockAnalyticsHTTP = [FakeHTTP fakeHTTP];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];
    analyticsService.flushThreshold = 5;
    analyticsService.http = mockAnalyticsHTTP;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends batched request"];
    [analyticsService sendAnalyticsEvent:@"an.analytics.event"];
    [analyticsService sendAnalyticsEvent:@"another.analytics.event" completion:^(NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(mockAnalyticsHTTP.POSTRequestCount == 1);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestEndpoint, @"/");
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"kind"], @"an.analytics.event");
        XCTAssertGreaterThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"timestamp"] unsignedIntegerValue], self.currentTime);
        XCTAssertLessThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"timestamp"] unsignedIntegerValue], self.oneSecondLater);

        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"][1][@"kind"], @"another.analytics.event");
        XCTAssertGreaterThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][1][@"timestamp"] unsignedIntegerValue], self.currentTime);
        XCTAssertLessThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][1][@"timestamp"] unsignedIntegerValue], self.oneSecondLater);

        [self validateMetaParameters:mockAnalyticsHTTP.lastRequestParameters[@"_meta"]];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testFlush_whenCalled_sendsAllQueuedEvents {
    MockAPIClient *stubAPIClient = [self stubbedAPIClientWithAnalyticsURL:@"test://do-not-send.url"];
    FakeHTTP *mockAnalyticsHTTP = [FakeHTTP fakeHTTP];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];
    analyticsService.flushThreshold = 5;
    analyticsService.http = mockAnalyticsHTTP;
    
    [analyticsService sendAnalyticsEvent:@"an.analytics.event"];
    [analyticsService sendAnalyticsEvent:@"another.analytics.event"];
    // Pause briefly to allow analytics service to dispatch async blocks
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends batched request"];
    [analyticsService flush:^(NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(mockAnalyticsHTTP.POSTRequestCount == 1);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestEndpoint, @"/");
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"kind"], @"an.analytics.event");
        XCTAssertGreaterThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"timestamp"] unsignedIntegerValue], self.currentTime);
        XCTAssertLessThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"timestamp"] unsignedIntegerValue], self.oneSecondLater);

        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"][1][@"kind"], @"another.analytics.event");
        XCTAssertGreaterThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][1][@"timestamp"] unsignedIntegerValue], self.currentTime);
        XCTAssertLessThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][1][@"timestamp"] unsignedIntegerValue], self.oneSecondLater);
        [self validateMetaParameters:mockAnalyticsHTTP.lastRequestParameters[@"_meta"]];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testFlush_whenThereAreNoQueuedEvents_doesNotPOST {
    MockAPIClient *stubAPIClient = [self stubbedAPIClientWithAnalyticsURL:@"test://do-not-send.url"];
    FakeHTTP *mockAnalyticsHTTP = [FakeHTTP fakeHTTP];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];
    analyticsService.flushThreshold = 5;
    analyticsService.http = mockAnalyticsHTTP;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends batched request"];
    [analyticsService flush:^(NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(mockAnalyticsHTTP.POSTRequestCount == 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testAnalyticsService_whenAPIClientConfigurationFails_returnsError {
    MockAPIClient *stubAPIClient = [self stubbedAPIClientWithAnalyticsURL:@"test://do-not-send.url"];
    NSError *stubbedError = [NSError errorWithDomain:@"SomeError" code:1 userInfo:nil];
    stubAPIClient.cannedConfigurationResponseError = stubbedError;
    FakeHTTP *mockAnalyticsHTTP = [FakeHTTP fakeHTTP];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];
    analyticsService.http = mockAnalyticsHTTP;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked with error"];
    [analyticsService sendAnalyticsEvent:@"an.analytics.event" completion:^(NSError *error) {
        XCTAssertEqualObjects(error, stubbedError);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
    
    expectation = [self expectationWithDescription:@"Callback invoked with error"];
    [analyticsService flush:^(NSError *error) {
        XCTAssertEqualObjects(error, stubbedError);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testAnalyticsService_afterConfigurationError_maintainsQueuedEventsUntilConfigurationIsSuccessful {
    MockAPIClient *stubAPIClient = [self stubbedAPIClientWithAnalyticsURL:@"test://do-not-send.url"];
    NSError *stubbedError = [NSError errorWithDomain:@"SomeError" code:1 userInfo:nil];
    stubAPIClient.cannedConfigurationResponseError = stubbedError;
    FakeHTTP *mockAnalyticsHTTP = [FakeHTTP fakeHTTP];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];
    analyticsService.http = mockAnalyticsHTTP;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Callback invoked with error"];
    [analyticsService sendAnalyticsEvent:@"an.analytics.event.1" completion:^(NSError *error) {
        XCTAssertEqualObjects(error, stubbedError);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
    
    stubAPIClient.cannedConfigurationResponseError = nil;
    
    expectation = [self expectationWithDescription:@"Callback invoked with error"];
    [analyticsService sendAnalyticsEvent:@"an.analytics.event.2" completion:^(NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(mockAnalyticsHTTP.POSTRequestCount == 1);
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestEndpoint, @"/");
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"kind"], @"an.analytics.event.1");
        XCTAssertGreaterThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"timestamp"] unsignedIntegerValue], self.currentTime);
        XCTAssertLessThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"timestamp"] unsignedIntegerValue], self.oneSecondLater);
        
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"][1][@"kind"], @"an.analytics.event.2");
        XCTAssertGreaterThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][1][@"timestamp"] unsignedIntegerValue], self.currentTime);
        XCTAssertLessThanOrEqual([mockAnalyticsHTTP.lastRequestParameters[@"analytics"][1][@"timestamp"] unsignedIntegerValue], self.oneSecondLater);

        [self validateMetaParameters:mockAnalyticsHTTP.lastRequestParameters[@"_meta"]];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - Helpers

- (MockAPIClient *)stubbedAPIClientWithAnalyticsURL:(NSString *)analyticsURL {
    MockAPIClient *stubAPIClient = [[MockAPIClient alloc] initWithAuthorization:@"development_tokenization_key" sendAnalyticsEvent:NO];
    if (analyticsURL) {
         stubAPIClient.cannedConfigurationResponseBody = [[BTJSON alloc] initWithValue:@{ @"analytics" : @{ @"url" : analyticsURL } }];
    } else {
        stubAPIClient.cannedConfigurationResponseBody = [[BTJSON alloc] initWithValue:@{}];
    }
    return stubAPIClient;
}

- (void)validateMetaParameters:(NSDictionary *)metaParameters {
    XCTAssertEqualObjects(metaParameters[@"deviceManufacturer"], @"Apple");
    XCTAssertEqualObjects(metaParameters[@"deviceModel"], [self deviceModel]);
    XCTAssertEqualObjects(metaParameters[@"deviceAppGeneratedPersistentUuid"], [self deviceAppGeneratedPersistentUuid]);
    XCTAssertEqualObjects(metaParameters[@"deviceScreenOrientation"], @"Unknown");
    XCTAssertEqualObjects(metaParameters[@"integrationType"], @"custom");
    XCTAssertEqualObjects(metaParameters[@"iosBaseSDK"], @(__IPHONE_OS_VERSION_MAX_ALLOWED).stringValue);
    XCTAssertEqualObjects(metaParameters[@"iosDeviceName"], UIDevice.currentDevice.name);
    XCTAssertTrue((BOOL)metaParameters[@"isSimulator"] == TARGET_IPHONE_SIMULATOR);
    XCTAssertEqualObjects(metaParameters[@"merchantAppId"], @"com.apple.dt.xctest.tool");
    XCTAssertEqualObjects(metaParameters[@"merchantAppName"], @"xctest");
    XCTAssertEqualObjects(metaParameters[@"sdkVersion"], BRAINTREE_VERSION);
    XCTAssertEqualObjects(metaParameters[@"platform"], @"iOS");
    XCTAssertEqualObjects(metaParameters[@"platformVersion"], UIDevice.currentDevice.systemVersion);
    XCTAssertNotNil(metaParameters[@"sessionId"]);
    XCTAssertEqualObjects(metaParameters[@"source"], @"unknown");
    XCTAssertTrue([metaParameters[@"venmoInstalled"] isKindOfClass:[NSNumber class]]);
}

// Ripped from BTAnalyticsMetadata
- (NSString *)deviceModel {
    struct utsname systemInfo;

    uname(&systemInfo);

    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    return code;
}

// Ripped from BTAnalyticsMetadata
- (NSString *)deviceAppGeneratedPersistentUuid {
    @try {
        static NSString *deviceAppGeneratedPersistentUuidKeychainKey = @"deviceAppGeneratedPersistentUuid";
        NSString *savedIdentifier = [BTKeychain stringForKey:deviceAppGeneratedPersistentUuidKeychainKey];
        if (savedIdentifier.length == 0) {
            savedIdentifier = [[NSUUID UUID] UUIDString];
            BOOL setDidSucceed = [BTKeychain setString:savedIdentifier
                                                forKey:deviceAppGeneratedPersistentUuidKeychainKey];
            if (!setDidSucceed) {
                return nil;
            }
        }
        return savedIdentifier;
    } @catch (NSException *exception) {
        return nil;
    }
}

@end
