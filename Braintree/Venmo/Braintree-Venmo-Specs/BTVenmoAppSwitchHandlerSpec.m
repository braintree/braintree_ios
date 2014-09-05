#import "BTVenmoErrors.h"
#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchReturnURL.h"
#import "BTVenmoAppSwitchRequestURL.h"
#import "BTClient+BTVenmo.h"
#import "BTClient_Metadata.h"

SpecBegin(BTVenmoAppSwitchHandler)

describe(@"sharedHandler", ^{

    it(@"returns one and only one instance", ^{
        expect([BTVenmoAppSwitchHandler sharedHandler]).to.beIdenticalTo([BTVenmoAppSwitchHandler sharedHandler]);
    });

});

describe(@"isAvailableForClient:", ^{

    __block BTVenmoAppSwitchHandler *handler;
    __block id mockClient;
    __block id mockBTVenmoAppSwitchRequestURL;

    beforeEach(^{
        handler = [[BTVenmoAppSwitchHandler alloc] init];
        mockClient = [OCMockObject mockForClass:[BTClient class]];
        mockBTVenmoAppSwitchRequestURL = [OCMockObject mockForClass:[BTVenmoAppSwitchRequestURL class]];
    });

    afterEach(^{
        [mockClient verify];
        [mockClient stopMocking];
        [mockBTVenmoAppSwitchRequestURL verify];
        [mockBTVenmoAppSwitchRequestURL stopMocking];
    });

    it(@"returns YES if [BTVenmoAppSwitchRequestURL isAppSwitchAvailable] and venmo status is production", ^{
        [[[mockClient stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusProduction)] btVenmo_status];
        [[[mockBTVenmoAppSwitchRequestURL stub] andReturnValue:@YES] isAppSwitchAvailable];
        expect([BTVenmoAppSwitchHandler isAvailableForClient:mockClient]).to.beTruthy();
    });

    it(@"returns YES if [BTVenmoAppSwitchRequestURL isAppSwitchAvailable] and venmo status is offline", ^{
        [[[mockClient stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusOffline)] btVenmo_status];
        [[[mockBTVenmoAppSwitchRequestURL stub] andReturnValue:@YES] isAppSwitchAvailable];
        expect([BTVenmoAppSwitchHandler isAvailableForClient:mockClient]).to.beTruthy();
    });

    it(@"returns NO if venmo status is off", ^{
        [[[mockClient stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusOff)] btVenmo_status];
        [[[mockBTVenmoAppSwitchRequestURL stub] andReturnValue:@YES] isAppSwitchAvailable];
        expect([BTVenmoAppSwitchHandler isAvailableForClient:mockClient]).to.beFalsy();
    });

    it(@"returns NO if [BTVenmoAppSwitchRequestURL isAppSwitchAvailable] returns NO", ^{
        [[[mockClient stub] andReturnValue:OCMOCK_VALUE(BTVenmoStatusProduction)] btVenmo_status];
        [[[mockBTVenmoAppSwitchRequestURL stub] andReturnValue:@NO] isAppSwitchAvailable];
        expect([BTVenmoAppSwitchHandler isAvailableForClient:mockClient]).to.beFalsy();
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

        BTVenmoAppSwitchHandler *handler = [[BTVenmoAppSwitchHandler alloc] init];
        BOOL handled = [handler canHandleReturnURL:testURL sourceApplication:testSourceApplication];

        expect(handled).to.beTruthy();
    });

    it(@"returns NO if [BTVenmoAppSwitchReturnURL isValidURL:sourceApplication:] returns NO", ^{
        [[[mockVenmoAppSwitchReturnURL expect] andReturnValue:@NO] isValidURL:testURL sourceApplication:testSourceApplication];

        BTVenmoAppSwitchHandler *handler = [[BTVenmoAppSwitchHandler alloc] init];
        BOOL handled = [handler canHandleReturnURL:testURL sourceApplication:testSourceApplication];

        expect(handled).to.beFalsy();
    });
});

describe(@"initiateAppSwitchWithClient:delegate:", ^{
    __block BTVenmoAppSwitchHandler *handler;

    beforeEach(^{
        handler = [[BTVenmoAppSwitchHandler alloc] init];
    });

    it(@"returns NO if client has `btVenmo_status` BTVenmoStatusOff", ^{
        id mockClient = [OCMockObject mockForClass:[BTClient class]];
        id delegate = [OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)];

        [[[mockClient stub] andReturn:mockClient] copyWithMetadata:OCMOCK_ANY];
        [[mockClient stub] postAnalyticsEvent:OCMOCK_ANY];
        [[[mockClient expect] andReturnValue:OCMOCK_VALUE(BTVenmoStatusOff)] btVenmo_status];

        [[delegate expect] appSwitcher:handler didFailWithError:[OCMArg checkWithBlock:^BOOL(id obj) {
            NSError *error = (NSError *)obj;
            expect(error.domain).to.equal(BTVenmoErrorDomain);
            expect(error.code).to.equal(BTVenmoErrorAppSwitchDisabled);
            return YES;
        }]];

        [handler initiateAppSwitchWithClient:mockClient delegate:delegate];

        [mockClient verify];
        [mockClient stopMocking];

        [delegate verify];
        [delegate stopMocking];
    });

});

SpecEnd
