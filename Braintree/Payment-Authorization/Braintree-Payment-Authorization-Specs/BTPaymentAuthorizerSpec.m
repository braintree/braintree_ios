#import "BTPaymentAuthorizer.h"

#import "BTClient.h"
#import "BTClient+BTPayPal.h"

#import "BTPayPalAppSwitchHandler.h"
#import "BTVenmoAppSwitchHandler.h"

SpecBegin(BTPaymentAuthorizer)

__block id client;
__block id delegate;

beforeEach(^{
    client = [OCMockObject mockForClass:[BTClient class]];
    [[client stub] btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    [[client stub] postAnalyticsEvent:OCMOCK_ANY];

    delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentAuthorizerDelegate)];
});

afterEach(^{
    [client verify];
    [client stopMocking];

    [delegate verify];
    [delegate stopMocking];
});

fdescribe(@"authorize:", ^{

    __block BTPaymentAuthorizationType paymentAuthorizationType;
    __block BTPaymentAuthorizer *authorizer;

    beforeEach(^{
        authorizer = [[BTPaymentAuthorizer alloc] init];
        authorizer.client = client;
    });

    context(@"when type is BTPaymentAuthorizationTypePayPal", ^{

        __block id payPalAppSwitchHandler;

        beforeEach(^{
            paymentAuthorizationType = BTPaymentAuthorizationTypePayPal;

            payPalAppSwitchHandler = [OCMockObject mockForClass:[BTPayPalAppSwitchHandler class]];
            [[[payPalAppSwitchHandler stub] andReturn:payPalAppSwitchHandler] sharedHandler];
        });

        afterEach(^{
            [payPalAppSwitchHandler verify];
            [payPalAppSwitchHandler stopMocking];
        });

        context(@"and app switch is available", ^{

            beforeEach(^{
                [[[payPalAppSwitchHandler stub] andReturnValue:@YES] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
            });

            it(@"returns YES and invokes app switch delegate method", ^{
                [[delegate expect] paymentAuthorizerWillRequestUserChallengeWithAppSwitch:authorizer];
                authorizer.delegate = delegate;

                BOOL initiated = [authorizer authorize:BTPaymentAuthorizationTypePayPal];
                expect(initiated).to.beTruthy();
            });
        });

        context(@"and app switch is unavailable", ^{

            beforeEach(^{
                [[[payPalAppSwitchHandler stub] andReturnValue:@NO] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
            });

            it(@"returns YES and invokes view controller delegate method", ^{
                [[delegate expect] paymentAuthorizer:authorizer requestsUserAuthorizationWithViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return [obj isKindOfClass:[UIViewController class]];
                }]];
                authorizer.delegate = delegate;

                BOOL initiated = [authorizer authorize:BTPaymentAuthorizationTypePayPal];
                expect(initiated).to.beTruthy();
            });
        });
    });


    context(@"when type is BTPaymentAuthorizationTypeVenmo", ^{

        __block id venmoAppSwitchHandler;

        beforeEach(^{
            venmoAppSwitchHandler = [OCMockObject mockForClass:[BTVenmoAppSwitchHandler class]];
            [[[venmoAppSwitchHandler stub] andReturn:venmoAppSwitchHandler] sharedHandler];

            authorizer = [[BTPaymentAuthorizer alloc] initWithType:BTPaymentAuthorizationTypeVenmo client:client];
            authorizer.delegate = delegate;
        });

        context(@"and app switch is available", ^{

            beforeEach(^{
                [[[venmoAppSwitchHandler stub] andReturnValue:@YES] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
            });


            it(@"returns YES and invokes an app switch delegate method", ^{
                [[delegate expect] paymentAuthorizerWillRequestUserChallengeWithAppSwitch:authorizer];

                BOOL initiated = [authorizer authorize];
                expect(initiated).to.beTruthy();
            });
        });

        context(@"and app switch is unavailable", ^{

            beforeEach(^{
                [[[venmoAppSwitchHandler stub] andReturnValue:@NO] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
            });


            it(@"returns NO and does not invokes an app switch delegate method", ^{
                BOOL initiated = [authorizer authorize];
                expect(initiated).to.beFalsy();
            });
        });
    });
});

SpecEnd
