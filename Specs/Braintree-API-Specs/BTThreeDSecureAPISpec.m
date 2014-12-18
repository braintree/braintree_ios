#import "BTThreeDSecureLookupResultAPI.h"

SpecBegin(BTThreeDSecureLookupResultAPI)

describe(@"Parsing a 3D Secure Lookup", ^{
    __block BTThreeDSecureLookupResult *lookup;
    __block NSError *error;

    beforeEach(^{
        NSDictionary *validResponse = @{
                                        @"nonce": @"some-valid-nonce",
                                        @"pareq": @"blob-of-data",
                                        @"acsUrl": @"http://example.com/acsurl",
                                        @"termUrl": @"http://example.com/termurl",
                                        };
        lookup = [BTThreeDSecureLookupResultAPI modelWithAPIDictionary:validResponse
                                                           error:&error];

    });

    describe(@"for a valid lookup response", ^{
        it(@"parses the nonce", ^{
            expect(lookup.nonce).to.equal(@"some-valid-nonce");
        });

        it(@"parses the pareq", ^{
            expect(lookup.PAReq).to.equal(@"blob-of-data");
        });

        it(@"parses the acsurl", ^{
            expect(lookup.acsURL).to.equal([NSURL URLWithString:@"http://example.com/acsurl"]);
        });

        it(@"parses the termURL", ^{
            expect(lookup.termURL).to.equal([NSURL URLWithString:@"http://example.com/termurl"]);
        });

        it(@"has no error", ^{
            expect(error).to.beNil();
        });
    });
});

SpecEnd
