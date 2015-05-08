#import "BTDropInViewController.h"
#import "BTClient+Testing.h"

#import "BTUIPaymentButtonCollectionViewCell.h"
#import "BTUICoinbaseButton.h"
#import "BTCoinbase.h"

SpecBegin(DropIn_Acceptance)

// IMPORTANT:
// When running the tests with Xcode, these values do not need
// to be set to nil/NO here; but with xcodebuild test, they do.
// The tests fail otherwise!
__block BTClient *testClient = nil;
__block BOOL testShouldEnableCoinbase = NO;
__block BOOL testShouldHaveCoinbaseAccountInVault = NO;
__block BOOL testShouldHaveCardInVault = NO;

afterEach(^{
    testClient = nil;
    testShouldEnableCoinbase = NO;
    testShouldHaveCoinbaseAccountInVault = NO;
    testShouldHaveCardInVault = NO;
});

describe(@"Drop In view controller", ^{
    beforeEach(^{
        XCTestExpectation *initializeClientExpectation = [self expectationWithDescription:@"initialize client"];
        [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                 BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                 BTClientTestConfigurationKeyCustomer:@YES,
                                                 BTClientTestConfigurationKeyClientTokenVersion: @2 }
                                        async:YES
                                   completion:^(BTClient *client) {
                                       testClient = client;
                                       [initializeClientExpectation fulfill];
                                   }];
        [self waitForExpectationsWithTimeout:10 handler:nil];

        if (testShouldEnableCoinbase) {
            XCTestExpectation *updateCoinbaseMerchantOptionsExpectation = [self expectationWithDescription:@"update merchant options for coinbase"];
            [testClient updateCoinbaseMerchantOptions:@{ @"enabled": @YES }
                                              success:^{
                                                  [updateCoinbaseMerchantOptionsExpectation fulfill];
                                              }
                                              failure:^(NSError *error) {
                                                  XCTFail(@"Should not call failure block of updateCoinbaseMerchantOptions:success:failure:");
                                              }];
            [self waitForExpectationsWithTimeout:10 handler:nil];

            // Reload client with new coinbase merchant options
            XCTestExpectation *reinitializeClientExpectation = [self expectationWithDescription:@"reinitialize client"];
            [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                     BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                     BTClientTestConfigurationKeyCustomer:@YES,
                                                     BTClientTestConfigurationKeyClientTokenVersion: @2 }
                                            async:YES
                                       completion:^(BTClient *client) {
                                           XCTAssertNotNil(client);
                                           testClient = client;
                                           [reinitializeClientExpectation fulfill];
                                       }];
            [self waitForExpectationsWithTimeout:10 handler:nil];
        }

        if (testShouldHaveCoinbaseAccountInVault) {
            XCTestExpectation *expectation = [self expectationWithDescription:@"store coinbase account"];
            [testClient saveCoinbaseAccount:@{ @"code": @"some-fake-code" }
                               storeInVault:YES
                                    success:^(BTCoinbasePaymentMethod *coinbasePaymentMethod) {
                                        [expectation fulfill];
                                    } failure:^(NSError *error) {
                                        XCTFail(@"Should not call failure block of saveCoinbaseAccount:success:failure:");
                                    }];
            [self waitForExpectationsWithTimeout:10 handler:nil];
        }

        if (testShouldHaveCardInVault) {
            BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
            r.number = @"4111111111111111";
            r.expirationDate = @"12/38";
            r.shouldValidate = YES;
            XCTestExpectation *saveCardExpectation = [self expectationWithDescription:@"Save card in vault"];
            [testClient saveCardWithRequest:r
                                    success:^(BTCardPaymentMethod *card) {
                                        [saveCardExpectation fulfill];
                                    } failure:^(NSError *error) {
                                        XCTFail(@"Should not receive failure block of saveCardWithRequest:success:failure:");
                                    }];
            [self waitForExpectationsWithTimeout:10 handler:nil];
        }

        BTDropInViewController *testDropInVC = [[BTDropInViewController alloc] initWithClient:testClient];
        [testDropInVC fetchPaymentMethods];
        [system presentViewController:testDropInVC withinNavigationControllerWithNavigationBarClass:nil toolbarClass:nil configurationBlock:nil];
    });

    afterEach(^{
        if (testShouldEnableCoinbase) {
            XCTestExpectation *disableCoinbaseMerchantOptionsExpectation = [self expectationWithDescription:@"disable coinbase in merchant options"];
            [testClient updateCoinbaseMerchantOptions:@{ @"enabled": @NO }
                                              success:^{
                                                  [disableCoinbaseMerchantOptionsExpectation fulfill];
                                              } failure:^(NSError *error) {
                                                  XCTFail(@"Should not call failure block of updateCoinbaseMerchantOptions:success:failure:");
                                              }];
            [self waitForExpectationsWithTimeout:10 handler:nil];
        }
    });

    describe(@"payment methods on file", ^{
        xit(@"presents the default at first", ^{
        });

        describe(@"tapping 'CHANGE PAYMENT METHOD'", ^{
            xit(@"presents the full list of vaulted payment methods", ^{
            });
        });
    });

    describe(@"coinbase", ^{
        beforeAll(^{
            testShouldEnableCoinbase = YES;
        });

        it(@"presents the newly vaulted coinbase account", ^{
            [tester waitForViewWithAccessibilityLabel:@"Coinbase"];
            BTUIPaymentButtonCollectionViewCell *coinbaseButtonCollectionViewCell = (BTUIPaymentButtonCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] inCollectionViewWithAccessibilityIdentifier:@"Payment Options"];
            expect([coinbaseButtonCollectionViewCell paymentButton]).to.beKindOf([BTUICoinbaseButton class]);

            [system waitForApplicationToOpenURLWithScheme:@"com.coinbase.oauth-authorize"
                                      whileExecutingBlock:^{
                                          [tester tapItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] inCollectionViewWithAccessibilityIdentifier:@"Payment Options"];
                                      } returning:YES];

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"com.braintreepayments.Braintree-Demo.payments://x-callback-url/vzero/auth/coinbase/redirect?code=some-coinbase-auth-code"]];
            [tester waitForViewWithAccessibilityLabel:@"Coinbase"];
            [tester waitForViewWithAccessibilityLabel:@"satoshi@example.com"];
            [tester waitForTappableViewWithAccessibilityLabel:@"Change payment method"];
            [tester waitForTappableViewWithAccessibilityLabel:@"Pay"];
        });

        describe(@"with payment methods on file", ^{
            beforeAll(^{
                testShouldEnableCoinbase = YES;
                testShouldHaveCoinbaseAccountInVault = YES;
            });

            it(@"presents a vaulted coinbase account when one is on file", ^{
                [tester waitForViewWithAccessibilityLabel:@"Coinbase"];
                [tester waitForViewWithAccessibilityLabel:@"satoshi@example.com"];
                [tester waitForTappableViewWithAccessibilityLabel:@"Change payment method"];
                [tester waitForTappableViewWithAccessibilityLabel:@"Pay"];
            });
        });
    });

    describe(@"multiple payment methods on file", ^{
        beforeAll(^{
            testShouldEnableCoinbase = YES;
            testShouldHaveCoinbaseAccountInVault = YES;
            testShouldHaveCardInVault = YES;
        });

        it(@"should allow the user to switch to a different payment method", ^{
            [tester waitForViewWithAccessibilityLabel:@"Visa"];

            [tester tapViewWithAccessibilityLabel:@"Change payment method"];

            [tester waitForViewWithAccessibilityLabel:@"Visa ending in 11"];

            [tester waitForViewWithAccessibilityLabel:@"Coinbase satoshi@example.com"];

            [tester tapViewWithAccessibilityLabel:@"Coinbase satoshi@example.com"];

            [tester waitForViewWithAccessibilityLabel:@"Change payment method"];
            [tester waitForViewWithAccessibilityLabel:@"Coinbase"];
            [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Visa"];
        });
    });
});

SpecEnd
