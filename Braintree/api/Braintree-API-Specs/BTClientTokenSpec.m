#import "BTClientToken.h"
#import "BTErrors.h"
#import "BTTestClientTokenFactory.h"

SpecBegin(BTClientToken)

describe(@"initialization from Base 64 encoded JSON", ^{
    it(@"decodes the client token", ^{
        NSString *clientTokenEncodedJSON = [BTTestClientTokenFactory base64EncodedToken];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenEncodedJSON error:NULL];
        expect(clientToken).to.beKindOf([BTClientToken class]);

        expect(clientToken.authorizationURL).to.equal([NSURL URLWithString:@"https://auth.example.com:1234"]);
        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api"]);
        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key");
    });
});

describe(@"initialization from raw JSON", ^{
    it(@"parses configuration from a client token that includes customer id", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory token];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];

        expect(clientToken.authorizationURL).to.equal([NSURL URLWithString:@"https://auth.example.com:1234"]);
        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api"]);
        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key");
    });

    it(@"parses configuration from a client token that omits customer id", ^{
        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithoutCustomerIdentifier];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:NULL];

        expect(clientToken.authorizationURL).to.equal([NSURL URLWithString:@"https://auth.example.com:1234"]);
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

        it(@"returns nil when auth url is omitted", ^{
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithoutAuthorizationUrl];
            NSError *error;
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];

            expect(clientToken).to.beNil();
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
            expect([error localizedDescription]).to.contain(@"Invalid client token");
            expect([error localizedFailureReason]).to.contain(@"Authorization url");
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

        it(@"returns nil when auth url is blank", ^{
            NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithBlankAuthorizationUrl];
            NSError *error;
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];

            expect(clientToken).to.beNil();
            expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
            expect([error localizedDescription]).to.contain(@"Invalid client token");
            expect([error localizedFailureReason]).to.contain(@"Authorization url");
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
});

describe(@"initialization from a raw claims set", ^{
    it(@"creates a client token based on a dictionary of configuration parameters", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:@{ BTClientTokenKeyAuthorizationFingerprint: @"AUTH_FINGERPRINT",
                                                                                    BTClientTokenKeyAuthorizationURL:@"AUTH_URL",
                                                                                    BTClientTokenKeyClientApiURL: @"CLIENT_API_URL" }
                                                                           error:nil];

        expect(clientToken.authorizationFingerprint).to.equal(@"AUTH_FINGERPRINT");
        expect(clientToken.authorizationURL).to.equal([NSURL URLWithString:@"AUTH_URL"]);
        expect(clientToken.clientApiURL).to.equal([NSURL URLWithString:@"CLIENT_API_URL"]);
    });

    it(@"accepts user-defined configuration parameters", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:@{ BTClientTokenKeyAuthorizationFingerprint: @"AUTH_FINGERPRINT",
                                                                                    BTClientTokenKeyAuthorizationURL:@"AUTH_URL",
                                                                                    BTClientTokenKeyClientApiURL:@"CLIENT_API_URL",
                                                                                    @"custom_key": @"custom_value" }
                                                                           error:nil];
        expect(clientToken.claims[@"custom_key"]).to.equal(@"custom_value");
    });

    it(@"rejects non-string authorizaion url parameters", ^{
        NSError *error;
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:@{ BTClientTokenKeyAuthorizationFingerprint: @"AUTH_FINGERPRINT",
                                                                                    BTClientTokenKeyAuthorizationURL:[OCMockObject mockForClass:[NSObject class]],
                                                                                    BTClientTokenKeyClientApiURL: @"CLIENT_API_URL" }
                                                                           error:&error];
        expect(clientToken).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
        expect(error.localizedDescription).to.contain(@"Invalid client token");
    });

    it(@"rejects non-string client api url parameters", ^{
        NSError *error;
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClaims:@{ BTClientTokenKeyAuthorizationFingerprint: @"AUTH_FINGERPRINT",
                                                                                    BTClientTokenKeyAuthorizationURL:@"AUTH_URL",
                                                                                    BTClientTokenKeyClientApiURL: [OCMockObject mockForClass:[NSObject class]] }
                                                                           error:&error];
        expect(clientToken).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
        expect(error.localizedDescription).to.contain(@"client api url");
    });
});

SpecEnd