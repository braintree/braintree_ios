#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <XCTest/XCTest.h>

@interface BTAPIClient_IntegrationTests : XCTestCase
@end

@implementation BTAPIClient_IntegrationTests {
    BTAPIClient *client;
}

- (void)setUp {
    [super setUp];
    client = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
}

- (void)testFetchConfiguration_returnsTheConfiguration {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [client fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertEqualObjects(configuration.json[@"merchantId"].asString, @"integration_merchant_id");
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testPostAnalytics_whenCalled_isSuccessful {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Post analytics event"];

    // Analytics require an authorization fingerprint, needs support for client key
    NSString *event = @"hello world! 🐴";
    [client sendAnalyticsEvent:event completion:^(NSError *error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

// Testing that analytics "is successful but does not send the event when analytics URL is omitted from the client token"
// is covered by the unit test:
//   testSendAnalyticsEvent_whenRemoteConfigurationHasNoAnalyticsURL_doesNotSendEvent

@end
