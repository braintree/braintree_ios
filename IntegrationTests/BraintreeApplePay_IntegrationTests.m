#import <BraintreeApplePay/BraintreeApplePay.h>
#import "BTIntegrationTestsHelper.h"
#import <PassKit/PassKit.h>
#import <XCTest/XCTest.h>

@interface BraintreeApplePay_IntegrationTests : XCTestCase

@end

@implementation BraintreeApplePay_IntegrationTests

- (void)testTokenizeApplePayPayment_whenApplePayEnabledInControlPanel_returnsANonce {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration_merchant_id"];
    BTApplePayClient *client = [[BTApplePayClient alloc] initWithAPIClient:apiClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize Apple Pay payment"];
    [client tokenizeApplePayPayment:[[PKPayment alloc] init]
                         completion:^(BTTokenizedApplePayPayment * _Nullable tokenizedApplePayPayment, NSError * _Nullable error) {
        XCTAssertTrue(tokenizedApplePayPayment.paymentMethodNonce.isANonce);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testTokenizeApplePayPayment_whenApplePayDisabledInControlPanel_returnsError {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"development_testing_integration2_merchant_id"];
    BTApplePayClient *client = [[BTApplePayClient alloc] initWithAPIClient:apiClient];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize Apple Pay payment"];
    [client tokenizeApplePayPayment:[[PKPayment alloc] init]
                         completion:^(BTTokenizedApplePayPayment * _Nullable tokenizedApplePayPayment, NSError * _Nullable error) {
        XCTAssertEqualObjects(error.domain, BTApplePayErrorDomain);
        XCTAssertEqual(error.code, BTApplePayErrorTypeUnsupported);
        XCTAssertNil(tokenizedApplePayPayment);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
