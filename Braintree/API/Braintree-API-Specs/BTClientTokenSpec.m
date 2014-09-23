#import "BTClientToken.h"
//#import "BTErrors.h"
#import "BTTestClientTokenFactory.h"
//#import "BTClientApplePayConfiguration.h"

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

describe(@"venmo", ^{
    __block NSDictionary *claims;

    beforeEach(^{
        claims = @{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                    BTClientTokenKeyClientApiURL: @"http://gateway.example.com/client_api" };
    });

    describe(@"btVenmo_status", ^{
        it(@"returns nil if a 'venmo' key is not present", ^{
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:claims] error:NULL];
            expect(clientToken.btVenmo_status).to.beNil();
        });

        it(@"returns the value of the 'venmo' key", ^{
            NSMutableDictionary *mutableClaims = [claims mutableCopy];
            mutableClaims[@"venmo"] = @"foo";
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims] error:NULL];
            expect(clientToken.btVenmo_status).to.equal(@"foo");
        });

        it(@"returns nil if 'venmo' key is not a string", ^{
            NSMutableDictionary *mutableClaims = [claims mutableCopy];
            mutableClaims[@"venmo"] = @{@"not": @"a string"};
            BTClientToken *clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims] error:NULL];
            expect(clientToken.btVenmo_status).to.beNil();
        });
    });
});

