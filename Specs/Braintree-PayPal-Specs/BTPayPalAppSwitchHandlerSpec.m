#import "BTPayPalAppSwitchHandler_Internal.h"
#import "BTClient+BTPayPal.h"
#import "BTClient_Internal.h"
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
    [[[client stub] andReturn:[[PayPalConfiguration alloc] init]] btPayPal_configuration];
    [[[client stub] andReturn:[NSSet setWithObjects:kPayPalOAuth2ScopeFuturePayments, kPayPalOAuth2ScopeEmail, nil]] btPayPal_scopes];
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

    context(@"with PayPal disabled", ^{
        it(@"returns error with code indicating PayPal is disabled", ^{
            [[[client stub] andReturnValue:@NO] btPayPal_isPayPalEnabled];
            [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.disabled"];
            NSError *error;
            BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];
            expect(handled).to.beFalsy();
            expect(error.domain).to.equal(BTBraintreePayPalErrorDomain);
            expect(error.code).to.equal(BTPayPalErrorPayPalDisabled);
        });
    });

    context(@"with PayPal Touch disabled", ^{
        it(@"returns error with code indicating app switch is disabled", ^{
            [[[client stub] andReturnValue:@YES] btPayPal_isPayPalEnabled];
            [[[client stub] andReturnValue:@YES] btPayPal_isTouchDisabled];
            [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.app-switch-disabled"];
            NSError *error;
            BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];
            expect(handled).to.beFalsy();
            expect(error.domain).to.equal(BTAppSwitchErrorDomain);
            expect(error.code).to.equal(BTAppSwitchErrorDisabled);
        });
    });

    context(@"with PayPal and PayPal Touch enabled", ^{

        beforeEach(^{
            [[[client stub] andReturnValue:@YES] btPayPal_isPayPalEnabled];
            [[[client stub] andReturnValue:@NO] btPayPal_isTouchDisabled];
            appSwitchHandler.returnURLScheme = @"a-scheme";
        });

        context(@"with invalid parameters", ^{

            it(@"returns a BTAppSwitchErrorIntegrationReturnURLScheme error if returnURLScheme is nil", ^{
                appSwitchHandler.returnURLScheme = nil;
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.invalid.return-url-scheme"];
                NSError *error;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];
                expect(handled).to.beFalsy();
                expect(error.domain).to.equal(BTAppSwitchErrorDomain);
                expect(error.code).to.equal(BTAppSwitchErrorIntegrationReturnURLScheme);
            });

            it(@"returns a BTAppSwitchErrorIntegrationInvalidParameters error with a nil delegate", ^{
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.invalid.parameters"];
                NSError *error;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:nil error:&error];
                expect(handled).to.beFalsy();
                expect(error.domain).to.equal(BTAppSwitchErrorDomain);
                expect(error.code).to.equal(BTAppSwitchErrorIntegrationInvalidParameters);
            });

            it(@"returns a BTAppSwitchErrorIntegrationInvalidParameters error with a nil client", ^{
                NSError *error;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:nil delegate:delegate error:&error];
                expect(handled).to.beFalsy();
                expect(error.domain).to.equal(BTAppSwitchErrorDomain);
                expect(error.code).to.equal(BTAppSwitchErrorIntegrationInvalidParameters);
            });

        });

        context(@"PayPalTouch canAppSwitchForUrlScheme returns YES", ^{
            beforeEach(^{
                [[[payPalTouch stub] andReturnValue:@YES] canAppSwitchForUrlScheme:OCMOCK_ANY];
            });

            it(@"returns nil and posts possible-error if PayPalTouch reports possible app switch failure", ^{
                [[[payPalTouch stub] andReturnValue:@NO] authorizeScopeValues:OCMOCK_ANY configuration:OCMOCK_ANY];
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.possible-error"];
                NSError *error = nil;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];
                expect(handled).to.beTruthy();
                expect(error).to.beNil();
            });

            it(@"returns nil when PayPalTouch can and does app switch", ^{
                [[[payPalTouch expect] andReturnValue:@YES] authorizeScopeValues:OCMOCK_ANY configuration:OCMOCK_ANY];
                [[client expect] postAnalyticsEvent:@"ios.paypal.appswitch.initiate.success"];
                NSError *error;
                BOOL handled = [appSwitchHandler initiateAppSwitchWithClient:client delegate:delegate error:&error];
                expect(handled).to.beTruthy();
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
