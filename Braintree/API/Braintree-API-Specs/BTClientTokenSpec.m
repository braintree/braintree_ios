#import "BTClientToken.h"
#import "BTErrors.h"
#import "BTTestClientTokenFactory.h"
#import "BTClientApplePayConfiguration.h"

SpecBegin(BTClientToken)

context(@"unsupported versions", ^{
    it(@"rejects unsupported versions", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ @"version": @0 }] error:NULL];
        expect(clientToken).to.beNil();
    });
});

context(@"v1 raw JSON client tokens", ^{
    it(@"can be parsed", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:1 overrides:nil] error:NULL];
        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint");
        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api"]);
        expect(clientToken.analyticsURL).to.equal([NSURL URLWithString:@"https://client-analytics.example.com"]);
        expect(clientToken.configURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"]);
        expect(clientToken.merchantId).to.equal(@"a_merchant_id");
        expect(clientToken.challenges).to.equal([NSSet setWithArray:@[@"cvv"]]);
        expect(clientToken.analyticsEnabled).to.equal(@YES);
        expect(clientToken.applePayConfiguration).to.equal(@{ @"status": @"mock" });
    });
});

context(@"v2 base64 encoded client tokens", ^{
    it(@"can be parsed", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:nil] error:NULL];
        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint");
        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api"]);
        expect(clientToken.analyticsURL).to.equal([NSURL URLWithString:@"https://client-analytics.example.com"]);
        expect(clientToken.configURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"]);
        expect(clientToken.merchantId).to.equal(@"a_merchant_id");
        expect(clientToken.challenges).to.equal([NSSet setWithArray:@[@"cvv"]]);
        expect(clientToken.analyticsEnabled).to.equal(@YES);
        expect(clientToken.applePayConfiguration).to.equal(@{ @"status": @"mock" });
    });

    it(@"must contain a client api url", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyClientApiURL: NSNull.null }];
        NSError *error;
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];

        expect(clientToken).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect([error localizedDescription]).to.contain(@"client api url");
    });

});

context(@"v3 base64 encoded bare-bones client tokens", ^{
    it(@"can be parsed", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:1 overrides:nil] error:NULL];

        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint");
        expect(clientToken.configURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"]);

        expect(clientToken.clientApiURL).to.beNil();
        expect(clientToken.applePayConfiguration).to.beNil();
    });

    it(@"accepts configuration obtained from the configuration endpoint", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:1 overrides:nil] error:NULL];

        [clientToken updateConfiguration:[BTTestClientTokenFactory configuration]];

        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint");
        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api"]);
        expect(clientToken.analyticsURL).to.equal([NSURL URLWithString:@"https://client-analytics.example.com"]);
        expect(clientToken.configURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"]);
        expect(clientToken.merchantId).to.equal(@"a_merchant_id");
        expect(clientToken.challenges).to.equal([NSSet setWithArray:@[@"cvv"]]);
        expect(clientToken.analyticsEnabled).to.equal(@YES);
        expect(clientToken.applePayConfiguration).to.equal(@{ @"status": @"mock" });
    });
});

context(@"edge cases", ^{
    it(@"fails to parse invalid JSON", ^{
        NSError *error;
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:@"definitely_not_a_client_token" error:&error];

        expect(clientToken).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
        expect([error localizedDescription]).to.contain(@"client token");
        expect([error.userInfo[NSUnderlyingErrorKey] domain]).to.equal(NSCocoaErrorDomain);
        expect([error.userInfo[NSUnderlyingErrorKey] debugDescription]).to.contain(@"JSON");
    });

    it(@"returns nil when authorization fingerprint is omitted", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAuthorizationFingerprint: NSNull.null }];

        NSError *error;
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];

        expect(clientToken).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
        expect([error localizedDescription]).to.contain(@"Invalid client token.");
        expect([error localizedFailureReason]).to.contain(@"Authorization fingerprint");
    });

    it(@"returns nil when client api url is blank", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyClientApiURL: @"" }];
        NSError *error;
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];

        expect(clientToken).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
        expect([error localizedDescription]).to.contain(@"client api url");
    });

    it(@"returns nil when authorization fingerprint is blank", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAuthorizationFingerprint: @"" }];

        NSError *error;
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];

        expect(clientToken).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
        expect([error localizedDescription]).to.contain(@"Invalid client token.");
        expect([error localizedFailureReason]).to.contain(@"Authorization fingerprint");
    });
});

describe(@"analytics enabled", ^{
    it(@"returns true when a valid analytics URL is included in the client token", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAnalytics: @{ BTClientTokenKeyURL: @"http://analytics.example.com/events" } }];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];
        expect(clientToken.analyticsEnabled).to.beTruthy();
    });

    it(@"returns false otherwise", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithVersion:2];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];
        expect(clientToken.analyticsEnabled).to.beFalsy();
    });
});

describe(@"coding", ^{
    it(@"roundtrips the clientToken", ^{
        NSString *clientTokenEncodedJSON = [BTTestClientTokenFactory tokenWithVersion:2];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenEncodedJSON error:NULL];

        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [clientToken encodeWithCoder:coder];
        [coder finishEncoding];

        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        BTClientToken *returnedClientToken = [[BTClientToken alloc] initWithCoder:decoder];
        [decoder finishDecoding];

        expect(returnedClientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api"]);
        expect(returnedClientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key");
    });
});

describe(@"isEqual:", ^{
    it(@"returns YES when tokens are identical", ^{
        NSString *clientTokenEncodedJSON = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAuthorizationFingerprint: @"abcd" }];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenEncodedJSON error:NULL];
        BTClientToken *clientToken2 = [[BTClientToken alloc] initWithClientTokenString:clientTokenEncodedJSON error:NULL];

        expect(clientToken).notTo.beNil();

        expect(clientToken).to.equal(clientToken2);
    });

    it(@"returns NO when tokens are different in meaningful ways", ^{
        NSString *clientTokenString1 = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAnalytics: @{ BTClientTokenKeyURL: @"http://some-url" } }];
        NSString *clientTokenString2 = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAnalytics: @{ BTClientTokenKeyURL: @"http://a-different-url" } }];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenString1 error:nil];
        BTClientToken *clientToken2 = [[BTClientToken alloc] initWithClientTokenString:clientTokenString2 error:nil];

        expect(clientToken).notTo.beNil();

        expect(clientToken).notTo.equal(clientToken2);
    });
});

describe(@"copy", ^{
    __block BTClientToken *clientToken;
    beforeEach(^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithVersion:2];
        clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];
    });

    it(@"returns a different instance", ^{
        expect([clientToken copy]).notTo.beIdenticalTo(clientToken);
    });

    pending(@"BTClientToken implementing isEqual:", ^{
        it(@"returns an equal instance", ^{
            expect([clientToken copy]).to.equal(clientToken);
        });
    });

    it(@"returned instance has equal values", ^{
        BTClientToken *copiedClientToken = [clientToken copy];
        expect(copiedClientToken.clientApiURL).to.equal(clientToken.clientApiURL);
        expect(copiedClientToken.analyticsURL).to.equal(clientToken.analyticsURL);
        expect(copiedClientToken.authorizationFingerprint).to.equal(clientToken.authorizationFingerprint);
        expect(copiedClientToken.applePayConfiguration).to.equal(clientToken.applePayConfiguration);
    });
});

SpecEnd
