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
    BTClient *client = [[BTClient alloc] initWithClientToken:clientToken];
    return client;
}

+ (NSArray *)clientsForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides {
    BTClient *deprecatedClient = [self deprecatedClientForTestCase:testCase withOverrides:overrides];
    BTClient *asyncClient = [self asyncClientForTestCase:testCase withOverrides:overrides];
    return @[deprecatedClient, asyncClient];
}

@end