describe(@"PayPal", ^{
    __block NSMutableDictionary *mutableClaims;
    __block BTClientToken *clientToken;

    beforeEach(^{
        waitUntil(^(DoneCallback done) {
            NSMutableDictionary *paypalClaims = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                BTClientTokenKeyPayPalClientId: @"PayPal-Test-Merchant-ClientId",
                                                                                                BTClientTokenKeyPayPalMerchantName: @"PayPal Merchant",
                                                                                                BTClientTokenKeyPayPalMerchantPrivacyPolicyUrl: @"http://merchant.example.com/privacy",
                                                                                                BTClientTokenKeyPayPalMerchantUserAgreementUrl: @"http://merchant.example.com/tos",
                                                                                                BTClientTokenKeyPayPalEnvironment: @"PayPalEnvironmentName",
                                                                                                BTClientTokenKeyPayPalDirectBaseUrl: @"http://api.paypal.example.com"
                                                                                                }];
            
            NSDictionary *baseClaims = @{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                          BTClientTokenKeyClientApiURL: @"http://gateway.example.com/client_api",
                                          BTClientTokenKeyPayPalEnabled: @YES,
                                          BTClientTokenKeyPayPal: paypalClaims};
            
            mutableClaims = [baseClaims mutableCopy];
            
            
            
            clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:baseClaims] error:NULL];
            done();
        });
    });

    describe(@"btPayPal_payPalClientIdentifier", ^{
        it(@"returns the client id as specified by the client token", ^{
            expect(clientToken.btPayPal_clientId).to.equal(@"PayPal-Test-Merchant-ClientId");
        });
    });

    describe(@"btPayPal_environment", ^{
        it(@"returns the PayPal environment as specified by the client token", ^{
            expect(clientToken.btPayPal_environment).to.equal(@"PayPalEnvironmentName");
        });
    });

    describe(@"btPayPal_isPayPalEnabled", ^{
    __block BTClientToken *clientTokenPayPalDisabled;
        beforeEach(^{
            NSDictionary *baseClaims = @{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                          BTClientTokenKeyClientApiURL: @"http://gateway.example.com/client_api",
                                          BTClientTokenKeyPayPalEnabled: @NO};

            clientTokenPayPalDisabled = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:baseClaims]
                                                                                   error:NULL];
        });

        it(@"returns false if the paypalEnabled flag is set to False in the client Token", ^{
            expect(clientTokenPayPalDisabled.btPayPal_isPayPalEnabled).to.beFalsy();
        });

        it(@"returns true if the paypalEnabled flag is set to True in the client Token", ^{
            expect(clientToken.btPayPal_isPayPalEnabled).to.beTruthy();
        });

    });

    describe(@"btPayPal_merchantName", ^{
        it(@"returns the merchant name specified by the client token", ^{
            expect(clientToken.btPayPal_merchantName).to.equal(@"PayPal Merchant");
        });
    });

    describe(@"btPayPal_merchantUserAgreementURL", ^{
        it(@"returns the merchant user agreement URL specified by the client token", ^{
            expect(clientToken.btPayPal_merchantUserAgreementURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/tos"]);
        });
    });

    describe(@"btPayPal_privacyPolicyURL", ^{
        it(@"returns the merchant privacy policy specified by the client token", ^{
            expect(clientToken.btPayPal_privacyPolicyURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/privacy"]);
        });

        describe(@"with missing fields", ^{
            __block BTClientToken *clientTokenMissingFields;
            __block NSURL *defaultUserAgreementURL, *defaultPrivacyPolicyURL;
            beforeEach(^{
                mutableClaims[BTClientTokenKeyPayPal][BTClientTokenKeyPayPalEnvironment] = BTClientTokenPayPalEnvironmentLive;
                [mutableClaims[BTClientTokenKeyPayPal] removeObjectForKey:BTClientTokenKeyPayPalMerchantName];
                [mutableClaims[BTClientTokenKeyPayPal] removeObjectForKey:BTClientTokenKeyPayPalMerchantPrivacyPolicyUrl];
                [mutableClaims[BTClientTokenKeyPayPal] removeObjectForKey:BTClientTokenKeyPayPalMerchantUserAgreementUrl];

                defaultUserAgreementURL = [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantUserAgreementUrl];
                defaultPrivacyPolicyURL = [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];
                clientTokenMissingFields = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims] error:nil];
            });

            describe(@"live environment", ^{
                it(@"returns a PayPal configuration object with a nil merchant name if not specified in the client tokent", ^{
                    expect(clientTokenMissingFields.btPayPal_merchantName).to.beNil();
                });

                it(@"returns a PayPal configuration object with a nil merchant user agreement url if not specified by the client token", ^{
                    expect(clientTokenMissingFields.btPayPal_merchantUserAgreementURL).to.beNil();
                });

                it(@"returns a PayPal configuration object with a nil privacy policy URL if not specified in the client tokent", ^{
                    expect(clientTokenMissingFields.btPayPal_privacyPolicyURL).to.beNil();
                });
            });

            describe(@"offline environment", ^{
                beforeEach(^{
                    mutableClaims[BTClientTokenKeyPayPal][BTClientTokenKeyPayPalEnvironment] = BTClientTokenPayPalEnvironmentOffline;
                    clientTokenMissingFields = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims] error:nil];
                });

                it(@"returns a PayPal configuration object with a the offline default merchant name if not specified in the client tokent", ^{
                    expect(clientTokenMissingFields.btPayPal_merchantName).to.equal(BTClientTokenPayPalNonLiveDefaultValueMerchantName);
                });

                it(@"returns a PayPal configuration object with a the offline default merchant user agreement url if not specified by the client token", ^{
                    expect(clientTokenMissingFields.btPayPal_merchantUserAgreementURL).to.equal(defaultUserAgreementURL);
                });

                it(@"returns a PayPal configuration object with a the offline default privacy policy URL if not specified in the client tokent", ^{
                    expect(clientTokenMissingFields.btPayPal_privacyPolicyURL).to.equal(defaultPrivacyPolicyURL);
                });
            });

            describe(@"custom environment", ^{
                beforeEach(^{
                    mutableClaims[BTClientTokenKeyPayPal][BTClientTokenKeyPayPal] = BTClientTokenPayPalEnvironmentCustom;
                    clientTokenMissingFields = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims] error:nil];
                });

                it(@"returns a PayPal configuration object with a the offline default merchant name if not specified in the client tokent", ^{
                    expect(clientTokenMissingFields.btPayPal_merchantName).to.equal(BTClientTokenPayPalNonLiveDefaultValueMerchantName);
                });

                it(@"returns a PayPal configuration object with a the offline default merchant user agreement url if not specified by the client token", ^{
                    expect(clientTokenMissingFields.btPayPal_merchantUserAgreementURL).to.equal(defaultUserAgreementURL);
                });

                it(@"returns a PayPal configuration object with a the offline default privacy policy URL if not specified in the client tokent", ^{
                    expect(clientTokenMissingFields.btPayPal_privacyPolicyURL).to.equal(defaultPrivacyPolicyURL);
                });
            });
        });
    });

    describe(@"btPayPal_directBaseURL", ^{
        it(@"returns the directBaseURL specified by the client token", ^{
            expect(clientToken.btPayPal_directBaseURL).to.equal([NSURL URLWithString:@"http://api.paypal.example.com/v1/"]);
        });
    });

    describe(@"btPayPal_disableAppSwitch", ^{
        it(@"returns that app switch is not disabled when there is no claim", ^{
            expect(clientToken.btPayPal_isTouchDisabled).to.equal(NO);
        });

        it(@"returns that app switch is not disabled when there is no PayPal configuration", ^{
            [mutableClaims removeObjectForKey:BTClientTokenKeyPayPal];
            clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims] error:nil];
            expect(clientToken.btPayPal_isTouchDisabled).to.equal(NO);
        });

        it(@"returns that app switch is not disabled when there is a claim that is false", ^{
            mutableClaims[BTClientTokenKeyPayPal][BTClientTokenKeyPayPalDisableAppSwitch] = @NO;
            clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims] error:nil];
            expect(clientToken.btPayPal_isTouchDisabled).to.equal(NO);
        });

        it(@"returns that app switch is disabled when there is a claim that is true", ^{
            mutableClaims[BTClientTokenKeyPayPal][BTClientTokenKeyPayPalDisableAppSwitch] = @YES;
            clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims] error:nil];
            expect(clientToken.btPayPal_isTouchDisabled).to.equal(YES);
        });

        it(@"returns that app switch is disabled when there is a claim that is 'TRUEDAT'", ^{
            mutableClaims[BTClientTokenKeyPayPal][BTClientTokenKeyPayPalDisableAppSwitch] = @"TRUEDAT";
            clientToken = [[BTClientToken alloc] initWithClientTokenString:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims] error:nil];
            expect(clientToken.btPayPal_isTouchDisabled).to.equal(YES);
        });
    });
    
    describe(@"btPayPal_privacyPolicyURL", ^{
        it(@"returns the privacy policy URL specified by the client token as a URL", ^{
            expect(clientToken.btPayPal_privacyPolicyURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/privacy"]);
        });
    });
    
    describe(@"btPayPal_merchantUserAgreementURL", ^{
        it(@"returns the merchant user agreement URL specified by the client token as a URL", ^{
            expect(clientToken.btPayPal_merchantUserAgreementURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/tos"]);
        });
    });
    
});

SpecEnd