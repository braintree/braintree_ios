#import <UIKit/UIKit.h>

#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchHandler_Internal.h"
#import "BTVenmoAppSwitchReturnURL.h"
#import "BTVenmoAppSwitchRequestURL.h"
#import "BTClient+BTVenmo.h"
#import "BTClient_Internal.h"

SpecBegin(BTVenmoAppSwitchHandler)

describe(@"sharedHandler", ^{

    it(@"returns one and only one instance", ^{
        expect([BTVenmoAppSwitchHandler sharedHandler]).to.beIdenticalTo([BTVenmoAppSwitchHandler sharedHandler]);
    });

});

describe(@"An instance", ^{
    __block BTVenmoAppSwitchHandler *handler;
    __block id client;
    __block id delegate;

    beforeEach(^{
        handler = [[BTVenmoAppSwitchHandler alloc] init];
        client = [OCMockObject mockForClass:[BTClient class]];
        delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

        [[[client stub] andReturn:client] copyWithMetadata:OCMOCK_ANY];
        [[client stub] postAnalyticsEvent:OCMOCK_ANY];
    });

    afterEach(^{
        [client verify];
        [client stopMocking];

        [delegate verify];
        [delegate stopMocking];
    });

    describe(@"availableWithClient:", ^{

        __block id venmoAppSwitchRequestURL;

        beforeEach(^{
            venmoAppSwitchRequestURL = [OCMockObject mockForClass:[BTVenmoAppSwitchRequestURL class]];
        });

        afterEach(^{
            [venmoAppSwitchRequestURL verify];
            [venmoAppSwitchRequestURL stopMocking];
        });

        context(@"valid merchant ID valid returnURLScheme", ^{
            beforeEach(^{
                [[[client stub] andReturn:@"a-merchant-id"] merchantId];
                handler.returnURLScheme = @"a-scheme";
            });

            it(@"returns YES if [BTVenmoAppSwitchRequestURL isAppSwitchAvailable] and venmo status is production", ^{
                [(BTClient *)[[client stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusProduction)] btVenmo_status];
                [[[venmoAppSwitchRequestURL stub] andReturnValue:@YES] isAppSwitchAvailable];
                expect([handler appSwitchAvailableForClient:client]).to.beTruthy();
            });

            it(@"returns YES if [BTVenmoAppSwitchRequestURL isAppSwitchAvailable] and venmo status is offline", ^{
                [(BTClient *)[[client stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusOffline)] btVenmo_status];
                [[[venmoAppSwitchRequestURL stub] andReturnValue:@YES] isAppSwitchAvailable];
                expect([handler appSwitchAvailableForClient:client]).to.beTruthy();
            });

            it(@"returns NO if venmo status is off", ^{
                [(BTClient *)[[client stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusOff)] btVenmo_status];
                [[[venmoAppSwitchRequestURL stub] andReturnValue:@YES] isAppSwitchAvailable];
                expect([handler appSwitchAvailableForClient:client]).to.beFalsy();
            });

            it(@"returns NO if [BTVenmoAppSwitchRequestURL isAppSwitchAvailable] returns NO", ^{
                [(BTClient *)[[client stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusProduction)] btVenmo_status];
                [[[venmoAppSwitchRequestURL stub] andReturnValue:@NO] isAppSwitchAvailable];
                expect([handler appSwitchAvailableForClient:client]).to.beFalsy();
            });
        });

        context(@"available venmo status and app switch", ^{
            beforeEach(^{
                [(BTClient *)[[client stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusProduction)] btVenmo_status];
                [[[venmoAppSwitchRequestURL stub] andReturnValue:@YES] isAppSwitchAvailable];
            });

            it(@"returns YES if merchant is not nil and returnURLScheme is not nil", ^{
                [[[client stub] andReturn:@"a-merchant-id"] merchantId];
                handler.returnURLScheme = @"a-scheme";
                expect([handler appSwitchAvailableForClient:client]).to.beTruthy();
            });

            it(@"returns NO if merchant is nil", ^{
                handler.returnURLScheme = @"a-scheme";
                [[[client stub] andReturn:nil] merchantId];
                expect([handler appSwitchAvailableForClient:client]).to.beFalsy();
            });

            it(@"returns NO if returnURLScheme is nil", ^{
                [[[client stub] andReturn:@"a-merchant-id"] merchantId];
                expect([handler appSwitchAvailableForClient:client]).to.beFalsy();
            });
        });
    });


    describe(@"canHandleReturnURL:sourceApplication:", ^{

        __block id mockVenmoAppSwitchReturnURL;
        NSString *testSourceApplication = @"a-source.app.App";
        NSURL *testURL = [NSURL URLWithString:@"another-scheme://a-host"];

        beforeEach(^{
            mockVenmoAppSwitchReturnURL = [OCMockObject mockForClass:[BTVenmoAppSwitchReturnURL class]];
        });

        afterEach(^{
            [mockVenmoAppSwitchReturnURL verify];
            [mockVenmoAppSwitchReturnURL stopMocking];
        });

        it(@"returns YES if [BTVenmoAppSwitchReturnURL isValidURL:sourceApplication:] returns YES", ^{
            [[[mockVenmoAppSwitchReturnURL expect] andReturnValue:@YES] isValidURL:testURL sourceApplication:testSourceApplication];

            BOOL handled = [handler canHandleReturnURL:testURL sourceApplication:testSourceApplication];

            expect(handled).to.beTruthy();
        });

        it(@"returns NO if [BTVenmoAppSwitchReturnURL isValidURL:sourceApplication:] returns NO", ^{
            [[[mockVenmoAppSwitchReturnURL expect] andReturnValue:@NO] isValidURL:testURL sourceApplication:testSourceApplication];

            BOOL handled = [handler canHandleReturnURL:testURL sourceApplication:testSourceApplication];

            expect(handled).to.beFalsy();
        });
    });

    describe(@"initiateAppSwitchWithClient:delegate:", ^{

        it(@"returns BTAppSwitchErrorDisabled error if client has `btVenmo_status` BTVenmoStatusOff", ^{

            [(BTClient *)[[client stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusOff)] btVenmo_status];

            NSError *error;
            BOOL handled = [handler initiateAppSwitchWithClient:client delegate:delegate error:&error];
            expect(handled).to.beFalsy();
            expect(error.domain).to.equal(BTAppSwitchErrorDomain);
            expect(error.code).to.equal(BTAppSwitchErrorDisabled);
        });

        context(@"btVenmo_status BTVenmoStatusProduction", ^{
            __block id venmoRequestURL;
            __block id sharedApplication;
            NSURL *url = [NSURL URLWithString:@"a-scheme://a-host"];

            beforeEach(^{
                venmoRequestURL = [OCMockObject mockForClass:[BTVenmoAppSwitchRequestURL class]];
                sharedApplication = [OCMockObject mockForClass:[UIApplication class]];
                [[[sharedApplication stub] andReturn:sharedApplication] sharedApplication];
                [[[sharedApplication stub] andReturnValue:@YES] canOpenURL:OCMOCK_ANY];

            });

            afterEach(^{
                [venmoRequestURL verify];
                [venmoRequestURL stopMocking];

                [sharedApplication verify];
                [sharedApplication stopMocking];
            });

            beforeEach(^{
                [(BTClient *)[[client stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusProduction)] btVenmo_status];
            });

            context(@"with valid setup", ^{
                beforeEach(^{
                    handler.returnURLScheme = @"a-scheme";
                    [[[client stub] andReturn:@"a-merchant-id"] merchantId];
                    [[[venmoRequestURL stub] andReturn:url] appSwitchURLForMerchantID:@"a-merchant-id" returnURLScheme:@"a-scheme" offline:NO error:(NSError *__autoreleasing *)[OCMArg anyPointer]];
                });

                it(@"returns nil if successfully app switches", ^{
                    [[[sharedApplication expect] andReturnValue:@YES] openURL:url];

                    NSError *error;
                    BOOL handled = [handler initiateAppSwitchWithClient:client delegate:delegate error:&error];
                    expect(handled).to.beTruthy();
                });

                it(@"returns error if app switch unexpectedly fails", ^{
                    [[[sharedApplication expect] andReturnValue:@NO] openURL:url];

                    NSError *error;
                    BOOL handled = [handler initiateAppSwitchWithClient:client delegate:delegate error:&error];
                    expect(handled).to.beFalsy();
                    expect(error.domain).to.equal(BTAppSwitchErrorDomain);
                    expect(error.code).to.equal(BTAppSwitchErrorFailed);
                });

            });
        });


    });

    describe(@"handleReturnURL:", ^{

        __block id appSwitchReturnURL;
        __block id paymentMethod;

        NSURL *returnURL = [NSURL URLWithString:@"scheme://host/x"];

        beforeEach(^{
            delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];
            handler.delegate = delegate;
            client = [OCMockObject mockForClass:[BTClient class]];
            handler.client = client;

            appSwitchReturnURL = [OCMockObject mockForClass:[BTVenmoAppSwitchReturnURL class]];
            [[[appSwitchReturnURL stub] andReturn:appSwitchReturnURL] alloc];
            __unused id _ = [[[appSwitchReturnURL stub] andReturn:appSwitchReturnURL] initWithURL:returnURL];

            paymentMethod = [OCMockObject mockForClass:[BTPaymentMethod class]];
            [[[paymentMethod stub] andReturn:@"a-nonce" ] nonce];

            [[[appSwitchReturnURL stub] andReturn:paymentMethod] paymentMethod];
        });

        afterEach(^{
            [appSwitchReturnURL verify];
            [appSwitchReturnURL stopMocking];
        });

        describe(@"with valid URL and with Venmo set to production", ^{

            beforeEach(^{
                [[[appSwitchReturnURL stub] andReturnValue:OCMOCK_VALUE(BTVenmoAppSwitchReturnURLStateSucceeded)] state];
                [(BTClient *)[[client stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusProduction)] btVenmo_status];
            });

            it(@"performs fetchPaymentMethodWithNonce:success:failure:", ^{
                [[delegate expect] appSwitcherWillCreatePaymentMethod:handler];
                [[client expect] postAnalyticsEvent:@"ios.venmo.appswitch.handle.authorized"];
                [[client expect] fetchPaymentMethodWithNonce:@"a-nonce" success:OCMOCK_ANY failure:OCMOCK_ANY];

                // TODO - examine blocks passed to fetchPaymentMethodWithNonce
                // [[client expect] fetchPaymentMethodWithNonce:@"a-nonce" success:OCMOCK_ANY failure:OCMOCK_ANY];
                // [[delegate expect] appSwitcher:handler didCreatePaymentMethod:paymentMethod];

                [handler handleReturnURL:returnURL];
            });
        });
    });
});


SpecEnd
