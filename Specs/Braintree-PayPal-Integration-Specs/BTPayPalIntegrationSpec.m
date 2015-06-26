#import "BTClient+BTPayPal.h"
#import "BTClient+Testing.h"
#import "BTClient+Offline.h"
#import "BTClientToken.h"
#import "PayPalMobile.h"
#import "BTPayPalViewController_Internal.h"
#import "BTErrors+BTPayPal.h"

SpecBegin(BTPayPal_Integration)


describe(@"preparePayPalMobile", ^{
    describe(@"online", ^{
        describe(@"with PayPal enabled", ^{
            __block BTClient *testClient;

            beforeEach(^{
                waitUntil(^(DoneCallback done){
                    [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier:@"altpay_merchant",
                                                             BTClientTestConfigurationKeyPublicKey:@"altpay_merchant_public_key",
                                                             BTClientTestConfigurationKeyCustomer:@YES }
                                               async:YES
                                               completion:^(BTClient *client) {
                                                   testClient = client;
                                                   done();
                                               }];
                });
            });

            it(@"configures BTClient for use with PayPal based on the client token configuration", ^{
                OCMockObject *mockPayPalMobile = [OCMockObject mockForClass:[PayPalMobile class]];

                // Assert that Braintree environment is added
                [[[mockPayPalMobile expect] classMethod] addEnvironments:[OCMArg checkWithBlock:^BOOL(NSDictionary *environments) {
                    return [environments count] == 1 && [NSURL URLWithString:environments[@"Braintree"][@"api"]] != nil;
                }]];

                // Assert that Braintree environment is configured with a client id
                [[[mockPayPalMobile expect] classMethod] initializeWithClientIdsForEnvironments:[OCMArg checkWithBlock:^BOOL(NSDictionary *clientIdsForEnvironments) {
                    return [clientIdsForEnvironments count] == 1 && [clientIdsForEnvironments[@"Braintree"] length] > 0;
                }]];

                // Assert that Braintree environment is actually used
                [[[mockPayPalMobile expect] classMethod] preconnectWithEnvironment:@"Braintree"];

                [testClient btPayPal_preparePayPalMobileWithError:NULL];

                [mockPayPalMobile verify];
                [mockPayPalMobile stopMocking];
            });

            it(@"enables BTPayPalViewController to embed a PayPalProfileSharingViewController that hits the specified environment", ^{
                OCMockObject *mockPayPalMobile = [OCMockObject mockForClass:[PayPalMobile class]];
                [[[mockPayPalMobile stub] classMethod] preconnectWithEnvironment:[OCMArg isNotNil]];

                BTPayPalViewController *payPalViewController = [[BTPayPalViewController alloc] initWithClient:testClient];

                [payPalViewController view];

                expect(payPalViewController.payPalProfileSharingViewController).to.beKindOf([PayPalProfileSharingViewController class]);
                [mockPayPalMobile stopMocking];
            });
        });

        describe(@"with PayPal disabled", ^{
            __block BTClient *testClient;

            beforeEach(^{
                waitUntil(^(DoneCallback done){
                    NSString *merchantIdWithPayPalDisabled = @"integration2_merchant_id";
                    NSString *merchantKeyWithPayPalDisabled = @"integration2_public_key";
                    [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier: merchantIdWithPayPalDisabled,
                                                             BTClientTestConfigurationKeyPublicKey:merchantKeyWithPayPalDisabled,
                                                             BTClientTestConfigurationKeyCustomer: @YES }
                                               async:YES
                                               completion:^(BTClient *client) {
                                                   testClient = client;
                                                   done();
                                               }];
                });
            });

            it(@"fails to initialize if the paypal directBaseURL is not present", ^{
                OCMockObject *mockPayPalMobile = [OCMockObject mockForClass:[PayPalMobile class]];
                [[[mockPayPalMobile stub] classMethod] preconnectWithEnvironment:[OCMArg isNotNil]];
                id mockPayPalViewControllerDelegate = [OCMockObject mockForProtocol:@protocol(BTPayPalViewControllerDelegate)];

                BTPayPalViewController *payPalViewController = [[BTPayPalViewController alloc] initWithClient:testClient];
                payPalViewController.delegate = mockPayPalViewControllerDelegate;

                [[mockPayPalViewControllerDelegate stub] payPalViewController:payPalViewController didFailWithError:[OCMArg checkWithBlock:^BOOL(NSError *error) {
                    return error.domain == BTBraintreePayPalErrorDomain && error.code == BTMerchantIntegrationErrorPayPalConfiguration;
                }]];
                [payPalViewController view];

                expect(payPalViewController.view).to.beNil();

                [mockPayPalMobile stopMocking];
                [mockPayPalViewControllerDelegate stopMocking];
            });
        });
    });

    describe(@"offline", ^{
        __block BTClient *client;

        beforeEach(^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            client = [[BTClient alloc] initWithClientToken:[BTClient btPayPal_offlineTestClientToken]];
#pragma clang diagnostic pop
        });

        it(@"defaults to PayPal mock mode in BTClient offline mode", ^{
            OCMockObject *mockPayPalMobile = [OCMockObject mockForClass:[PayPalMobile class]];

            // Assert that Braintree environment is actually used
            [[[mockPayPalMobile expect] classMethod] preconnectWithEnvironment:PayPalEnvironmentNoNetwork];

            [client btPayPal_preparePayPalMobileWithError:NULL];

            [mockPayPalMobile verify];
            [mockPayPalMobile stopMocking];
        });

        it(@"enables BTPayPalViewController to embed a PayPalProfileSharingViewController that hits the mock mode environment", ^{
            BTPayPalViewController *payPalViewController = [[BTPayPalViewController alloc] initWithClient:client];
            [payPalViewController view];
            expect(payPalViewController.payPalProfileSharingViewController).to.beKindOf([PayPalProfileSharingViewController class]);
        });
    });
});

SpecEnd
