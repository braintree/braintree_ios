#import "BTThreeDSecureLookupResult.h"

SpecBegin(BTThreeDSecureLookupResult)

describe(@"requiresUserAuthentication", ^{
    it(@"returns YES when the acs url is present", ^{
        BTThreeDSecureLookupResult *lookup = [[BTThreeDSecureLookupResult alloc] init];
        lookup.acsURL = [NSURL URLWithString:@"http://example.com"];
        lookup.termURL = [NSURL URLWithString:@"http://example.com"];
        lookup.MD = @"an-md";
        lookup.PAReq = @"a-PAReq";

        expect(lookup.requiresUserAuthentication).to.beTruthy();
    });
    it(@"returns NO when the acs url is not present", ^{
        BTThreeDSecureLookupResult *lookup = [[BTThreeDSecureLookupResult alloc] init];
        lookup.acsURL = nil;
        lookup.termURL = [NSURL URLWithString:@"http://example.com"];
        lookup.MD = @"an-md";
        lookup.PAReq = @"a-PAReq";

        expect(lookup.requiresUserAuthentication).to.beFalsy();
    });
});

SpecEnd
