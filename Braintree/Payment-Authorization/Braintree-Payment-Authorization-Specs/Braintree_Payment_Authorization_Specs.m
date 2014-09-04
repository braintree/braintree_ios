#import "BTPaymentAuthorizer_Protected.h"
#import "BTPaymentAuthorizerPayPal.h"
#import "BTPaymentAuthorizerVenmo.h"

#import "BTClient.h"
#import "BTClient+BTPayPal.h"

#import "BTPayPalAppSwitchHandler.h"

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

    context(@"when type is BTPaymentAuthorizationTypePayPal", ^{

        __block id payPalAppSwitchHandler;
        __block BTPaymentAuthorizer *authorizer;

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

            it(@"invokes app switch delegate method", ^{
                [[delegate expect] paymentAuthorizerWillRequestUserChallengeWithAppSwitch:authorizer];
                authorizer.delegate = delegate;

                [authorizer authorize];
            });
        });

        context(@"and app switch is unavailable", ^{

            beforeEach(^{
                [[[payPalAppSwitchHandler stub] andReturnValue:@NO] initiateAppSwitchWithClient:OCMOCK_ANY delegate:OCMOCK_ANY];
            });

            it(@"invokes view controller delegate method", ^{
                [[delegate expect] paymentAuthorizer:authorizer requestsUserChallengeWithViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                    return [obj isKindOfClass:[UIViewController class]];
                }]];
                authorizer.delegate = delegate;

                [authorizer authorize];
            });
        });
    });
});

SpecEnd
