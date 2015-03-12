@import PassKit;

#import "BTConfiguration.h"
#import "BTTestClientTokenFactory.h"

SpecBegin(BTConfiguration)

context(@"valid configuration", ^{
    it(@"can be parsed", ^{
        NSError *error;
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:[BTTestClientTokenFactory configuration]] error:&error];
        expect(error).to.beNil();

        expect(configuration.clientApiURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api"]);
        expect(configuration.analyticsURL).to.equal([NSURL URLWithString:@"https://client-analytics.example.com"]);
        expect(configuration.merchantId).to.equal(@"a_merchant_id");
        expect(configuration.challenges).to.equal([NSSet setWithArray:@[@"cvv"]]);
        expect(configuration.analyticsEnabled).to.equal(@YES);
        expect(configuration.merchantAccountId).to.equal(@"a_merchant_account_id");

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        expect(clientToken.applePayConfiguration).to.equal(@{ @"status": @"mock",
//                                                              @"countryCode": @"US",
//                                                              @"currencyCode": @"USD",
//                                                              @"merchantIdentifier": @"apple-pay-merchant-id",
//                                                              @"supportedNetworks": @[ @"visa", @"mastercard", @"amex" ] });
//#pragma clang diagnostic pop

        expect(configuration.applePayStatus).to.equal(BTClientApplePayStatusMock);
        expect(configuration.applePayCountryCode).to.equal(@"US");
        expect(configuration.applePayCurrencyCode).to.equal(@"USD");
        expect(configuration.applePayMerchantIdentifier).to.equal(@"merchant.com.braintreepayments.test");
        expect(configuration.applePaySupportedNetworks).to.equal(@[ PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex ]);
    });

    xit(@"must contain a client api url", ^{
        NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
        dict[BTConfigurationKeyClientApiURL] = NSNull.null;
        NSError *error;
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:&error];
        expect(configuration).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect([error localizedDescription]).to.contain(@"client api url");
    });
});

context(@"edge cases", ^{
    xit(@"returns nil when client api url is blank", ^{
        NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
        dict[BTConfigurationKeyClientApiURL] = @"";
        NSError *error;
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:&error];

        expect(configuration).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect(error.code).to.equal(BTServerErrorUnexpectedError);
        expect([error localizedDescription]).to.contain(@"client api url");
    });
});

describe(@"analytics enabled", ^{
    it(@"returns true when a valid analytics URL is included in configuration", ^{
        NSError *error;
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:[BTTestClientTokenFactory configuration]] error:&error];

        expect(error).to.beNil();
        expect(configuration.analyticsEnabled).to.beTruthy();
    });

    it(@"returns false otherwise", ^{
        NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
        dict[BTConfigurationKeyAnalytics] = NSNull.null;

        NSError *error;
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:&error];

        expect(error).to.beNil();
        expect(configuration.analyticsEnabled).to.beFalsy();
    });
});

describe(@"coding", ^{
    it(@"roundtrips the configuration", ^{
        NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
        dict[BTConfigurationKeyClientApiURL] = @"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api";
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];

        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [configuration encodeWithCoder:coder];
        [coder finishEncoding];

        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        BTConfiguration *returnedConfiguration = [[BTConfiguration alloc] initWithCoder:decoder];
        [decoder finishDecoding];
        expect(returnedConfiguration.clientApiURL).to.equal([NSURL URLWithString:@"https://client.api.example.com:6789/merchants/MERCHANT_ID/client_api"]);
    });
});

describe(@"isEqual:", ^{
    it(@"returns YES when configurations are identical", ^{
        NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
        dict[BTConfigurationKeyClientApiURL] = @"https://test.api.url/for_testing";
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
        BTConfiguration *configuration2 = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
        expect(configuration).notTo.beNil();
        expect(configuration).to.equal(configuration2);
    });

    it(@"returns NO when tokens are different in meaningful ways", ^{
        NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
        dict[BTConfigurationKeyClientApiURL] = @"https://test.api.url/for_testing";
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
        NSMutableDictionary *dict2 = [BTTestClientTokenFactory configuration];
        dict2[BTConfigurationKeyClientApiURL] = @"https://different.test.url/for_different_testing";
        BTConfiguration *configuration2 = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict2] error:NULL];
        expect(configuration).notTo.beNil();
        expect(configuration).notTo.equal(configuration2);

        // Ensure that same dict is not used by configuration object after initialization
        dict[BTConfigurationKeyClientApiURL] = @"https://test.api.url/for_testing";
        expect(configuration).notTo.beNil();
        expect(configuration).notTo.equal(configuration2);

        BTConfiguration *configuration3 = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
        expect(configuration3).notTo.beNil();
        expect(configuration3).notTo.equal(configuration2);
    });
});

