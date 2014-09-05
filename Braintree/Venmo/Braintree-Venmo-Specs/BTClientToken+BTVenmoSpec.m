#import "BTClientToken+BTVenmo.h"
#import <UIKit/UIKit.h>

SpecBegin(BTClientToken_BTVenmo)

__block NSMutableDictionary *claims;

beforeEach(^{

    claims = [NSMutableDictionary dictionaryWithDictionary:@{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                  BTClientTokenKeyClientApiURL: @"http://gateway.example.com/client_api"}];

});

describe(@"btVenmo_status", ^{

    it(@"returns nil if a 'venmo' key is not present", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:claims error:NULL];
        expect(clientToken.btVenmo_status).to.beNil();
    });

    it(@"returns the value of the 'venmo' key", ^{
        claims[@"venmo"] = @"foo";
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:claims error:NULL];
        expect(clientToken.btVenmo_status).to.equal(@"foo");
    });

    it(@"returns nil if 'venmo' key is not a string", ^{
        claims[@"venmo"] = @{@"not": @"a string"};
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:claims error:NULL];
        expect(clientToken.btVenmo_status).to.beNil();
    });

});

SpecEnd