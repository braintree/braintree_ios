#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/BTURLUtils.h>
#import <BraintreeVenmo/BraintreeVenmo.h>
#import <BraintreeVenmo/BTVenmoDriver_Internal.h>
#import "BTIntegrationTestsHelper.h"
#import <XCTest/XCTest.h>

@interface FakeApplication : NSObject
@property (nonatomic, strong) NSURL *openedURL;
@end

@implementation FakeApplication

- (BOOL)canOpenURL:(__unused NSURL *)url {
    return YES;
}

- (void)openURL:(NSURL *)url {
    self.openedURL = url;
}

@end

@interface BraintreeVenmo_IntegrationTests : XCTestCase
@property (nonatomic, strong) NSNumber *didReceiveCompletionCallback;
@end

@implementation BraintreeVenmo_IntegrationTests

- (void)testTokenizeVenmoCard_whenVenmoDisabledInControlPanel_returnsANonce {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration2_merchant_id"];
    BTVenmoDriver *venmoDriver = [[BTVenmoDriver alloc] initWithAPIClient:apiClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize Venmo card"];
    [venmoDriver authorizeWithCompletion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        XCTAssertEqualObjects(error.domain, BTVenmoDriverErrorDomain);
        XCTAssertEqual(error.code, BTVenmoDriverErrorTypeDisabled);
        XCTAssertNil(tokenizedCard);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
