#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchReturnURL.h"

SpecBegin(BTVenmoAppSwitchHandler)

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
        [[[mockVenmoAppSwitchReturnURL expect] andReturnValue:@YES] isValidSourceApplication:testSourceApplication];

        BTVenmoAppSwitchHandler *handler = [[BTVenmoAppSwitchHandler alloc] init];
        BOOL handled = [handler canHandleReturnURL:testURL sourceApplication:testSourceApplication];

        expect(handled).to.beTruthy();
    });

    it(@"returns NO if [BTVenmoAppSwitchReturnURL isValidURL:sourceApplication:] returns NO", ^{
        [[[mockVenmoAppSwitchReturnURL expect] andReturnValue:@NO] isValidSourceApplication:testSourceApplication];

        BTVenmoAppSwitchHandler *handler = [[BTVenmoAppSwitchHandler alloc] init];
        BOOL handled = [handler canHandleReturnURL:testURL sourceApplication:testSourceApplication];

        expect(handled).to.beFalsy();
    });
});

describe(@"sharedHandler", ^{

    it(@"returns one and only one instance", ^{
        expect([BTVenmoAppSwitchHandler sharedHandler]).to.beIdenticalTo([BTVenmoAppSwitchHandler sharedHandler]);
    });
    
});


SpecEnd
