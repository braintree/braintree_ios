#import "BTVenmoAppSwitchURL.h"

SpecBegin(BTVenmoAppSwitchURL)

describe(@"isAppSwitchAvailable", ^{
    it(@"returns YES if application says the Venmo app is available", ^{
        id application = [OCMockObject mockForClass:[NSApplication class]];
        [[[application expect] andReturnValue:@YES] canOpenURL:OCMOCK_ANY];
        expect([BTVenmoAppSwitchURL isAppSwitchAvailable]).to.beTruthy();
        [application verify];
        [application stopMocking];
    });
    it(@"returns YES if application says the Venmo app is not available", ^{
        id application = [OCMockObject mockForClass:[NSApplication class]];
        [[[application expect] andReturnValue:@NO] canOpenURL:OCMOCK_ANY];
        expect([BTVenmoAppSwitchURL isAppSwitchAvailable]).to.beFalsy();
        [application verify];
        [application stopMocking];
    });
});

SpecEnd