#import "BTClientToken.h"
#import "BTErrors.h"
#import "BTTestClientTokenFactory.h"

SpecBegin(BTClientToken)

describe(@"initialization from Base 64 encoded JSON", ^{
    it(@"decodes the client token", ^{
        NSString *clientTokenEncodedJSON = [BTTestClientTokenFactory base64EncodedToken];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenEncodedJSON error:NULL];
        expect(clientToken).to.beKindOf([BTClientToken class]);

        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api"]);
        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key");
    });
});

describe(@"initialization from raw JSON", ^{
    it(@"parses configuration from a client token that includes customer id", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory token];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];

        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api"]);
        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key");
    });

    it(@"parses configuration from a client token that omits customer id", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithoutCustomerIdentifier];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];

        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api"]);
        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&public_key=integration_public_key");
    });

    describe(@"edge cases", ^{
        it(@"returns nil when it receives invalid JSON", ^{
            NSError *error;
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:@"definitely_not_a_client_token" error:&error];

            expect(clientToken).to.beNil();
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
            expect([error localizedDescription]).to.contain(@"client token");
            expect([error.userInfo[NSUnderlyingErrorKey] domain]).to.equal(NSCocoaErrorDomain);
            expect([error.userInfo[NSUnderlyingErrorKey] debugDescription]).to.contain(@"JSON");
        });

        it(@"returns nil when client api url is omitted", ^{
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithoutClientApiUrl];
            NSError *error;
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];

            expect(clientToken).to.beNil();
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect([error localizedDescription]).to.contain(@"client api url");
        });

        it(@"returns nil when authorization fingerprint is omitted", ^{
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithoutAuthorizationFingerprint];

            NSError *error;
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];

            expect(clientToken).to.beNil();
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
            expect([error localizedDescription]).to.contain(@"Invalid client token.");
            expect([error localizedFailureReason]).to.contain(@"Authorization fingerprint");
        });

        it(@"returns nil when client api url is blank", ^{
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithBlankClientApiUrl];
            NSError *error;
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];

            expect(clientToken).to.beNil();
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
            expect([error localizedDescription]).to.contain(@"client api url");
        });

        it(@"returns nil when authorization fingerprint is blank", ^{
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithBlankAuthorizationFingerprint];

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
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithAnalyticsUrl:@"http://analytics.example.com"];
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];
            expect(clientToken.isAnalyticsEnabled).to.beTruthy();
        });

        it(@"returns false otherwise", ^{
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory token];
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];
            expect(clientToken.isAnalyticsEnabled).to.beFalsy();
        });
    });

    describe(@"analytics base url", ^{
        it(@"returns nil when the url is omitted", ^{
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory token];
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];
            expect(clientToken.analyticsURL).to.beNil();
        });

        it(@"returns a parsed URL when the analytics url is included", ^{
            NSString *analyticsUrl = @"http://analytics.example.com/path/to/analytics";
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithAnalyticsUrl:analyticsUrl];
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];

            expect(clientToken.analyticsURL).to.equal([NSURL URLWithString:analyticsUrl]);
        });
    });
});

describe(@"initialization from a raw claims set", ^{
    it(@"creates a client token based on a dictionary of configuration parameters", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:@{ BTClientTokenKeyAuthorizationFingerprint: @"AUTH_FINGERPRINT",
                                                                              BTClientTokenKeyClientApiURL: @"CLIENT_API_URL",
                                                                              BTClientTokenKeyAnalytics: @{ BTClientTokenKeyURL: @"ANALYTICS_URL" }
                                                                              }
                                                                     error:nil];

        expect(clientToken.authorizationFingerprint).to.equal(@"AUTH_FINGERPRINT");
        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"CLIENT_API_URL"]);
        expect(clientToken.analyticsURL).to.equal([NSURL URLWithString:@"ANALYTICS_URL"]);
        expect(clientToken.analyticsEnabled).to.beTruthy();
    });

    it(@"accepts user-defined configuration parameters", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:@{ BTClientTokenKeyAuthorizationFingerprint: @"AUTH_FINGERPRINT",
                                                                              BTClientTokenKeyClientApiURL:@"CLIENT_API_URL",
                                                                              @"custom_key": @"custom_value" }
                                                                     error:nil];
        expect(clientToken.claims[@"custom_key"]).to.equal(@"custom_value");
    });

    it(@"rejects non-string client api url parameters", ^{
        NSError *error;
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:@{ BTClientTokenKeyAuthorizationFingerprint: @"AUTH_FINGERPRINT",
                                                                              BTClientTokenKeyClientApiURL: [OCMockObject mockForClass:[NSObject class]] }
                                                                     error:&error];
        expect(clientToken).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
        expect(error.localizedDescription).to.contain(@"client api url");
    });
});

describe(@"copy", ^{
    __block BTClientToken *clientToken;
    beforeEach(^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory token];
        clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];
    });

    it(@"returns a different instance", ^{
        expect([clientToken copy]).notTo.beIdenticalTo(clientToken);
    });

    it(@"returned instance has equal values and claims", ^{
        BTClientToken *copiedClientToken = [clientToken copy];
        expect(copiedClientToken.clientApiURL).to.equal(clientToken.clientApiURL);
        expect(copiedClientToken.analyticsURL).to.equal(clientToken.analyticsURL);
        expect(copiedClientToken.claims).to.equal(clientToken.claims);
    });
});

SpecEnd