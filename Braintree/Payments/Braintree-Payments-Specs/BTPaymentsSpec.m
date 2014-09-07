#import "BTPaymentProvider.h"

#import "BTClient.h"
#import "BTClient+BTPayPal.h"

#import "BTPayPalAppSwitchHandler.h"
#import "BTVenmoAppSwitchHandler.h"

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
                [[[payPalAppSwitchHandler stub] andReturn:nil] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
            });

            it(@"invokes an app switch delegate method", ^{
                [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];
                provider.delegate = delegate;
                [provider createPaymentMethod:BTPaymentProviderTypePayPal];
            });
        });

        context(@"and app switch is unavailable", ^{

            beforeEach(^{
                NSError *error = [NSError errorWithDomain:@"a-domain" code:1 userInfo:nil];
                [[[payPalAppSwitchHandler stub] andReturn:error] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
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
                [[[venmoAppSwitchHandler stub] andReturn:nil] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
            });

            it(@"invokes an app switch delegate method", ^{
                [[delegate expect] paymentMethodCreatorWillPerformAppSwitch:provider];
                [provider createPaymentMethod:BTPaymentProviderTypeVenmo];
            });
        });

        context(@"and app switch is unavailable", ^{

            NSError *error = [NSError errorWithDomain:@"a-domain" code:1 userInfo:nil];

            beforeEach(^{
                [[[venmoAppSwitchHandler stub] andReturn:error] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
            });


            it(@"returns NO and does not invoke a willAppSwitch delegate method", ^{
                [[delegate expect] paymentMethodCreator:provider didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
                    expect(obj).to.equal(error);
                    return obj == error;
                }]];
                [provider createPaymentMethod:BTPaymentProviderTypeVenmo];
            });
        });
    });
});

SpecEnd
