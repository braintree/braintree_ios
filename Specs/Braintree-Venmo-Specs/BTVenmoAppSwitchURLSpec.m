#import "BTVenmoAppSwitchRequestURL.h"
#import "BTAppSwitchErrors.h"
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

    __block id mockBundle;
    __block NSError *error;

    beforeEach(^{
        mockBundle = [OCMockObject mockForClass:[NSBundle class]];
        [[[mockBundle stub] andReturn:mockBundle] mainBundle];
    });

    afterEach(^{
        [mockBundle stopMocking];
    });

    context(@"with valid CFBundleDisplayName", ^{

        beforeEach(^{
            [[[mockBundle stub] andReturn:@"Your App"] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        });

        it(@"returns a URL that does not indicate offline mode", ^{
            NSURL *url = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:@"merchant-id"
                                                               returnURLScheme:@"a.scheme"
                                                                       offline:NO
                                                                         error:&error];

            expect(url.uq_queryDictionary[@"offline"]).to.beNil();
            expect(error).to.beNil();
        });

        it(@"returns a URL indicating offline mode", ^{
            NSURL *url = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:@"merchant-id"
                                                               returnURLScheme:@"a.scheme"
                                                                       offline:YES
                                                                         error:&error];

            expect([url.uq_queryDictionary[@"offline"] integerValue]).to.equal(1);
            expect(error).to.beNil();
        });

    });

    it(@"returns an error if CFBundleDisplayName is not set", ^{
        [[[mockBundle stub] andReturn:nil] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSURL *url = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:@"merchant-id"
                                                           returnURLScheme:@"a.scheme"
                                                                   offline:NO
                                                                     error:&error];

        expect(url).to.beNil();
        expect(error.domain).to.equal(BTAppSwitchErrorDomain);
        expect(error.code).to.equal(BTAppSwitchErrorIntegrationInvalidBundleDisplayName);
    });

});

SpecEnd
