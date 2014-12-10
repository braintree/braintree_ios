#import "BTThreeDSecureLookup.h"

SpecBegin(BTThreeDSecureLookup)

describe(@"requiresUserAuthentication", ^{
    it(@"returns YES when the acs url is present", ^{
        BTThreeDSecureLookup *lookup = [[BTThreeDSecureLookup alloc] init];
        lookup.acsURL = [NSURL URLWithString:@"http://example.com"];
        lookup.termURL = [NSURL URLWithString:@"http://example.com"];
        lookup.nonce = @"a-nonce";
        lookup.PAReq = @"a-PAReq";

        expect(lookup.requiresUserAuthentication).to.beTruthy();
    });
    it(@"returns NO when the acs url is not present", ^{
        BTThreeDSecureLookup *lookup = [[BTThreeDSecureLookup alloc] init];
        lookup.acsURL = nil;
        lookup.termURL = [NSURL URLWithString:@"http://example.com"];
        lookup.nonce = @"a-nonce";
        lookup.PAReq = @"a-PAReq";

        expect(lookup.requiresUserAuthentication).to.beFalsy();
    });
});

SpecEnd
