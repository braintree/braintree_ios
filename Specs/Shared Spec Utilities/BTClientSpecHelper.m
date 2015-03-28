#import "BTClientSpecHelper.h"
#import <Braintree/BTClient.h>
#import "BTTestClientTokenFactory.h"

@implementation BTClientSpecHelper

+ (BTClient *)asyncClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides {
    NSString *clientToken = [BTTestClientTokenFactory tokenWithVersion:2 overrides:overrides];
    XCTestExpectation *expectation = [testCase expectationWithDescription:@"Setup client"];
    __block BTClient *client;
    [BTClient setupWithClientToken:clientToken completion:^(BTClient *_client, NSError *error) {
        client = _client;
        [expectation fulfill];
    }];

    [testCase waitForExpectationsWithTimeout:10 handler:nil];
    return client;
}

+ (BTClient *)deprecatedClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides {
    NSString *clientToken = [BTTestClientTokenFactory tokenWithVersion:2 overrides:overrides];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BTClient *client = [[BTClient alloc] initWithClientToken:clientToken];
#pragma clang diagnostic pop
    return client;
}

+ (BTClient *)clientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides async:(BOOL)async {
  if (async) {
    return [self asyncClientForTestCase:testCase withOverrides:overrides];
  } else {
    return [self deprecatedClientForTestCase:testCase withOverrides:overrides];
  }
}

@end
