#import "BTClientToken.h"
#import "BTClient+BTVenmo.h"
#import <UIKit/UIKit.h>
#import "BTTestClientTokenFactory.h"
#import "BTConfiguration.h"

SpecBegin(BTClient_BTVenmo)

describe(@"btVenmo_status", ^{

    it(@"returns BTVenmoStatusOff if no key is present", ^{
        NSString *clientTokenString = [BTTestClientTokenFactory tokenWithVersion:2
                                                                       overrides:@{ BTConfigurationKeyVenmo: [NSNull null] }];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
#pragma clang diagnostic pop
        expect(client.btVenmo_status).to.equal(BTVenmoStatusOff);
    });

    it(@"returns BTVenmoStatusOff if key is unrecognized", ^{
        NSString *clientTokenString = [BTTestClientTokenFactory tokenWithVersion:2
                                                                       overrides:@{BTConfigurationKeyVenmo:@{@"yo": @"yoyo"}}];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
#pragma clang diagnostic pop
        expect(client.btVenmo_status).to.equal(BTVenmoStatusOff);
    });

    it(@"returns BTVenmoStatusOff if key is 'off'", ^{
        NSString *clientTokenString = [BTTestClientTokenFactory tokenWithVersion:2
                                                                       overrides:@{BTConfigurationKeyVenmo:@"off"}];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
#pragma clang diagnostic pop
        expect(client.btVenmo_status).to.equal(BTVenmoStatusOff);
    });

    it(@"returns BTVenmoStatusProduction if key is 'production'", ^{
        NSString *clientTokenString = [BTTestClientTokenFactory tokenWithVersion:2
                                                                       overrides:@{BTConfigurationKeyVenmo:@"production"}];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
#pragma clang diagnostic pop
        expect(client.btVenmo_status).to.equal(BTVenmoStatusProduction);
    });

    it(@"returns BTVenmoStatusProduction if key is 'offline'", ^{
        NSString *clientTokenString = [BTTestClientTokenFactory tokenWithVersion:2
                                                                       overrides:@{BTConfigurationKeyVenmo:@"offline"}];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
#pragma clang diagnostic pop
        expect(client.btVenmo_status).to.equal(BTVenmoStatusOffline);
    });

});

SpecEnd
