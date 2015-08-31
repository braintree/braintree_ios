#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <XCTest/XCTest.h>

typedef NS_ENUM(NSInteger, BTTestMode_t) {
    BTTestModeDebug = 1,
    BTTestModeRelease = 2
};

extern BTTestMode_t BTTestMode;

void wait_for_potential_async_exceptions(void (^done)(void));

BOOL isANonce(NSString *nonce);
