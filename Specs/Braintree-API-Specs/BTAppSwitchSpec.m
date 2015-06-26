#import "BTAppSwitch.h"

#import "BTAppSwitching.h"

SpecBegin(BTAppSwitch)

describe(@"handleReturnURL:sourceApplication:", ^{
    context(@"with no AppSwitching", ^{
        it(@"should return NO", ^{
            BOOL handled = [[[BTAppSwitch alloc] init] handleReturnURL:[NSURL URLWithString:@"scheme://"] sourceApplication:@"com.yourcompany.hi"];
            expect(handled).to.beFalsy();
        });
    });

    context(@"with one AppSwitcher that returns YES", ^{
        __block id happyAppSwitcher;
        beforeEach(^{
            happyAppSwitcher = [OCMockObject mockForProtocol:@protocol(BTAppSwitching)];
            [[happyAppSwitcher stub] setReturnURLScheme:OCMOCK_ANY];
            [[[happyAppSwitcher stub] andReturn:[OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)]] delegate];
            [[[happyAppSwitcher stub] andReturnValue:@YES] canHandleReturnURL:OCMOCK_ANY sourceApplication:OCMOCK_ANY];
            [[happyAppSwitcher stub] handleReturnURL:OCMOCK_ANY];
        });

        afterEach(^{
            [happyAppSwitcher verify];
            [happyAppSwitcher stopMocking];
        });

        it(@"should return YES", ^{
            BTAppSwitch *appSwitch;
            appSwitch = [[BTAppSwitch alloc] init];
            [appSwitch addAppSwitching:happyAppSwitcher forApp:0];
            BOOL handled = [appSwitch handleReturnURL:[NSURL new] sourceApplication:@""];
            expect(handled).to.beTruthy();
        });
    });

    pending(@"with one AppSwitcher that returns NO", ^{
        __block id sadAppSwitcher;
        beforeEach(^{
            sadAppSwitcher = [OCMockObject mockForProtocol:@protocol(BTAppSwitching)];
            [[sadAppSwitcher stub] setReturnURLScheme:OCMOCK_ANY];
            [[[sadAppSwitcher stub] andReturn:[OCMockObject mockForProtocol:@protocol(BTAppSwitchingDelegate)]] delegate];
        });

        afterEach(^{
            [sadAppSwitcher verify];
            [sadAppSwitcher stopMocking];
        });

        it(@"should return NO", ^{
            BTAppSwitch *appSwitch;
            appSwitch = [[BTAppSwitch alloc] init];
            [appSwitch addAppSwitching:sadAppSwitcher forApp:0];
            BOOL handled = [appSwitch handleReturnURL:[NSURL new] sourceApplication:@""];
            expect(handled).to.beFalsy();
        });
    });
});

SpecEnd
