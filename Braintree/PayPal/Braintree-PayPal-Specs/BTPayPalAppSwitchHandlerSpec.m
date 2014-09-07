#import "BTPayPalAppSwitchHandler_Internal.h"
#import "BTClient+BTPayPal.h"
#import "BTClient_Metadata.h"
#import "PayPalMobile.h"
#import "BTClientToken.h"

SpecBegin(BTPayPalAppSwitchHandler)

__block id client;
__block id delegate;
__block id payPalTouch;

beforeEach(^{
    client = [OCMockObject mockForClass:[BTClient class]];
    delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];
    payPalTouch = [OCMockObject mockForClass:[PayPalTouch class]];

    [[[client stub] andReturn:client] copyWithMetadata:OCMOCK_ANY];
});

afterEach(^{
    [client verify];
    [delegate verify];
    [payPalTouch verify];

    [(OCMockObject *)client stopMocking];
    [(OCMockObject *)delegate stopMocking];
    [(OCMockObject *)payPalTouch stopMocking];
});

describe(@"sharedHandler", ^{
    it(@"returns only one instance", ^{
        expect([BTPayPalAppSwitchHandler sharedHandler]).to.beIdenticalTo([BTPayPalAppSwitchHandler sharedHandler]);
    });
});


describe(@"initiatePayPalAuthWithClient:delegate:", ^{
    __block BTPayPalAppSwitchHandler *appSwitchHandler;

    beforeEach(^{
        appSwitchHandler = [[BTPayPalAppSwitchHandler alloc] init];
        appSwitchHandler.returnURLScheme = @"test.your.code";
    });

    context(@"with PayPal Touch Disabled", ^{
        it(@"returns NO", ^{
            [[[client expect] andReturnValue:@YES] btPayPal_isTouchDisabled];
            [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.disabled"];
            BOOL initiated = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate];
            expect(initiated).to.beFalsy();
        });
    });

    context(@"with PayPal Touch Enabled", ^{

        context(@"with invalid parameters", ^{

            context(@"with a client", ^{
                beforeEach(^{
                    [[[client expect] andReturnValue:@NO] btPayPal_isTouchDisabled];
                });

                it(@"returns NO if appSwitchCallbackURLScheme is nil", ^{
                    appSwitchHandler.returnURLScheme = nil;
                    [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.invalid"];
                    BOOL initiated = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate];
                    expect(initiated).to.beFalsy();
                });

                it(@"returns NO with a nil delegate", ^{
                    [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.invalid"];
                    BOOL initiated = [appSwitchHandler initiateAppSwitchWithClient:client delegate:nil];
                    expect(initiated).to.beFalsy();
                });
            });

            it(@"returns NO with a nil client", ^{
                BOOL initiated = [appSwitchHandler initiateAppSwitchWithClient:nil delegate:delegate];
                expect(initiated).to.beFalsy();
            });

        });

        it(@"returns NO if PayPalTouch can not app switch", ^{
            [[[payPalTouch expect] andReturnValue:@NO] canAppSwitchForUrlScheme:OCMOCK_ANY];
            [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.bad-callback-url-scheme"];
            [[[client expect] andReturnValue:@NO] btPayPal_isTouchDisabled];
            BOOL initiated = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate];
            expect(initiated).to.beFalsy();
        });


        describe(@"when PayPalTouch can app switch", ^{
            beforeEach(^{
                [[[payPalTouch expect] andReturnValue:@YES] canAppSwitchForUrlScheme:OCMOCK_ANY];
                [[[client stub] andReturn:[[PayPalConfiguration alloc] init]] btPayPal_configuration];
                [[[client expect] andReturnValue:@NO] btPayPal_isTouchDisabled];
            });

            it(@"returns NO if PayPalTouch does not authorize", ^{
                [[[payPalTouch expect] andReturnValue:@NO] authorizeFuturePayments:OCMOCK_ANY];
                [[delegate expect] appSwitcherWillSwitch:appSwitchHandler];
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.failure"];
                BOOL initiated = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate];
                expect(initiated).to.beFalsy();
            });

            it(@"returns YES when PayPalTouch can and does app switch", ^{
                [[[payPalTouch expect] andReturnValue:@YES] authorizeFuturePayments:OCMOCK_ANY];
                [[delegate expect] appSwitcherWillSwitch:appSwitchHandler];
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.success"];
                BOOL initiated = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate];
                expect(initiated).to.beTruthy();
            });
        });
    });
});

describe(@"handleReturnURL:", ^{

    __block BTPayPalAppSwitchHandler *appSwitchHandler;
    __block NSURL *sampleURL = [NSURL URLWithString:@"test.your.code://hello"];

    beforeEach(^{
        appSwitchHandler = [[BTPayPalAppSwitchHandler alloc] init];
        appSwitchHandler.returnURLScheme = @"test.your.code";
        appSwitchHandler.delegate = delegate;
        appSwitchHandler.client = client;
    });

    describe(@"with returnURLScheme", ^{
        [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.handle.error"];
        [[delegate expect] appSwitcher:appSwitchHandler didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [obj isKindOfClass:[NSError class]];
        }]];

        appSwitchHandler.returnURLScheme = nil;
        [appSwitchHandler handleReturnURL:sampleURL];

    });

    pending(@"with valid initial state and invalid URL");
    pending(@"with valid initial state and URL PayPal can't handle");
    pending(@"with valid initial state and URL PayPal can handle - cancel, error, and success results");
});

SpecEnd