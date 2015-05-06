#import <Braintree/BTClient.h>

#import "BTClientSpecHelper.h"
#import "BTTestClientTokenFactory.h"
#import "BTClient_Internal.h"

@implementation BTClientSpecHelper

+ (BTClient *)asyncClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides {
    NSString *clientToken = [BTTestClientTokenFactory tokenWithVersion:2 overrides:overrides];
    XCTestExpectation *expectation = [testCase expectationWithDescription:@"Setup client"];
    __block BTClient *returnedClient;
    [BTClient setupWithClientToken:clientToken completion:^(BTClient *client, NSError *error) {
        NSAssert(client != nil && error == nil, @"setupWithClientToken:completion: should succeed");
        returnedClient = client;
        [expectation fulfill];
    }];

    [testCase waitForExpectationsWithTimeout:10 handler:nil];
    return returnedClient;
}

+ (BTClient *)deprecatedClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides {
    NSString *clientToken = [BTTestClientTokenFactory tokenWithVersion:2 overrides:overrides];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BTClient *client = [[BTClient alloc] initWithClientToken:clientToken];
#pragma clang diagnostic pop
    NSAssert(client != nil, @"initWithClientToken: should succeed");
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
