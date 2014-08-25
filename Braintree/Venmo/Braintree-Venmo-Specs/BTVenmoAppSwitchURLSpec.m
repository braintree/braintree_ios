#import "BTVenmoAppSwitchURL.h"
#import <UIKit/UIKit.h>

SpecBegin(BTVenmoAppSwitchURL)

describe(@"isAppSwitchAvailable", ^{

    __block id application;

    beforeEach(^{
        application = [OCMockObject mockForClass:[UIApplication class]];
        [[[application stub] andReturn:application] sharedApplication];
    });

    afterEach(^{
        [application verify];
        [application stopMocking];
    });

    it(@"returns YES if application says the Venmo app is available", ^{
        [[[application expect] andReturnValue:@YES] canOpenURL:OCMOCK_ANY];
        expect([BTVenmoAppSwitchURL isAppSwitchAvailable]).to.beTruthy();
    });

    it(@"returns NO if application says the Venmo app is not available", ^{
        [[[application expect] andReturnValue:@NO] canOpenURL:OCMOCK_ANY];
        expect([BTVenmoAppSwitchURL isAppSwitchAvailable]).to.beFalsy();
    });
});

SpecEnd