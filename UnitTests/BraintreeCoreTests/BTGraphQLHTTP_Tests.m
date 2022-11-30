#import "BraintreeCoreTests-Swift.h"
@import BraintreeCore;
@import Specta;
@import Expecta;
@import OHHTTPStubs;
@import BraintreeCore;

@interface BTGraphQLHTTPTests : XCTestCase
@end

@implementation BTGraphQLHTTPTests {
    BTGraphQLHTTP *http;
}

- (void)setUp {
    [super setUp];

    http = [[BTGraphQLHTTP alloc] initWithBaseURL:[BTHTTPTestProtocol testBaseURL] authorizationFingerprint:@"test-authorization-fingerprint"];
}

- (void)tearDown {
    [HTTPStubs removeAllStubs];
    [super tearDown];
}

- (NSURLSession *)fakeSession {
    NSURLSessionConfiguration *testConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [testConfiguration setProtocolClasses:@[[BTHTTPTestProtocol class]]];
    return [NSURLSession sessionWithConfiguration:testConfiguration];
}

#pragma mark - Unsupported requests

- (void)testGETRequests_areUnsupported {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];

    @try {
        [http GET:@"" completion:^(__unused BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, __unused NSError * _Nullable error) {
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"GET is unsupported");
        [expectation fulfill];
    }

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testPUTRequests_areUnsupported {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];

    @try {
        [http PUT:@"" completion:^(__unused BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, __unused NSError * _Nullable error) {
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"PUT is unsupported");
        [expectation fulfill];
    }

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testDELETERequests_areUnsupported {
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET callback"];

    @try {
        [http DELETE:@"" completion:^(__unused BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, __unused NSError * _Nullable error) {
        }];
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"DELETE is unsupported");
        [expectation fulfill];
    }

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
