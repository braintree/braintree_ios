#import "BTAPIClient_Internal.h"
#import "BTPayPalDriver_Internal.h"
#import "BTNonceValidationHelper.h"
@import BraintreePayPal;
@import OCMock;
@import XCTest;

@interface BraintreePayPal_IntegrationTests : XCTestCase

@end

@implementation BraintreePayPal_IntegrationTests

NSString * const OneTouchCoreAppSwitchSuccessURLFixture = @"com.braintreepayments.Demo.payments://onetouch/v1/success?payload=eyJ2ZXJzaW9uIjoyLCJhY2NvdW50X2NvdW50cnkiOiJVUyIsInJlc3BvbnNlX3R5cGUiOiJjb2RlIiwiZW52aXJvbm1lbnQiOiJtb2NrIiwiZXhwaXJlc19pbiI6LTEsImRpc3BsYXlfbmFtZSI6Im1vY2tEaXNwbGF5TmFtZSIsInNjb3BlIjoiaHR0cHM6XC9cL3VyaS5wYXlwYWwuY29tXC9zZXJ2aWNlc1wvcGF5bWVudHNcL2Z1dHVyZXBheW1lbnRzIiwiZW1haWwiOiJtb2NrZW1haWxhZGRyZXNzQG1vY2suY29tIiwiYXV0aG9yaXphdGlvbl9jb2RlIjoibW9ja1RoaXJkUGFydHlBdXRob3JpemF0aW9uQ29kZSJ9&x-source=com.paypal.ppclient.touch.v1-or-v2";

#pragma mark - One-Time Payments (Checkout)

- (void)testOneTimePayment_withTokenizationKey_tokenizesPayPalAccount {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    [BTAppContextSwitcher sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";

    XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize one-time payment"];

    // Simulate SFAuthenicationSession completing
    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    [payPalDriver handleBrowserSwitchReturnURL:returnURL
                                   paymentType:BTPayPalPaymentTypeCheckout
                                    completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
        XCTAssertTrue(tokenizedPayPalAccount.nonce.isANonce);
        XCTAssertNil(error);
        [tokenizationExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testOneTimePayment_withClientToken_tokenizesPayPalAccount {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];

    [BTAppContextSwitcher sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";

    XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize one-time payment"];

    // Simulate SFAuthenicationSession completing
    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    [payPalDriver handleBrowserSwitchReturnURL:returnURL
                                   paymentType:BTPayPalPaymentTypeCheckout
                                    completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
        XCTAssertTrue(tokenizedPayPalAccount.nonce.isANonce);
        XCTAssertNil(error);
        [tokenizationExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - Billing Agreement (Vault)

- (void)testBillingAgreement_withTokenizationKey_tokenizesPayPalAccount {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_TOKENIZATION_KEY];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];

    [BTAppContextSwitcher sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";

    XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize billing agreement payment"];

    // Simulate SFAuthenicationSession completing
    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    [payPalDriver handleBrowserSwitchReturnURL:returnURL
                                   paymentType:BTPayPalPaymentTypeCheckout
                                    completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
        XCTAssertTrue(tokenizedPayPalAccount.nonce.isANonce);
        XCTAssertNil(error);
        [tokenizationExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testBillingAgreement_withClientToken_tokenizesPayPalAccount {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:SANDBOX_CLIENT_TOKEN];
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];

    [BTAppContextSwitcher sharedInstance].returnURLScheme = @"com.braintreepayments.Demo.payments";

    XCTestExpectation *tokenizationExpectation = [self expectationWithDescription:@"Tokenize billing agreement payment"];

    // Simulate SFAuthenicationSession completing
    NSURL *returnURL = [NSURL URLWithString:OneTouchCoreAppSwitchSuccessURLFixture];
    [payPalDriver handleBrowserSwitchReturnURL:returnURL
                                   paymentType:BTPayPalPaymentTypeCheckout
                                    completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
        XCTAssertTrue(tokenizedPayPalAccount.nonce.isANonce);
        XCTAssertNil(error);
        [tokenizationExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
