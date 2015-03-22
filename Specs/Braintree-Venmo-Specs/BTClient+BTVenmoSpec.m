#import "BTClientToken.h"
#import "BTClient+BTVenmo.h"
#import <UIKit/UIKit.h>
#import "BTClient+Offline.h"

NSString *clientTokenStringFromNSDictionary(NSDictionary *dictionary) {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return [data base64EncodedStringWithOptions:0];
}

SpecBegin(BTClient_BTVenmo)

__block NSMutableDictionary *baseClientTokenClaims;

beforeEach(^{

    baseClientTokenClaims = [NSMutableDictionary dictionaryWithDictionary:@{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                                                             BTClientTokenKeyConfigURL: @"https://api.example.com/client_api/v1/configuration",
                                                                             BTClientTokenKeyVersion: @2 }];

});

describe(@"btVenmo_status", ^{

    it(@"returns BTVenmoStatusOff if no key is present", ^{
        NSString *clientTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:baseClientTokenClaims];
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
        expect(client.btVenmo_status).to.equal(BTVenmoStatusOff);
    });

    it(@"returns BTVenmoStatusOff if key is unrecognized", ^{
        baseClientTokenClaims[@"venmo"] = @{@"yo": @"yoyo"};
        NSString *clientTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:baseClientTokenClaims];
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
        expect(client.btVenmo_status).to.equal(BTVenmoStatusOff);
    });

    it(@"returns BTVenmoStatusOff if key is 'off'", ^{
        baseClientTokenClaims[@"venmo"] = @"off";
        NSString *clientTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:baseClientTokenClaims];
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
        expect(client.btVenmo_status).to.equal(BTVenmoStatusOff);
    });

    it(@"returns BTVenmoStatusProduction if key is 'production'", ^{
        baseClientTokenClaims[@"venmo"] = @"production";
        NSString *clientTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:baseClientTokenClaims];
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
        expect(client.btVenmo_status).to.equal(BTVenmoStatusProduction);
    });

    it(@"returns BTVenmoStatusProduction if key is 'offline'", ^{
        baseClientTokenClaims[@"venmo"] = @"offline";
        NSString *clientTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:baseClientTokenClaims];
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
        expect(client.btVenmo_status).to.equal(BTVenmoStatusOffline);
    });

});

SpecEnd
