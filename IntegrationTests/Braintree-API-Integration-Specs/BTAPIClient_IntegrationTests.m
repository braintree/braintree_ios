#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <XCTest/XCTest.h>

@interface BTAPIClient_IntegrationTests : XCTestCase
@end

@implementation BTAPIClient_IntegrationTests

- (void)testFetchConfiguration_withTokenizationKey_returnsTheConfiguration {
    BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [client fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        XCTAssertEqualObjects([configuration.json[@"merchantId"] asString], @"dcpspy2brwdjr3qn");
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFetchConfiguration_withClientToken_returnsTheConfiguration {
    BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch configuration"];
    [client fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        // Note: client token uses a different merchant ID than the merchant whose tokenization key
        // we use in the other test
        XCTAssertEqualObjects([configuration.json[@"merchantId"] asString], @"348pk9cgf3bgyw2b");
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testSendAnalyticsEvent_withTokenizationKey_isSuccessful {
    [self validateSendAnalyticsEventWithAPIClient:[[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY]];
}

- (void)testSendAnalyticsEvent_withClientToken_isSuccessful {
    [self validateSendAnalyticsEventWithAPIClient:[[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN]];
}

#pragma mark - Helpers

- (void)validateSendAnalyticsEventWithAPIClient:(BTAPIClient *)apiClient {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Post analytics event"];

    // Analytics require an authorization fingerprint, needs support for tokenization key
    NSString *event = @"hello world! 🐴";
    [apiClient sendAnalyticsEvent:event completion:^(NSError *error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

// Testing that analytics "is successful but does not send the event when analytics URL is omitted from the client token"
// is covered by the unit test:
//   testSendAnalyticsEvent_whenRemoteConfigurationHasNoAnalyticsURL_doesNotSendEvent

@end
