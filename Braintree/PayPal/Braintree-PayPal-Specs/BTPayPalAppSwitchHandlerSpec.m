#import "BTPayPalAppSwitchHandler_Internal.h"
#import "BTClient+BTPayPal.h"
#import "PayPalMobile.h"
#import "BTClientToken.h"
#import "BTClientToken+BTPayPal.h"
#import "BTClient_Internal.h"

SpecBegin(BTPayPalAppSwitchHandler)

__block id client;
__block id clientToken;
__block id delegate;
__block id payPalTouch;

beforeEach(^{
    client = [OCMockObject mockForClass:[BTClient class]];
    clientToken = [OCMockObject mockForClass:[BTClientToken class]];
    delegate = [OCMockObject mockForProtocol:@protocol(BTPayPalAppSwitchHandlerDelegate)];
    payPalTouch = [OCMockObject mockForClass:[PayPalTouch class]];
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
        appSwitchHandler.appSwitchCallbackURLScheme = @"test.your.code";
    });

    context(@"with PayPal Touch Disabled", ^{
        it(@"returns NO", ^{
            [[[client expect] andReturn:clientToken] clientToken];
            [[[clientToken stub] andReturnValue:@YES] btPayPal_disableAppSwitch];
            [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch-handler.initiate.disabled"];
            BOOL initiated = [appSwitchHandler initiatePayPalAuthWithClient:client delegate:delegate];
            expect(initiated).to.beFalsy();
        });
    });

    context(@"with PayPal Touch Enabled", ^{

        beforeEach(^{
            [[[client stub] andReturn:clientToken] clientToken];
            [[[clientToken stub] andReturnValue:@NO] btPayPal_disableAppSwitch];
        });

        describe(@"with invalid parameters", ^{
            it(@"returns NO if appSwitchCallbackURLScheme is nil", ^{
                appSwitchHandler.appSwitchCallbackURLScheme = nil;
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch-handler.initiate.invalid"];
                BOOL initiated = [appSwitchHandler initiatePayPalAuthWithClient:client delegate:delegate];
                expect(initiated).to.beFalsy();
            });

            it(@"returns NO with a nil client", ^{
                BOOL initiated = [appSwitchHandler initiatePayPalAuthWithClient:nil delegate:delegate];
                expect(initiated).to.beFalsy();
            });

            it(@"returns NO with a nil delegate", ^{
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch-handler.initiate.invalid"];
                BOOL initiated = [appSwitchHandler initiatePayPalAuthWithClient:client delegate:nil];
                expect(initiated).to.beFalsy();
            });
        });

        it(@"returns NO if PayPalTouch can not app switch", ^{
            [[[payPalTouch expect] andReturnValue:@NO] canAppSwitchForUrlScheme:OCMOCK_ANY];
            [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch-handler.initiate.bad-callback-url-scheme"];
            BOOL initiated = [appSwitchHandler initiatePayPalAuthWithClient:client delegate:delegate];
            expect(initiated).to.beFalsy();
        });


        describe(@"when PayPalTouch can app switch", ^{
            beforeEach(^{
                [[[payPalTouch expect] andReturnValue:@YES] canAppSwitchForUrlScheme:OCMOCK_ANY];
                [[[client stub] andReturn:[[PayPalConfiguration alloc] init]] btPayPal_configuration];
            });

            it(@"returns NO if PayPalTouch does not authorize", ^{
                [[[payPalTouch expect] andReturnValue:@NO] authorizeFuturePayments:OCMOCK_ANY];
                [[delegate expect] payPalAppSwitchHandlerWillAppSwitch:appSwitchHandler];
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch-handler.initiate.fail"];
                BOOL initiated = [appSwitchHandler initiatePayPalAuthWithClient:client delegate:delegate];
                expect(initiated).to.beFalsy();
            });

            it(@"returns YES when PayPalTouch can and does app switch", ^{
                [[[payPalTouch expect] andReturnValue:@YES] authorizeFuturePayments:OCMOCK_ANY];
                [[delegate expect] payPalAppSwitchHandlerWillAppSwitch:appSwitchHandler];
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch-handler.initiate.success"];
                BOOL initiated = [appSwitchHandler initiatePayPalAuthWithClient:client delegate:delegate];
                expect(initiated).to.beTruthy();
            });
        });
    });
});

describe(@"handleAppSwitchURL:sourceApplication:", ^{

    __block BTPayPalAppSwitchHandler *appSwitchHandler;
    __block NSURL *sampleURL = [NSURL URLWithString:@"test.your.code://hello"];
    __block NSString *sampleSourceApplication = @"com.a.wallet";

    beforeEach(^{
        appSwitchHandler = [[BTPayPalAppSwitchHandler alloc] init];
        appSwitchHandler.appSwitchCallbackURLScheme = @"test.your.code";
        appSwitchHandler.delegate = delegate;
        appSwitchHandler.client = client;
    });

    describe(@"with invalid initial state", ^{
        it(@"returns NO if appSwitchCallbackURLScheme is nil", ^{
            appSwitchHandler.appSwitchCallbackURLScheme = nil;
            [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch-handler.handle.invalid"];
            BOOL initiated = [appSwitchHandler handleAppSwitchURL:sampleURL sourceApplication:sampleSourceApplication];
            expect(initiated).to.beFalsy();
        });

        it(@"returns NO with a nil client", ^{
            appSwitchHandler.client = nil;
            BOOL initiated = [appSwitchHandler handleAppSwitchURL:sampleURL sourceApplication:sampleSourceApplication];
            expect(initiated).to.beFalsy();
        });

        it(@"returns NO with a nil delegate", ^{
            appSwitchHandler.delegate = nil;
            [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch-handler.handle.invalid"];
            BOOL initiated = [appSwitchHandler handleAppSwitchURL:sampleURL sourceApplication:sampleSourceApplication];
            expect(initiated).to.beFalsy();
        });
    });

    pending(@"with valid initial state and invalid URL");
    pending(@"with valid initial state and URL PayPal can't handle");
    pending(@"with valid initial state and URL PayPal can handle - cancel, error, and success results");
});

SpecEnd