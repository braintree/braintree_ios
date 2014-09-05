#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchReturnURL.h"
#import "BTClient+BTVenmo.h"
#import "BTClient_Metadata.h"

SpecBegin(BTVenmoAppSwitchHandler)

describe(@"sharedHandler", ^{

    it(@"returns one and only one instance", ^{
        expect([BTVenmoAppSwitchHandler sharedHandler]).to.beIdenticalTo([BTVenmoAppSwitchHandler sharedHandler]);
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

        [handler initiateAppSwitchWithClient:mockClient delegate:delegate];

        [mockClient verify];
        [mockClient stopMocking];

        [delegate verify];
        [delegate stopMocking];
    });

});

SpecEnd
