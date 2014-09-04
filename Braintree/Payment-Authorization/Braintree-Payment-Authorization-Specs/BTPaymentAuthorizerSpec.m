#import "BTPaymentAuthorizer_Protected.h"
#import "BTPaymentAuthorizerPayPal.h"
#import "BTPaymentAuthorizerVenmo.h"

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

describe(@"initWithType:client:", ^{

    it(@"returns a PayPal authorizer", ^{
        BTPaymentAuthorizer *authorizer = [[BTPaymentAuthorizer alloc] initWithType:BTPaymentAuthorizationTypePayPal client:client];
        expect(authorizer).to.beKindOf([BTPaymentAuthorizerPayPal class]);
    });

    it(@"returns a Venmo authorizer", ^{
        BTPaymentAuthorizer *authorizer = [[BTPaymentAuthorizer alloc] initWithType:BTPaymentAuthorizationTypeVenmo client:client];
        expect(authorizer).to.beKindOf([BTPaymentAuthorizerVenmo class]);
    });

});

describe(@"authorize", ^{

    __block BTPaymentAuthorizer *authorizer;

    context(@"for abstract BTPaymentAuthorizer", ^{

        beforeEach(^{
            authorizer = [[BTPaymentAuthorizer alloc] init];
        });

        it(@"throws an exception", ^{
            BOOL thrown;
            @try {
                [authorizer authorize];
            } @catch (NSException *e) {
                thrown = YES;
            }
            expect(thrown).to.beTruthy();
        });
    });

    context(@"when type is BTPaymentAuthorizationTypePayPal", ^{

        __block id payPalAppSwitchHandler;

        beforeEach(^{
            payPalAppSwitchHandler = [OCMockObject mockForClass:[BTPayPalAppSwitchHandler class]];
            [[[payPalAppSwitchHandler stub] andReturn:payPalAppSwitchHandler] sharedHandler];

            authorizer = [[BTPaymentAuthorizer alloc] initWithType:BTPaymentAuthorizationTypePayPal client:client];
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

                BOOL initiated = [authorizer authorize];
                expect(initiated).to.beTruthy();
            });
        });

        context(@"and app switch is unavailable", ^{

            beforeEach(^{
                [[[payPalAppSwitchHandler stub] andReturnValue:@NO] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
            });

            it(@"returns YES and invokes view controller delegate method", ^{
                [[delegate expect] paymentAuthorizer:authorizer requestsUserChallengeWithViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return [obj isKindOfClass:[UIViewController class]];
                }]];
                authorizer.delegate = delegate;

                BOOL initiated = [authorizer authorize];
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
