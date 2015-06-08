#import "BTClient+Testing.h"
#import "BTCoinbaseAcceptanceSpecViewController.h"

SpecBegin(BTCoinbaseAcceptance)

beforeAll(^{
    XCTestExpectation *updateCoinbaseMerchantOptionsExpectation = [self expectationWithDescription:@"update merchant options for coinbase"];
    [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                             BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                             BTClientTestConfigurationKeyCustomer:@YES,
                                             BTClientTestConfigurationKeyClientTokenVersion: @2 }
                                    async:YES
                               completion:^(BTClient *client) {
                                   [client updateCoinbaseMerchantOptions:@{ @"enabled": @YES }
                                                                 success:^{
                                                                     [updateCoinbaseMerchantOptionsExpectation fulfill];
                                                                 }
                                                                 failure:^(NSError *error) {
                                                                     XCTFail(@"Should not call failure block of updateCoinbaseMerchantOptions:success:failure:");
                                                                 }];
                               }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
});

afterAll(^{
    XCTestExpectation *updateCoinbaseMerchantOptionsExpectation = [self expectationWithDescription:@"update merchant options for coinbase"];
    [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                             BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                             BTClientTestConfigurationKeyCustomer:@YES,
                                             BTClientTestConfigurationKeyClientTokenVersion: @2 }
                                    async:YES
                               completion:^(BTClient *client) {
                                   [client updateCoinbaseMerchantOptions:@{ @"enabled": @NO }
                                                                 success:^{
                                                                     [updateCoinbaseMerchantOptionsExpectation fulfill];
                                                                 }
                                                                 failure:^(NSError *error) {
                                                                     XCTFail(@"Should not call failure block of updateCoinbaseMerchantOptions:success:failure:");
                                                                 }];
                               }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
});

describe(@"Coinbase authorization", ^{
    beforeEach(^{
        BTCoinbaseAcceptanceSpecViewController *vc = [[BTCoinbaseAcceptanceSpecViewController alloc] init];
        [system presentViewController:vc
withinNavigationControllerWithNavigationBarClass:nil
                         toolbarClass:nil
                   configurationBlock:nil];
        [tester waitForTimeInterval:2]; // Wait for preparePayPalMobile to finish
        [tester waitForViewWithAccessibilityLabel:vc.title];
    });

    it(@"authorizes the user in the coinbase app and returns a nonce when the app is available", ^{
        [system waitForApplicationToOpenURLWithScheme:BTCoinbaseAcceptanceSpecCoinbaseScheme
                                  whileExecutingBlock:^{
                                      [tester tapViewWithAccessibilityLabel:@"Coinbase"];
                                  } returning:YES];

        // Simulate Response: Success
        NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/coinbase/redirect?code=fake-coinbase-auth-code"];
        [[UIApplication sharedApplication] openURL:returnURL];

        [tester waitForViewWithAccessibilityLabel:@"Got a ฿ nonce! satoshi@example.com"];
    });

    it(@"shows the error when the coinbase flow results in an error", ^{
        [system waitForApplicationToOpenURLWithScheme:BTCoinbaseAcceptanceSpecCoinbaseScheme
                                  whileExecutingBlock:^{
                                      [tester tapViewWithAccessibilityLabel:@"Coinbase"];
                                  } returning:YES];

        // Simulate Response: Error
        NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/coinbase/redirect?error=some_error&error_description=The+error."];
        [[UIApplication sharedApplication] openURL:returnURL];

        [tester waitForViewWithAccessibilityLabel:@"Failed with error. The error."];
    });

    it(@"distinguishes the canceled/denied flow from other errors flows", ^{
        [system waitForApplicationToOpenURLWithScheme:BTCoinbaseAcceptanceSpecCoinbaseScheme
                                  whileExecutingBlock:^{
                                      [tester tapViewWithAccessibilityLabel:@"Coinbase"];
                                  } returning:YES];

        // Simulate Response: Error
        NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/coinbase/redirect?error=access_denied&error_description=The+resource+owner+or+authorization+server+denied+the+request."];
        [[UIApplication sharedApplication] openURL:returnURL];

        [tester waitForViewWithAccessibilityLabel:@"Canceled"];
    });

    it(@"authorizes the user in the browser and returns a nonce when the app is not available", ^{
        [system waitForApplicationToOpenURLWithScheme:@"https"
                                  whileExecutingBlock:^{
                                      // Inside of `executionBlock` to avoid unintended interactions with KIF's Swizzling
                                      OCMockObject *applicationPartialStub = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
                                      [[[applicationPartialStub expect] andReturnValue:@NO] canOpenURL:HC_hasProperty(@"scheme", BTCoinbaseAcceptanceSpecCoinbaseScheme)];

                                      [tester tapViewWithAccessibilityLabel:@"Coinbase"];

                                      [applicationPartialStub verify];
                                      [applicationPartialStub stopMocking];
                                  } returning:YES];

        // Simulate Response: Success
        NSURL *returnURL = [NSURL URLWithString:@"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/coinbase/redirect?code=fake-coinbase-auth-code"];
        [[UIApplication sharedApplication] openURL:returnURL];
        
        [tester waitForViewWithAccessibilityLabel:@"Got a ฿ nonce! satoshi@example.com"];
    });
});

SpecEnd
