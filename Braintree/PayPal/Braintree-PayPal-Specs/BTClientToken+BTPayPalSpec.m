#import "BTClientToken+BTPayPal.h"
#import "PayPalConfiguration.h"

SpecBegin(BTClientToken_BTPayPal)

__block NSMutableDictionary *mutableClaims;
__block BTClientToken *clientToken;
__block BTClientToken *clientTokenOffline;
__block BTClientToken *clientTokenPayPalDisabled;

beforeEach(^AsyncBlock{

    NSMutableDictionary *paypalClaims = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                        BTClientTokenPayPalKeyClientId: @"PayPal-Test-Merchant-ClientId",
                                                                                        BTClientTokenPayPalKeyMerchantName: @"PayPal Merchant",
                                                                                        BTClientTokenPayPalKeyMerchantPrivacyPolicyUrl: @"http://merchant.example.com/privacy",
                                                                                        BTClientTokenPayPalKeyMerchantUserAgreementUrl: @"http://merchant.example.com/tos",
                                                                                        BTClientTokenPayPalKeyEnvironment: @"PayPalEnvironmentName",
                                                                                        BTClientTokenPayPalKeyDirectBaseUrl: @"http://api.paypal.example.com"
                                                                                        }];

     NSDictionary *baseClaims = @{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                                           BTClientTokenKeyClientApiURL: @"http://gateway.example.com/client_api",
                                                           BTClientTokenKeyPayPalEnabled: @YES,
                                                           BTClientTokenPayPalNamespace: paypalClaims};

    mutableClaims = [baseClaims mutableCopy];
    clientToken = [[BTClientToken alloc] initWithClaims:baseClaims
                                                  error:NULL];
    clientTokenOffline = [[BTClientToken alloc] initWithClaims:mutableClaims
                                                         error:nil];
    done();
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
    beforeEach(^{
        NSDictionary *baseClaims = @{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                      BTClientTokenKeyClientApiURL: @"http://gateway.example.com/client_api",
                                      BTClientTokenKeyPayPalEnabled: @NO};

        clientTokenPayPalDisabled = [[BTClientToken alloc] initWithClaims:baseClaims
                                                             error:nil];
    });
    
    it(@"returns false if the paypalEnabled flag is set to False in the client Token", ^{
        expect(clientTokenPayPalDisabled.btPayPal_isPayPalEnabled).to.beFalsy();
    });

    it(@"returns true if the paypalEnabled flag is set to True in the client Token", ^{
        expect(clientToken.btPayPal_isPayPalEnabled).to.beTruthy();
    });

});

