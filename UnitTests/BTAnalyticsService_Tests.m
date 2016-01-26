#import "BTAnalyticsMetadata.h"
#import "BTAnalyticsService.h"
#import "BTKeychain.h"
#import "Braintree-Version.h"
#import "BTFakeHTTP.h"
#import "UnitTests-Swift.h"
#import <XCTest/XCTest.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

@interface BTAnalyticsService_Tests : XCTestCase

@end

@implementation BTAnalyticsService_Tests

#pragma mark - Analytics tests

- (void)testSendAnalyticsEvent_whenRemoteConfigurationHasNoAnalyticsURL_doesNotSendEvent {
    MockAPIClient *stubAPIClient = [[MockAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    stubAPIClient.cannedConfigurationResponseBody = [[BTJSON alloc] initWithValue:@{
                                                                                    @"analytics" : @{
                                                                                            }
                                                                                    }];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [analyticsService sendAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testSendAnalyticsEvent_whenRemoteConfigurationHasAnalyticsURL_setsUpAnalyticsHTTPToUseBaseURL {
    MockAPIClient *stubAPIClient = [[MockAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    stubAPIClient.cannedConfigurationResponseBody = [[BTJSON alloc] initWithValue:@{
                                                                                    @"analytics" : @{
                                                                                            @"url" : @"test://do-not-send.url"
                                                                                            }
                                                                                    }];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [analyticsService sendAnalyticsEvent:@"any.analytics.event" completion:^(NSError *error) {
        XCTAssertEqualObjects(analyticsService.http.baseURL.absoluteString, @"test://do-not-send.url");
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testSendAnalyticsEvent_whenSuccessful_sendsAnalyticsEvent {
    MockAPIClient *stubAPIClient = [[MockAPIClient alloc] initWithAuthorization:@"development_tokenization_key"];
    stubAPIClient.cannedConfigurationResponseBody = [[BTJSON alloc] initWithValue:@{
                                                                                    @"analytics" : @{
                                                                                            @"url" : @"test://do-not-send.url"
                                                                                            }
                                                                                    }];
    BTFakeHTTP *mockAnalyticsHTTP = [BTFakeHTTP fakeHTTP];
    BTAnalyticsService *analyticsService = [[BTAnalyticsService alloc] initWithAPIClient:stubAPIClient];
    analyticsService.http = mockAnalyticsHTTP;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Sends analytics event"];
    [analyticsService sendAnalyticsEvent:@"an.analytics.event" completion:^(NSError *error) {
        XCTAssertNil(error);

        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestEndpoint, @"/");
        XCTAssertEqualObjects(mockAnalyticsHTTP.lastRequestParameters[@"analytics"][0][@"kind"], @"an.analytics.event");
        NSDictionary *_meta = mockAnalyticsHTTP.lastRequestParameters[@"_meta"];
        XCTAssertEqualObjects(_meta[@"deviceManufacturer"], @"Apple");
        XCTAssertEqualObjects(_meta[@"deviceModel"], [self deviceModel]);
        XCTAssertEqualObjects(_meta[@"deviceAppGeneratedPersistentUuid"], [self deviceAppGeneratedPersistentUuid]);
        XCTAssertEqualObjects(_meta[@"deviceScreenOrientation"], @"Portrait");
        XCTAssertEqualObjects(_meta[@"integration"], @"custom");
        XCTAssertEqualObjects(_meta[@"iosBaseSDK"], [@(__IPHONE_OS_VERSION_MAX_ALLOWED) stringValue]);
        XCTAssertEqualObjects(_meta[@"iosDeploymentTarget"], [@(__IPHONE_OS_VERSION_MIN_REQUIRED) stringValue]);
        XCTAssertEqualObjects(_meta[@"iosDeviceName"], [[UIDevice currentDevice] name]);
        XCTAssertTrue((BOOL)_meta[@"isSimulator"] == TARGET_IPHONE_SIMULATOR);
        XCTAssertEqualObjects(_meta[@"merchantAppId"], @"com.braintreepayments.Demo");
        XCTAssertEqualObjects(_meta[@"merchantAppName"], @"Braintree iOS SDK Demo");
        XCTAssertEqualObjects(_meta[@"merchantAppVersion"], BRAINTREE_VERSION);
        XCTAssertEqualObjects(_meta[@"sdkVersion"], BRAINTREE_VERSION);
        XCTAssertEqualObjects(_meta[@"platform"], @"iOS");
        XCTAssertEqualObjects(_meta[@"platformVersion"], [[UIDevice currentDevice] systemVersion]);
        XCTAssertNotNil(_meta[@"sessionId"]);
        XCTAssertEqualObjects(_meta[@"source"], @"unknown");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - Helpers

// Note: ripped from BTAnalyticsMetadata

- (NSString *)deviceModel {
    struct utsname systemInfo;

    uname(&systemInfo);

    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    return code;
}

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
