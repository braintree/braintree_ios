#import "BTVenmoAppSwitchRequestURL.h"
#import <NSURL+QueryDictionary.h>
#import <UIKit/UIKit.h>

SpecBegin(BTVenmoAppSwitchRequestURL)

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
        expect([BTVenmoAppSwitchRequestURL isAppSwitchAvailable]).to.beTruthy();
    });

    it(@"returns NO if application says the Venmo app is not available", ^{
        [[[application expect] andReturnValue:@NO] canOpenURL:OCMOCK_ANY];
        expect([BTVenmoAppSwitchRequestURL isAppSwitchAvailable]).to.beFalsy();
    });
});

describe(@"appSwitchURLForMerchantID:returnURLScheme:offline:", ^{

    __block NSString *bundleDisplayName = @"Your App";

    beforeEach(^{
        id nsBundle = [OCMockObject mockForClass:[NSBundle class]];
        [[[nsBundle stub] andReturn:nsBundle] mainBundle];
        [[[nsBundle stub] andReturn:bundleDisplayName] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    });

    it(@"returns a URL that does not indicate offline mode", ^{
        NSURL *url = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:@"merchant-id"
                                                           returnURLScheme:@"a.scheme"
                                                                   offline:NO];

        expect(url.uq_queryDictionary[@"offline"]).to.beNil();
    });

    it(@"returns a URL indicating offline mode", ^{
        NSURL *url = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:@"merchant-id"
                                                           returnURLScheme:@"a.scheme"
                                                                   offline:YES];

        expect([url.uq_queryDictionary[@"offline"] integerValue]).to.equal(1);
    });


});


SpecEnd
