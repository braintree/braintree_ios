@import PassKit;

#import "BTClientToken.h"
#import "BTTestClientTokenFactory.h"

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
        expect(clientToken.configURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"]);
    });
});

context(@"v2 base64 encoded client tokens", ^{
    it(@"can be parsed", ^{
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:nil] error:NULL];
        expect(clientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint");
        expect(clientToken.configURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration"]);
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

//    it(@"returns nil when client api url is blank", ^{
//        NSString *clientTokenRawJSON = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTConfigurationKeyClientApiURL: @"" }];
//        NSError *error;
//        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenRawJSON error:&error];
//
//        expect(clientToken).to.beNil();
//        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
//        expect(error.code).to.equal(BTMerchantIntegrationErrorInvalidClientToken);
//        expect([error localizedDescription]).to.contain(@"client api url");
//    });

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

//describe(@"coding", ^{
//    xit(@"roundtrips the clientToken", ^{
//        NSString *clientTokenEncodedJSON = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTConfigurationKeyClientApiURL: @"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api",
//                                                                                                     BTClientTokenKeyAuthorizationFingerprint: @"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key" }];
//        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenEncodedJSON error:NULL];
//
//        NSMutableData *data = [NSMutableData data];
//        NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//        [clientToken encodeWithCoder:coder];
//        [coder finishEncoding];
//
//        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//        BTClientToken *returnedClientToken = [[BTClientToken alloc] initWithCoder:decoder];
//        [decoder finishDecoding];
//
////        expect(returnedClientToken.clientApiURL).to.equal([NSURL URLWithString:@"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api"]);
//        expect(returnedClientToken.authorizationFingerprint).to.equal(@"an_authorization_fingerprint|created_at=2014-02-12T18:02:30+0000&customer_id=1234567&public_key=integration_public_key");
//    });
//});

describe(@"isEqual:", ^{
    it(@"returns YES when tokens are identical", ^{
        NSString *clientTokenEncodedJSON = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTClientTokenKeyAuthorizationFingerprint: @"abcd" }];
        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenEncodedJSON error:NULL];
        BTClientToken *clientToken2 = [[BTClientToken alloc] initWithClientTokenString:clientTokenEncodedJSON error:NULL];

        expect(clientToken).notTo.beNil();

        expect(clientToken).to.equal(clientToken2);
    });

//    it(@"returns NO when tokens are different in meaningful ways", ^{
//        NSString *clientTokenString1 = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTConfigurationKeyAnalytics: @{ BTClientTokenKeyURL: @"http://some-url" } }];
//        NSString *clientTokenString2 = [BTTestClientTokenFactory tokenWithVersion:2 overrides:@{ BTConfigurationKeyAnalytics: @{ BTClientTokenKeyURL: @"http://a-different-url" } }];
//        BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenString1 error:nil];
//        BTClientToken *clientToken2 = [[BTClientToken alloc] initWithClientTokenString:clientTokenString2 error:nil];
//
//        expect(clientToken).notTo.beNil();
//
//        expect(clientToken).notTo.equal(clientToken2);
//    });
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

    it(@"returns an equal instance", ^{
        expect([clientToken copy]).to.equal(clientToken);
    });

    it(@"returned instance has equal values", ^{
        BTClientToken *copiedClientToken = [clientToken copy];
//        expect(copiedClientToken.clientApiURL).to.equal(clientToken.clientApiURL);
//        expect(copiedClientToken.analyticsURL).to.equal(clientToken.analyticsURL);
        expect(copiedClientToken.authorizationFingerprint).to.equal(clientToken.authorizationFingerprint);

        // TODO: compare configUrl

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        expect(copiedClientToken.applePayConfiguration).to.equal(clientToken.applePayConfiguration);
//#pragma clang diagnostic pop
//        expect(copiedClientToken.applePayStatus).to.equal(BTClientApplePayStatusMock);
//        expect(copiedClientToken.applePayCountryCode).to.equal(@"US");
//        expect(copiedClientToken.applePayCurrencyCode).to.equal(@"USD");
//        expect(copiedClientToken.applePayMerchantIdentifier).to.equal(@"apple-pay-merchant-id");
//        expect(copiedClientToken.applePaySupportedNetworks).to.equal(@[ PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex ]);
    });
});

SpecEnd
