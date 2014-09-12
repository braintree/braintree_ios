@import PassKit;

#import "BTPaymentProvider.h"

#import "BTClient_Internal.h"
#import "BTClient+BTPayPal.h"
#import "BTClientApplePayConfiguration.h"

#import "BTPayPalAppSwitchHandler.h"
#import "BTVenmoAppSwitchHandler.h"

@interface BTPaymentProvider () <PKPaymentAuthorizationViewControllerDelegate>
@end


SpecBegin(BTPaymentProvider)

__block id client;
__block id delegate;

beforeEach(^{
    client = [OCMockObject mockForClass:[BTClient class]];
    [[client stub] btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    [[client stub] postAnalyticsEvent:OCMOCK_ANY];
    [[[client stub] andReturnValue:@YES] btPayPal_isPayPalEnabled];

    delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];
});

afterEach(^{
    [client verify];
    [client stopMocking];

    [delegate verify];
    [delegate stopMocking];
});

describe(@"createPaymentMethod:", ^{

    __block BTPaymentProviderType providerType;
    __block BTPaymentProvider *provider;

    beforeEach(^{
        provider = [[BTPaymentProvider alloc] initWithClient:client];
        provider.client = client;
        provider.delegate = delegate;
    });

    context(@"when type is BTPaymentProviderTypeApplePay", ^{
        __block id pkPaymentAuthorizationViewController;
        BTClientApplePayConfiguration *applePayConfiguration = [[BTClientApplePayConfiguration alloc] initWithDictionary:@{@"merchantId": @"a-merchant-id"}];
        beforeEach(^{
            pkPaymentAuthorizationViewController = [OCMockObject mockForClass:[PKPaymentAuthorizationViewController class]];
            [[[client stub] andReturn:applePayConfiguration] applePayConfiguration];
        });

        context(@"PKPaymentAuthorizationViewController can NOT make a payment", ^{

            beforeEach(^{
                [[[pkPaymentAuthorizationViewController stub] andReturnValue:@NO] canMakePayments];
            });

            it(@"calls delegate didFailWithError method", ^{
                [[delegate expect] paymentMethodCreator:provider didFailWithError:OCMOCK_ANY];
                [provider createPaymentMethod:BTPaymentProviderTypeApplePay];
            });

        });

        context(@"PKPaymentAuthorizationViewController CAN make a payment", ^{

            beforeEach(^{
                [[[pkPaymentAuthorizationViewController stub] andReturnValue:@YES] canMakePayments];
                [[[pkPaymentAuthorizationViewController stub] andReturn:pkPaymentAuthorizationViewController] alloc];
                __unused id _ = [[[pkPaymentAuthorizationViewController stub] andReturn:pkPaymentAuthorizationViewController] initWithPaymentRequest:OCMOCK_ANY];
                [[pkPaymentAuthorizationViewController stub] setDelegate:OCMOCK_ANY];
            });

            fit(@"calls delegate didFailWithError method", ^{
                [[delegate expect] paymentMethodCreator:provider requestsPresentationOfViewController:pkPaymentAuthorizationViewController];
                [provider createPaymentMethod:BTPaymentProviderTypeApplePay];
            });

        });

        describe(@"implementation of PKPaymentAuthorizationViewControllerDelegate", ^{

            __block id pkPayment;
            beforeEach(^{
                pkPayment = [OCMockObject mockForClass:[PKPayment class]];
            });



            context(@"when saveApplePayPayment:success:failure: succeeds", ^{
                __block id paymentMethod;
                beforeEach(^{
                    paymentMethod = [OCMockObject mockForClass:[BTPaymentMethod class]];
                    [[client stub] saveApplePayPayment:pkPayment success:[OCMArg checkWithBlock:^BOOL(id obj) {
                        ((BTClientApplePaySuccessBlock)obj)(paymentMethod);
                        return YES;
                    }] failure:OCMOCK_ANY];
                });

                it(@"paymentAuthorizationViewController:didAuthorizePayment:completion: calls delegate didCreatePaymentMethod:", ^AsyncBlock{

                    [[delegate expect] paymentMethodCreator:provider didCreatePaymentMethod:paymentMethod];

                    [provider paymentAuthorizationViewController:pkPaymentAuthorizationViewController didAuthorizePayment:pkPayment completion:^(PKPaymentAuthorizationStatus status) {
                        expect(status).to.equal(PKPaymentAuthorizationStatusSuccess);
                        done();
                    }];
                });
            });

            context(@"when saveApplePayPayment:success:failure: fails", ^{

                NSError *expectedError = [NSError errorWithDomain:@"a-domain" code:123 userInfo:nil];

                beforeEach(^{
                    [[client stub] saveApplePayPayment:pkPayment success:OCMOCK_ANY failure:[OCMArg checkWithBlock:^BOOL(id obj) {
                        ((BTClientFailureBlock)obj)(expectedError);
                        return YES;
                    }]];
                });

                it(@"paymentAuthorizationViewController:didAuthorizePayment:completion: calls delegate didFailWithError:", ^AsyncBlock{

                    [[delegate expect] paymentMethodCreator:provider didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
                        NSError *error = (NSError *)obj;
                        expect(error.domain).to.equal(BTPaymentProviderErrorDomain);
                        expect(error.code).to.equal(BTPaymentProviderErrorUnknown);
                        expect(error.userInfo[NSUnderlyingErrorKey]).to.equal(expectedError);
                        return YES;
                    }]];

                    [provider paymentAuthorizationViewController:pkPaymentAuthorizationViewController
                                             didAuthorizePayment:pkPayment
                                                      completion:^(PKPaymentAuthorizationStatus status) {
                        expect(status).to.equal(PKPaymentAuthorizationStatusFailure);
                        done();
                    }];
                });
            });

            it(@"paymentAuthorizationViewControllerDidFinish: calls delegate didCreatePaymentMethod:", ^{
                [[delegate expect] paymentMethodCreator:provider requestsDismissalOfViewController:pkPaymentAuthorizationViewController];
                [provider paymentAuthorizationViewControllerDidFinish:pkPaymentAuthorizationViewController];
            });
        });

    });

    context(@"when type is BTPaymentProviderTypePayPal", ^{

        __block id payPalAppSwitchHandler;

        beforeEach(^{
            providerType = BTPaymentProviderTypePayPal;

            payPalAppSwitchHandler = [OCMockObject mockForClass:[BTPayPalAppSwitchHandler class]];
            [[[payPalAppSwitchHandler stub] andReturn:payPalAppSwitchHandler] sharedHandler];
        });

        afterEach(^{
            [payPalAppSwitchHandler verify];
            [payPalAppSwitchHandler stopMocking];
        });

        context(@"and app switch is available", ^{

            beforeEach(^{
                [[[payPalAppSwitchHandler stub] andReturnValue:@YES] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
            });

            it(@"invokes an app switch delegate method", ^{
                [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];
                provider.delegate = delegate;
                [provider createPaymentMethod:BTPaymentProviderTypePayPal];
            });
        });

        context(@"and app switch is unavailable", ^{

            beforeEach(^{
                [[[payPalAppSwitchHandler stub] andReturnValue:@NO] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
            });

            it(@"returns YES and invokes view controller delegate method", ^{
                [[delegate expect] paymentMethodCreator:provider requestsPresentationOfViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return [obj isKindOfClass:[UIViewController class]];
                }]];
                provider.delegate = delegate;

                [provider createPaymentMethod:BTPaymentProviderTypePayPal];
            });
        });
    });


    context(@"when type is BTPaymentProviderTypeVenmo", ^{

        __block id venmoAppSwitchHandler;

        beforeEach(^{
            venmoAppSwitchHandler = [OCMockObject mockForClass:[BTVenmoAppSwitchHandler class]];
            [[[venmoAppSwitchHandler stub] andReturn:venmoAppSwitchHandler] sharedHandler];

            provider.delegate = delegate;
        });

        context(@"and app switch is available", ^{

            beforeEach(^{
                [[[venmoAppSwitchHandler stub] andReturnValue:@YES] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
            });

            it(@"invokes an app switch delegate method", ^{
                [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];
                [provider createPaymentMethod:BTPaymentProviderTypeVenmo];
            });
        });

        context(@"and app switch is unavailable", ^{

            beforeEach(^{
                [[[venmoAppSwitchHandler stub] andReturnValue:@NO] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
            });


            it(@"returns NO and does not invoke a willAppSwitch delegate method", ^{
                [[delegate expect] paymentMethodCreator:provider didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
                    if ([obj isKindOfClass:[NSError class]]) {
                        NSError *error = (NSError *)obj;
                        expect(error.domain).to.equal(BTPaymentProviderErrorDomain);
                        expect(error.code).to.equal(BTPaymentProviderErrorUnknown);
                        return YES;
                    }
                    return NO;
                }]];
                [provider createPaymentMethod:BTPaymentProviderTypeVenmo];
            });
        });
    });
});

SpecEnd