describe(@"btPayPal_configuration", ^{

    it(@"returns a PayPal configuration object with a merchant name specified by the client token", ^{
        expect(clientToken.btPayPal_configuration.merchantName).to.equal(@"PayPal Merchant");
    });

    it(@"returns a PayPal configuration object with a merchant user agreement url specified by the client token", ^{
        expect(clientToken.btPayPal_configuration.merchantUserAgreementURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/tos"]);
    });

    it(@"returns a PayPal configuration object with a merchant privacy policy specified by the client token", ^{
        expect(clientToken.btPayPal_configuration.merchantPrivacyPolicyURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/privacy"]);
    });

    describe(@"with missing fields", ^{
        __block BTClientToken *clientTokenMissingFields;
        __block NSURL *defaultUserAgreementURL, *defaultPrivacyPolicyURL;
        beforeEach(^{
            mutableClaims[BTClientTokenPayPalNamespace][BTClientTokenPayPalKeyEnvironment] = BTClientTokenPayPalEnvironmentLive;
            [mutableClaims[BTClientTokenPayPalNamespace] removeObjectForKey:BTClientTokenPayPalKeyMerchantName];
            [mutableClaims[BTClientTokenPayPalNamespace] removeObjectForKey:BTClientTokenPayPalKeyMerchantPrivacyPolicyUrl];
            [mutableClaims[BTClientTokenPayPalNamespace] removeObjectForKey:BTClientTokenPayPalKeyMerchantUserAgreementUrl];

            defaultUserAgreementURL = [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantUserAgreementUrl];
            defaultPrivacyPolicyURL = [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];
            clientTokenMissingFields = [[BTClientToken alloc] initWithClaims:mutableClaims error:nil];
        });

        describe(@"live environment", ^{

            it(@"returns a PayPal configuration object with a nil merchant name if not specified in the client tokent", ^{
                expect(clientTokenMissingFields.btPayPal_configuration.merchantName).to.beNil();
            });

            it(@"returns a PayPal configuration object with a nil merchant user agreement url if not specified by the client token", ^{
                expect(clientTokenMissingFields.btPayPal_configuration.merchantUserAgreementURL).to.beNil();
            });

            it(@"returns a PayPal configuration object with a nil privacy policy URL if not specified in the client tokent", ^{
                expect(clientTokenMissingFields.btPayPal_configuration.merchantPrivacyPolicyURL).to.beNil();
            });
        });

        describe(@"offline environment", ^{
            beforeEach(^{
                mutableClaims[BTClientTokenPayPalNamespace][BTClientTokenPayPalKeyEnvironment] = BTClientTokenPayPalEnvironmentOffline;
                clientTokenMissingFields = [[BTClientToken alloc] initWithClaims:mutableClaims error:nil];
            });

            it(@"returns a PayPal configuration object with a the offline default merchant name if not specified in the client tokent", ^{
                expect(clientTokenMissingFields.btPayPal_configuration.merchantName).to.equal(BTClientTokenPayPalNonLiveDefaultValueMerchantName);
            });

            it(@"returns a PayPal configuration object with a the offline default merchant user agreement url if not specified by the client token", ^{
                expect(clientTokenMissingFields.btPayPal_configuration.merchantUserAgreementURL).to.equal(defaultUserAgreementURL);
            });

            it(@"returns a PayPal configuration object with a the offline default privacy policy URL if not specified in the client tokent", ^{
                expect(clientTokenMissingFields.btPayPal_configuration.merchantPrivacyPolicyURL).to.equal(defaultPrivacyPolicyURL);
            });
        });

        describe(@"custom environment", ^{
            beforeEach(^{
                mutableClaims[BTClientTokenPayPalNamespace][BTClientTokenPayPalKeyEnvironment] = BTClientTokenPayPalEnvironmentCustom;
                clientTokenMissingFields = [[BTClientToken alloc] initWithClaims:mutableClaims error:nil];
            });

            it(@"returns a PayPal configuration object with a the offline default merchant name if not specified in the client tokent", ^{
                expect(clientTokenMissingFields.btPayPal_configuration.merchantName).to.equal(BTClientTokenPayPalNonLiveDefaultValueMerchantName);
            });

            it(@"returns a PayPal configuration object with a the offline default merchant user agreement url if not specified by the client token", ^{
                expect(clientTokenMissingFields.btPayPal_configuration.merchantUserAgreementURL).to.equal(defaultUserAgreementURL);
            });

            it(@"returns a PayPal configuration object with a the offline default privacy policy URL if not specified in the client tokent", ^{
                expect(clientTokenMissingFields.btPayPal_configuration.merchantPrivacyPolicyURL).to.equal(defaultPrivacyPolicyURL);
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
        expect(clientToken.btPayPal_disableAppSwitch).to.equal(NO);
    });

    it(@"returns that app switch is not disabled when there is no PayPal configuration", ^{
        [mutableClaims removeObjectForKey:BTClientTokenPayPalNamespace];
        clientToken = [[BTClientToken alloc] initWithClaims:mutableClaims error:nil];
        expect(clientToken.btPayPal_disableAppSwitch).to.equal(NO);
    });

    it(@"returns that app switch is not disabled when there is a claim that is false", ^{
        mutableClaims[BTClientTokenPayPalNamespace][BTClientTokenPayPalDisableAppSwitch] = @NO;
        clientToken = [[BTClientToken alloc] initWithClaims:mutableClaims error:nil];
        expect(clientToken.btPayPal_disableAppSwitch).to.equal(NO);
    });

    it(@"returns that app switch is disabled when there is a claim that is true", ^{
        mutableClaims[BTClientTokenPayPalNamespace][BTClientTokenPayPalDisableAppSwitch] = @YES;
        clientToken = [[BTClientToken alloc] initWithClaims:mutableClaims error:nil];
        expect(clientToken.btPayPal_disableAppSwitch).to.equal(YES);
    });

    it(@"returns that app switch is disabled when there is a claim that is 'TRUEDAT'", ^{
        mutableClaims[BTClientTokenPayPalNamespace][BTClientTokenPayPalDisableAppSwitch] = @"TRUEDAT";
        clientToken = [[BTClientToken alloc] initWithClaims:mutableClaims error:nil];
        expect(clientToken.btPayPal_disableAppSwitch).to.equal(YES);
    });
});

SpecEnd