describe(@"copy", ^{
    __block BTConfiguration *configuration;
    beforeEach(^{
        NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
        configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
    });

    it(@"returns a different instance", ^{
        expect([configuration copy]).notTo.beIdenticalTo(configuration);
    });
});

describe(@"PayPal", ^{
    __block BTConfiguration *configuration;

    beforeEach(^{
        NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
        configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
    });

    describe(@"btPayPal_payPalClientIdentifier", ^{
        it(@"returns the client id as specified by the client token", ^{
            expect(configuration.btPayPal_clientId).to.equal(@"PayPal-Test-Merchant-ClientId");
        });
    });

    describe(@"btPayPal_environment", ^{
        it(@"returns the PayPal environment as specified by the client token", ^{
            expect(configuration.btPayPal_environment).to.equal(@"PayPalEnvironmentName");
        });
    });

    describe(@"btPayPal_isPayPalEnabled", ^{
        __block BTConfiguration *configurationPayPalDisabled;
        beforeEach(^{
            NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
            [dict setValuesForKeysWithDictionary:@{ //BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint", // BTConfiguration should not contain authorization fingerprint.
                                                    BTConfigurationKeyClientApiURL: @"http://gateway.example.com/client_api",
                                                    BTConfigurationKeyPayPalEnabled: @NO }];
            configurationPayPalDisabled = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
        });

        it(@"returns false if the paypalEnabled flag is set to False in the client Token", ^{
            expect(configurationPayPalDisabled.btPayPal_isPayPalEnabled).to.beFalsy();
        });

        it(@"returns true if the paypalEnabled flag is set to True in the client Token", ^{
            expect(configuration.btPayPal_isPayPalEnabled).to.beTruthy();
        });

    });

    describe(@"btPayPal_merchantName", ^{
        it(@"returns the merchant name specified by the client token", ^{
            expect(configuration.btPayPal_merchantName).to.equal(@"PayPal Merchant");
        });
    });

    describe(@"btPayPal_merchantUserAgreementURL", ^{
        it(@"returns the merchant user agreement URL specified by the client token", ^{
            expect(configuration.btPayPal_merchantUserAgreementURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/tos"]);
        });
    });

    describe(@"btPayPal_privacyPolicyURL", ^{
        it(@"returns the merchant privacy policy specified by the client token", ^{
            expect(configuration.btPayPal_privacyPolicyURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/privacy"]);
        });

        describe(@"with missing fields", ^{
            __block BTConfiguration *configurationMissingFields;
            __block NSMutableDictionary *payPalDict;
            __block NSURL *defaultUserAgreementURL, *defaultPrivacyPolicyURL;
            beforeEach(^{
                NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];

                payPalDict = [dict[BTConfigurationKeyPayPal] mutableCopy];
                payPalDict[BTConfigurationKeyPayPalEnvironment] = BTConfigurationPayPalEnvironmentLive;
                [payPalDict[BTConfigurationKeyPayPal] removeObjectForKey:BTConfigurationKeyPayPalMerchantName];
                [payPalDict[BTConfigurationKeyPayPal] removeObjectForKey:BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl];
                [payPalDict[BTConfigurationKeyPayPal] removeObjectForKey:BTConfigurationKeyPayPalMerchantUserAgreementUrl];
                dict[BTConfigurationKeyPayPal] = payPalDict;

                [dict setValuesForKeysWithDictionary:@{ BTConfigurationKeyClientApiURL: @"http://gateway.example.com/client_api",
                                                        BTConfigurationKeyPayPalEnabled: @NO }];
                configurationMissingFields = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];

                defaultUserAgreementURL = [NSURL URLWithString:BTConfigurationPayPalNonLiveDefaultValueMerchantUserAgreementUrl];
                defaultPrivacyPolicyURL = [NSURL URLWithString:BTConfigurationPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];
            });

            describe(@"live environment", ^{
                it(@"returns a PayPal configuration object with a nil merchant name if not specified in the client tokent", ^{
                    expect(configurationMissingFields.btPayPal_merchantName).to.beNil();
                });

                it(@"returns a PayPal configuration object with a nil merchant user agreement url if not specified by the client token", ^{
                    expect(configurationMissingFields.btPayPal_merchantUserAgreementURL).to.beNil();
                });

                it(@"returns a PayPal configuration object with a nil privacy policy URL if not specified in the client tokent", ^{
                    expect(configurationMissingFields.btPayPal_privacyPolicyURL).to.beNil();
                });
            });

            describe(@"offline environment", ^{
                beforeEach(^{
                    NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
                    payPalDict = [dict[BTConfigurationKeyPayPal] mutableCopy];
                    payPalDict[BTConfigurationKeyPayPalEnvironment] = BTConfigurationPayPalEnvironmentOffline;
                    dict[BTConfigurationKeyPayPal] = payPalDict;
                    configurationMissingFields = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
                });

                it(@"returns a PayPal configuration object with an offline default merchant name if not specified in the client token", ^{
                    expect(configurationMissingFields.btPayPal_merchantName).to.equal(BTConfigurationPayPalNonLiveDefaultValueMerchantName);
                });

                it(@"returns a PayPal configuration object with an offline default merchant user agreement url if not specified by the client token", ^{
                    expect(configurationMissingFields.btPayPal_merchantUserAgreementURL).to.equal(defaultUserAgreementURL);
                });

                it(@"returns a PayPal configuration object with an offline default privacy policy URL if not specified in the client tokent", ^{
                    expect(configurationMissingFields.btPayPal_privacyPolicyURL).to.equal(defaultPrivacyPolicyURL);
                });
            });

            describe(@"custom environment", ^{
                beforeEach(^{
                    NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
                    payPalDict = [dict[BTConfigurationKeyPayPal] mutableCopy];
                    payPalDict[BTConfigurationKeyPayPalEnvironment] = BTConfigurationPayPalEnvironmentCustom;
                    dict[BTConfigurationKeyPayPal] = payPalDict;
                    configurationMissingFields = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
                });

                it(@"returns a PayPal configuration object with an offline default merchant name if not specified in the client tokent", ^{
                    expect(configurationMissingFields.btPayPal_merchantName).to.equal(BTConfigurationPayPalNonLiveDefaultValueMerchantName);
                });

                it(@"returns a PayPal configuration object with an offline default merchant user agreement url if not specified by the client token", ^{
                    expect(configurationMissingFields.btPayPal_merchantUserAgreementURL).to.equal(defaultUserAgreementURL);
                });

                it(@"returns a PayPal configuration object with an offline default privacy policy URL if not specified in the client token", ^{
                    expect(configurationMissingFields.btPayPal_privacyPolicyURL).to.equal(defaultPrivacyPolicyURL);
                });
            });
        });
    });

    describe(@"btPayPal_directBaseURL", ^{
        it(@"returns the directBaseURL specified by the client token", ^{
            expect(configuration.btPayPal_directBaseURL).to.equal([NSURL URLWithString:@"http://api.paypal.example.com/v1/"]);
        });
    });

    describe(@"btPayPal_disableAppSwitch", ^{
        it(@"returns that app switch is not disabled when there is no claim", ^{
            expect(configuration.btPayPal_isTouchDisabled).to.equal(NO);
        });

        it(@"returns that app switch is not disabled when there is no PayPal configuration", ^{
            NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
            [dict removeObjectForKey:BTConfigurationKeyPayPal];
            configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
            expect(configuration.btPayPal_isTouchDisabled).to.equal(NO);
        });

        it(@"returns that app switch is not disabled when there is a claim that is false", ^{
            NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
            dict[BTConfigurationKeyPayPal][BTConfigurationKeyPayPalDisableAppSwitch] = @NO;
            configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
            expect(configuration.btPayPal_isTouchDisabled).to.equal(NO);
        });

        it(@"returns that app switch is disabled when there is a claim that is true", ^{
            NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
            dict[BTConfigurationKeyPayPal][BTConfigurationKeyPayPalDisableAppSwitch] = @YES;
            configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
            expect(configuration.btPayPal_isTouchDisabled).to.equal(YES);
        });

        it(@"returns that app switch is disabled when there is a claim that is 'TRUEDAT'", ^{
            NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
            dict[BTConfigurationKeyPayPal][BTConfigurationKeyPayPalDisableAppSwitch] = @"TRUEDAT";
            configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
            expect(configuration.btPayPal_isTouchDisabled).to.equal(YES);
        });
    });
    
    describe(@"btPayPal_privacyPolicyURL", ^{
        it(@"returns the privacy policy URL specified by the client token as a URL", ^{
            expect(configuration.btPayPal_privacyPolicyURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/privacy"]);
        });
    });
    
    describe(@"btPayPal_merchantUserAgreementURL", ^{
        it(@"returns the merchant user agreement URL specified by the client token as a URL", ^{
            expect(configuration.btPayPal_merchantUserAgreementURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/tos"]);
        });
    });
    
});

describe(@"coinbase", ^{
    __block BTConfiguration *configuration;
    beforeEach(^{
        NSMutableDictionary *dict = [BTTestClientTokenFactory configuration];
        configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
    });

    describe(@"coinbaseEnabled", ^{
        expect(configuration.coinbaseEnabled).to.beTruthy();
    });

    describe(@"coinbaseClientId", ^{
        expect(configuration.coinbaseClientId).to.equal(@"a_coinbase_client_id");
    });

    describe(@"coinbaseMerchantAccount", ^{
        expect(configuration.coinbaseMerchantAccount).to.equal(@"coinbase-account@example.com");
    });

    describe(@"coinbaseScopes", ^{
        expect(configuration.coinbaseScope).to.equal(@"authorizations:braintree user");
    });
});

SpecEnd
