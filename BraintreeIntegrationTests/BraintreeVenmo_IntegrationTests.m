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
    return @YES;
}

- (void)openURL:(NSURL *)url {
    self.openedURL = url;
}

@end

@interface BraintreeVenmo_IntegrationTests : XCTestCase
@property (nonatomic, strong) NSNumber *didReceiveCompletionCallback;
@end

@implementation BraintreeVenmo_IntegrationTests

- (void)testTokenizeVenmoCard_whenVenmoEnabledInControlPanel_opensVenmoApp {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTVenmoDriver *venmoDriver = [[BTVenmoDriver alloc] initWithAPIClient:apiClient];
    FakeApplication *mockApplication = [[FakeApplication alloc] init];
    venmoDriver.application = mockApplication;

    [venmoDriver tokenizeVenmoCardWithCompletion:^(__unused BTVenmoTokenizedCard * _Nullable tokenizedCard, __unused NSError * _Nullable error) { }];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"openedURL != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:mockApplication handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];

    XCTAssertEqualObjects(mockApplication.openedURL.scheme, @"com.venmo.touch.v1");
}

- (void)testTokenizeVenmoCard_whenVenmoEnabledInControlPanelAndUsingClientKey_returnsANonce {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    BTVenmoDriver *venmoDriver = [[BTVenmoDriver alloc] initWithAPIClient:apiClient];
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo";
    FakeApplication *mockApplication = [[FakeApplication alloc] init];
    venmoDriver.application = mockApplication;

    _didReceiveCompletionCallback = nil;
    [venmoDriver tokenizeVenmoCardWithCompletion:^(BTVenmoTokenizedCard * _Nullable tokenizedCard, NSError * _Nullable error) {
        XCTAssertTrue(tokenizedCard.paymentMethodNonce.isANonce);
        XCTAssertEqualObjects(tokenizedCard.localizedDescription, @"Card from Venmo");
        XCTAssertNil(error);

        _didReceiveCompletionCallback = @YES;
    }];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"openedURL != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:mockApplication handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];

    [BTVenmoDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"com.integration.test://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=00000000-0000-0000-0000-000000000012"]];

    XCTAssertEqualObjects(mockApplication.openedURL.scheme, @"com.venmo.touch.v1");
    XCTAssertEqualObjects(mockApplication.openedURL.host, @"x-callback-url");
    XCTAssertEqualObjects(mockApplication.openedURL.path, @"/vzero/auth");
    NSDictionary *queryParamsDictionary = [BTURLUtils dictionaryForQueryString:mockApplication.openedURL.query];
    NSDictionary *expectedQueryParams = @{@"x-cancel": @"com.braintreepayments.Demo://x-callback-url/vzero/auth/venmo/cancel",
                                          @"x-error": @"com.braintreepayments.Demo://x-callback-url/vzero/auth/venmo/error",
                                          @"braintree_merchant_id": @"integration_merchant_id",
                                          @"x-source": @"Braintree Demo",
                                          @"x-success": @"com.braintreepayments.Demo://x-callback-url/vzero/auth/venmo/success"
                                          };
    XCTAssertEqualObjects(queryParamsDictionary, expectedQueryParams);
    predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

// TODO: Will work when JWT is implemented
- (void)pendTokenizeVenmoCard_whenVenmoEnabledInControlPanelAndUsingJWT_returnsACard {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
    apiClient.clientJWT = @"TODO";
    [BTAppSwitch sharedInstance].returnURLScheme = @"com.braintreepayments.Demo";
    BTVenmoDriver *venmoDriver = [[BTVenmoDriver alloc] initWithAPIClient:apiClient];
    FakeApplication *mockApplication = [[FakeApplication alloc] init];
    venmoDriver.application = mockApplication;

    _didReceiveCompletionCallback = nil;
    [venmoDriver tokenizeVenmoCardWithCompletion:^(BTVenmoTokenizedCard *tokenizedCard, NSError *error) {
        XCTAssertTrue(tokenizedCard.paymentMethodNonce.isANonce);
        XCTAssertEqualObjects(tokenizedCard.localizedDescription, @"Card from Venmo");
        XCTAssertEqualObjects(tokenizedCard.lastTwo, @"Card from Venmo");
//        XCTAssertEqualObjects(tokenizedCard.cardNetwork, @"Card from Venmo");
        XCTAssertNil(error);

        _didReceiveCompletionCallback = @YES;
    }];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"openedURL != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:mockApplication handler:nil];
    [self waitForExpectationsWithTimeout:3 handler:nil];

    [BTVenmoDriver handleAppSwitchReturnURL:[NSURL URLWithString:@"com.integration.test://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=00000000-0000-0000-0000-000000000012"]];

    XCTAssertEqualObjects(mockApplication.openedURL.scheme, @"com.venmo.touch.v1");
    XCTAssertEqualObjects(mockApplication.openedURL.host, @"x-callback-url");
    XCTAssertEqualObjects(mockApplication.openedURL.path, @"/vzero/auth");
    NSDictionary *queryParamsDictionary = [BTURLUtils dictionaryForQueryString:mockApplication.openedURL.query];
    NSDictionary *expectedQueryParams = @{@"x-cancel": @"com.braintreepayments.Demo://x-callback-url/vzero/auth/venmo/cancel",
                                          @"x-error": @"com.braintreepayments.Demo://x-callback-url/vzero/auth/venmo/error",
                                          @"braintree_merchant_id": @"integration_merchant_id",
                                          @"x-source": @"Braintree Demo",
                                          @"x-success": @"com.braintreepayments.Demo://x-callback-url/vzero/auth/venmo/success"
                                          };
    XCTAssertEqualObjects(queryParamsDictionary, expectedQueryParams);

    predicate = [NSPredicate predicateWithFormat:@"didReceiveCompletionCallback != nil"];
    [self expectationForPredicate:predicate evaluatedWithObject:self handler:nil];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testTokenizeVenmoCard_whenVenmoDisabledInControlPanel_returnsANonce {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration2_merchant_id"];
    BTVenmoDriver *venmoDriver = [[BTVenmoDriver alloc] initWithAPIClient:apiClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize Venmo card"];
    [venmoDriver tokenizeVenmoCardWithCompletion:^(BTVenmoTokenizedCard * _Nullable tokenizedCard, NSError * _Nullable error) {
        XCTAssertEqualObjects(error.domain, BTVenmoDriverErrorDomain);
        XCTAssertEqual(error.code, BTVenmoDriverErrorTypeDisabled);
        XCTAssertNil(tokenizedCard);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
