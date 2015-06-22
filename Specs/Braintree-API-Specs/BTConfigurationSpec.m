@import PassKit;

#import "BTConfiguration.h"
#import "BTTestClientTokenFactory.h"

NSDictionary *BTConfigurationSpecTestConfiguration() {
    return @{
             @"challenges": @[
                     @"cvv"
                     ],
             @"clientApiUrl": @"https://api.example.com:443/merchants/a_merchant_id/client_api",
             @"assetsUrl": @"https://assets.example.com",
             @"authUrl": @"https://auth.venmo.example.com",
             @"analytics": @{
                     @"url": @"https://client-analytics.example.com"
                     },
             @"threeDSecureEnabled": @NO,
             @"paypalEnabled": @YES,
             @"paypal": @{
                     @"displayName": @"Acme Widgets, Ltd. (Sandbox)",
                     @"clientId": @"a_paypal_client_id",
                     @"privacyUrl": @"http://example.com/pp",
                     @"userAgreementUrl": @"http://example.com/tos",
                     @"baseUrl": @"https://assets.example.com",
                     @"assetsUrl": @"https://checkout.paypal.example.com",
                     @"directBaseUrl": [NSNull null],
                     @"allowHttp": @YES,
                     @"environmentNoNetwork": @YES,
                     @"environment": @"offline",
                     @"merchantAccountId": @"a_merchant_account_id",
                     @"currencyIsoCode": @"USD"
                     },
             @"merchantId": @"a_merchant_id",
             @"venmo": @"offline",
             @"applePay": @{
                     @"status": @"mock",
                     @"countryCode": @"US",
                     @"currencyCode": @"USD",
                     @"merchantIdentifier": @"apple-pay-merchant-id",
                     @"supportedNetworks": @[ @"visa",
                                              @"mastercard",
                                              @"amex" ]
                     
                     },
             @"coinbaseEnabled": @YES,
             @"coinbase": @{
                     @"clientId": @"a_coinbase_client_id",
                     @"merchantAccount": @"coinbase-account@example.com",
                     @"scopes": @"authorizations:braintree user",
                     @"redirectUrl": @"https://assets.example.com/coinbase/oauth/redirect"
                     },
             @"merchantAccountId": @"some-merchant-account-id",
             };
}

SpecBegin(BTConfiguration)

context(@"valid configuration", ^{
    it(@"can be parsed", ^{
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
        dict[@"merchantAccountId"] = @"a_merchant_account_id";
        NSError *error;
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:&error];
        expect(error).to.beNil();
        
        expect(configuration.clientApiURL).to.equal([NSURL URLWithString:@"https://api.example.com:443/merchants/a_merchant_id/client_api"]);
        expect(configuration.analyticsURL).to.equal([NSURL URLWithString:@"https://client-analytics.example.com"]);
        expect(configuration.merchantId).to.equal(@"a_merchant_id");
        expect(configuration.challenges).to.equal([NSSet setWithArray:@[@"cvv"]]);
        expect(configuration.analyticsEnabled).to.equal(@YES);
        expect(configuration.merchantAccountId).to.equal(@"a_merchant_account_id");
        expect(configuration.applePayStatus).to.equal(BTClientApplePayStatusMock);
        expect(configuration.applePayCountryCode).to.equal(@"US");
        expect(configuration.applePayCurrencyCode).to.equal(@"USD");
        expect(configuration.applePayMerchantIdentifier).to.equal(@"apple-pay-merchant-id");
        expect(configuration.applePaySupportedNetworks).to.equal(@[ PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex ]);
    });
    
    it(@"must contain a client api url", ^{
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
        dict[BTConfigurationKeyClientApiURL] = NSNull.null;
        NSError *error;
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:&error];
        expect(configuration).to.beNil();
        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
        expect([error localizedDescription]).to.contain(@"client api url");
    });
});

context(@"edge cases", ^{
    it(@"returns nil when client api url is blank", ^{
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
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
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:BTConfigurationSpecTestConfiguration()] error:&error];
        
        expect(error).to.beNil();
        expect(configuration.analyticsEnabled).to.beTruthy();
    });
    
    it(@"returns false otherwise", ^{
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
        dict[BTConfigurationKeyAnalytics] = NSNull.null;
        
        NSError *error;
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:&error];
        
        expect(error).to.beNil();
        expect(configuration.analyticsEnabled).to.beFalsy();
    });
});

describe(@"coding", ^{
    it(@"roundtrips the configuration", ^{
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
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
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
        dict[BTConfigurationKeyClientApiURL] = @"https://test.api.url/for_testing";
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
        BTConfiguration *configuration2 = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
        expect(configuration).notTo.beNil();
        expect(configuration).to.equal(configuration2);
    });
    
    it(@"returns NO when tokens are different in meaningful ways", ^{
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
        dict[BTConfigurationKeyClientApiURL] = @"https://test.api.url/for_testing";
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
        NSMutableDictionary *dict2 = [BTConfigurationSpecTestConfiguration() mutableCopy];
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
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
        configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
    });
    
    it(@"returns a different instance", ^{
        expect([configuration copy]).notTo.beIdenticalTo(configuration);
    });
    
    it(@"has equal values", ^{
        BTConfiguration *copiedConfiguration = [configuration copy];
        expect(copiedConfiguration.applePayStatus).to.equal(BTClientApplePayStatusMock);
        expect(copiedConfiguration.applePayCountryCode).to.equal(@"US");
        expect(copiedConfiguration.applePayCurrencyCode).to.equal(@"USD");
        expect(copiedConfiguration.applePayMerchantIdentifier).to.equal(@"apple-pay-merchant-id");
        expect(copiedConfiguration.applePaySupportedNetworks).to.equal(@[ PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex ]);
    });
});

describe(@"PayPal", ^{
    __block BTConfiguration *configuration;
    
    beforeEach(^{
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
        configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
    });
    
    describe(@"payPalClientIdentifier", ^{
        it(@"returns the client id as specified by the configuration", ^{
            expect(configuration.payPalClientId).to.equal(@"a_paypal_client_id");
        });
    });
    
    describe(@"payPalEnvironment", ^{
        it(@"returns the PayPal environment as specified by the configuration", ^{
            expect(configuration.payPalEnvironment).to.equal(@"offline");
        });
    });
    
    describe(@"payPalCurrencyCode", ^{
        it(@"returns the PayPal currency code as specified by the configuration", ^{
            expect(configuration.payPalCurrencyCode).to.equal(@"USD");
        });
    });
    
    describe(@"isPayPalEnabled", ^{
        __block BTConfiguration *configurationPayPalDisabled;
        beforeEach(^{
            NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
            [dict setValuesForKeysWithDictionary:@{
                                                   // BTConfiguration should not contain authorization fingerprint.
                                                   //BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                                   BTConfigurationKeyClientApiURL: @"http://gateway.example.com/client_api",
                                                   BTConfigurationKeyPayPalEnabled: @NO }];
            configurationPayPalDisabled = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
        });
        
        it(@"returns false if the paypalEnabled flag is set to False in the configuration", ^{
            expect(configurationPayPalDisabled.payPalEnabled).to.beFalsy();
        });
        
        it(@"returns true if the paypalEnabled flag is set to True in the configuration", ^{
            expect(configuration.payPalEnabled).to.beTruthy();
        });
        
    });
    
    describe(@"payPalMerchantName", ^{
        it(@"returns the merchant name specified by the configuration", ^{
            expect(configuration.payPalMerchantName).to.equal(@"Acme Widgets, Ltd. (Sandbox)");
        });
    });
    
    describe(@"payPalMerchantUserAgreementURL", ^{
        it(@"returns the merchant user agreement URL specified by the configuration", ^{
            expect(configuration.payPalMerchantUserAgreementURL).to.equal([NSURL URLWithString:@"http://example.com/tos"]);
        });
    });
    
    describe(@"payPalPrivacyPolicyURL", ^{
        it(@"returns the merchant privacy policy specified by the configuration", ^{
            expect(configuration.payPalPrivacyPolicyURL).to.equal([NSURL URLWithString:@"http://example.com/pp"]);
        });
        
        describe(@"with missing fields", ^{
            __block BTConfiguration *configurationMissingFields;
            __block NSMutableDictionary *configurationDict;
            __block NSMutableDictionary *payPalDict;
            __block NSURL *defaultUserAgreementURL, *defaultPrivacyPolicyURL;
            beforeEach(^{
                configurationDict = [BTConfigurationSpecTestConfiguration() mutableCopy];
                
                payPalDict = [configurationDict[BTConfigurationKeyPayPal] mutableCopy];
                payPalDict[BTConfigurationKeyPayPalEnvironment] = BTConfigurationPayPalEnvironmentLive;
                [payPalDict removeObjectForKey:BTConfigurationKeyPayPalMerchantName];
                [payPalDict removeObjectForKey:BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl];
                [payPalDict removeObjectForKey:BTConfigurationKeyPayPalMerchantUserAgreementUrl];
                configurationDict[BTConfigurationKeyPayPal] = payPalDict;
                
                [configurationDict setValuesForKeysWithDictionary:@{ BTConfigurationKeyClientApiURL: @"http://gateway.example.com/client_api",
                                                                     BTConfigurationKeyPayPalEnabled: @NO }];
                configurationMissingFields = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:configurationDict] error:NULL];
                
                defaultUserAgreementURL = [NSURL URLWithString:BTConfigurationPayPalNonLiveDefaultValueMerchantUserAgreementUrl];
                defaultPrivacyPolicyURL = [NSURL URLWithString:BTConfigurationPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];
            });
            
            describe(@"live environment", ^{
                it(@"returns a PayPal configuration object with a nil merchant name if not specified in the configuration", ^{
                    expect(configurationMissingFields.payPalMerchantName).to.beNil();
                });
                
                it(@"returns a PayPal configuration object with a nil merchant user agreement url if not specified by the configuration", ^{
                    expect(configurationMissingFields.payPalMerchantUserAgreementURL).to.beNil();
                });
                
                it(@"returns a PayPal configuration object with a nil privacy policy URL if not specified in the configuration", ^{
                    expect(configurationMissingFields.payPalPrivacyPolicyURL).to.beNil();
                });
            });
            
            describe(@"offline environment", ^{
                beforeEach(^{
                    payPalDict[BTConfigurationKeyPayPalEnvironment] = BTConfigurationPayPalEnvironmentOffline;
                    configurationDict[BTConfigurationKeyPayPal] = payPalDict;
                    configurationMissingFields = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:configurationDict] error:NULL];
                });
                
                it(@"returns a PayPal configuration object with an offline default merchant name if not specified in the configuration", ^{
                    expect(configurationMissingFields.payPalMerchantName).to.equal(BTConfigurationPayPalNonLiveDefaultValueMerchantName);
                });
                
                it(@"returns a PayPal configuration object with an offline default merchant user agreement url if not specified by the configuration", ^{
                    expect(configurationMissingFields.payPalMerchantUserAgreementURL).to.equal(defaultUserAgreementURL);
                });
                
                it(@"returns a PayPal configuration object with an offline default privacy policy URL if not specified in the configurationt", ^{
                    expect(configurationMissingFields.payPalPrivacyPolicyURL).to.equal(defaultPrivacyPolicyURL);
                });
            });
            
            describe(@"custom environment", ^{
                beforeEach(^{
                    payPalDict[BTConfigurationKeyPayPalEnvironment] = BTConfigurationPayPalEnvironmentCustom;
                    configurationDict[BTConfigurationKeyPayPal] = payPalDict;
                    configurationMissingFields = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:configurationDict] error:NULL];
                });
                
                it(@"returns a PayPal configuration object with an offline default merchant name if not specified in the configuration", ^{
                    expect(configurationMissingFields.payPalMerchantName).to.equal(BTConfigurationPayPalNonLiveDefaultValueMerchantName);
                });
                
                it(@"returns a PayPal configuration object with an offline default merchant user agreement url if not specified by the configuration", ^{
                    expect(configurationMissingFields.payPalMerchantUserAgreementURL).to.equal(defaultUserAgreementURL);
                });
                
                it(@"returns a PayPal configuration object with an offline default privacy policy URL if not specified in the configuration", ^{
                    expect(configurationMissingFields.payPalPrivacyPolicyURL).to.equal(defaultPrivacyPolicyURL);
                });
            });
        });
    });
    
    describe(@"payPalPrivacyPolicyURL", ^{
        it(@"returns the privacy policy URL specified by the configuration as a URL", ^{
            expect(configuration.payPalPrivacyPolicyURL).to.equal([NSURL URLWithString:@"http://example.com/pp"]);
        });
    });
    
    describe(@"payPalMerchantUserAgreementURL", ^{
        it(@"returns the merchant user agreement URL specified by the configuration as a URL", ^{
            expect(configuration.payPalMerchantUserAgreementURL).to.equal([NSURL URLWithString:@"http://example.com/tos"]);
        });
    });
    
});

describe(@"coinbase", ^{
    __block BTConfiguration *configuration;
    beforeEach(^{
        NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
        configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
    });
    
    describe(@"coinbaseEnabled", ^{
        it(@"is YES when coinbaseEnabled is 1", ^{
            expect(configuration.coinbaseEnabled).to.beTruthy();
        });
        it(@"is NO when coinbaseConfiguration is missing", ^{
            NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
            [dict removeObjectForKey:BTConfigurationKeyCoinbase];
            configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
            expect(configuration.coinbaseEnabled).to.equal(NO);
        });
        it(@"is NO when coinbaseClientId is missing", ^{
            NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
            NSMutableDictionary *coinbaseDict = [dict[BTConfigurationKeyCoinbase] mutableCopy];
            [coinbaseDict removeObjectForKey:BTConfigurationKeyCoinbaseClientId];
            dict[BTConfigurationKeyCoinbase] = coinbaseDict;
            configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
            expect(configuration.coinbaseEnabled).to.equal(NO);
        });
        it(@"is NO when coinbaseScope is missing", ^{
            NSMutableDictionary *dict = [BTConfigurationSpecTestConfiguration() mutableCopy];
            NSMutableDictionary *coinbaseDict = [dict[BTConfigurationKeyCoinbase] mutableCopy];
            [coinbaseDict removeObjectForKey:BTConfigurationKeyCoinbaseScope];
            dict[BTConfigurationKeyCoinbase] = coinbaseDict;
            configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:dict] error:NULL];
            expect(configuration.coinbaseEnabled).to.equal(NO);
        });
        // We don't check for coinbaseMerchantAccount because it may not always be required,
        // i.e. Coinbase could actually know what the coinbaseMerchantAccount should be by
        // looking it up with the coinbaseClientId. We also don't check for coinbaseRedirectUri
        // because we don't use it.
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

describe(@"merchant account id", ^{
    it(@"is optional", ^{
        NSMutableDictionary *testConfiguration = [BTConfigurationSpecTestConfiguration() mutableCopy];
        [testConfiguration removeObjectForKey:BTConfigurationKeyMerchantAccountId];
        BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:testConfiguration] error:NULL];
        expect(configuration).to.beKindOf([BTConfiguration class]);
        expect(configuration.merchantAccountId).to.beNil();
    });
});

describe(@"venmo", ^{
    __block NSDictionary *claims;
    
    beforeEach(^{
        claims = @{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                    BTConfigurationKeyClientApiURL: @"http://gateway.example.com/client_api" };
    });
    
    describe(@"btVenmo_status", ^{
        it(@"returns nil if a 'venmo' key is not present", ^{
            NSMutableDictionary *venmoNotPresentClaims = [claims mutableCopy];
            venmoNotPresentClaims[@"venmo"] = [NSNull null];
            BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:venmoNotPresentClaims] error:NULL];
            expect(configuration.btVenmo_status).to.beNil();
        });
        
        it(@"returns the value of the 'venmo' key", ^{
            NSMutableDictionary *mutableClaims = [claims mutableCopy];
            mutableClaims[@"venmo"] = @"foo";
            BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:mutableClaims] error:NULL];
            expect(configuration.btVenmo_status).to.equal(@"foo");
        });
        
        it(@"returns nil if 'venmo' key is not a string", ^{
            NSMutableDictionary *mutableClaims = [claims mutableCopy];
            mutableClaims[@"venmo"] = @{@"not": @"a string"};
            BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:mutableClaims] error:NULL];
            expect(configuration.btVenmo_status).to.beNil();
        });
    });
});

describe(@"PayPal", ^{
    __block NSMutableDictionary *mutableClaims;
    __block BTConfiguration *configuration;
    
    beforeEach(^{
        waitUntil(^(DoneCallback done) {
            NSMutableDictionary *paypalClaims = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                BTConfigurationKeyPayPalClientId: @"PayPal-Test-Merchant-ClientId",
                                                                                                BTConfigurationKeyPayPalMerchantName: @"PayPal Merchant",
                                                                                                BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl: @"http://merchant.example.com/privacy",
                                                                                                BTConfigurationKeyPayPalMerchantUserAgreementUrl: @"http://merchant.example.com/tos",
                                                                                                BTConfigurationKeyPayPalEnvironment: @"PayPalEnvironmentName"
                                                                                                }];
            
            NSDictionary *baseClaims = @{ BTConfigurationKeyClientApiURL: @"http://gateway.example.com/client_api",
                                          BTConfigurationKeyPayPalEnabled: @YES,
                                          BTConfigurationKeyPayPal: paypalClaims};
            
            mutableClaims = [baseClaims mutableCopy];
            configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:mutableClaims] error:NULL];
            done();
        });
    });
    
    describe(@"payPalClientIdentifier", ^{
        it(@"returns the client id as specified by the client token", ^{
            expect(configuration.payPalClientId).to.equal(@"PayPal-Test-Merchant-ClientId");
        });
    });
    
    describe(@"payPalEnvironment", ^{
        it(@"returns the PayPal environment as specified by the client token", ^{
            expect(configuration.payPalEnvironment).to.equal(@"PayPalEnvironmentName");
        });
    });
    
    describe(@"isPayPalEnabled", ^{
        it(@"returns false if the paypalEnabled flag is set to False in the client Token", ^{
            NSDictionary *baseClaims = @{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                          BTConfigurationKeyClientApiURL: @"http://gateway.example.com/client_api",
                                          BTConfigurationKeyPayPalEnabled: @NO};
            BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:baseClaims] error:NULL];
            
            
            expect(configuration.payPalEnabled).to.beFalsy();
        });
        
        it(@"returns true if the paypalEnabled flag is set to True in the client Token", ^{
            NSDictionary *baseClaims = @{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                          BTConfigurationKeyClientApiURL: @"http://gateway.example.com/client_api",
                                          BTConfigurationKeyPayPalEnabled: @YES};
            BTConfiguration *configuration = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:baseClaims] error:NULL];
            
            expect(configuration.payPalEnabled).to.beTruthy();
        });
    });
    
    describe(@"payPalMerchantName", ^{
        it(@"returns the merchant name specified by the client token", ^{
            expect(configuration.payPalMerchantName).to.equal(@"PayPal Merchant");
        });
    });
    
    describe(@"payPalMerchantUserAgreementURL", ^{
        it(@"returns the merchant user agreement URL specified by the client token", ^{
            expect(configuration.payPalMerchantUserAgreementURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/tos"]);
        });
    });
    
    describe(@"payPalPrivacyPolicyURL", ^{
        it(@"returns the merchant privacy policy specified by the client token", ^{
            expect(configuration.payPalPrivacyPolicyURL).to.equal([NSURL URLWithString:@"http://merchant.example.com/privacy"]);
        });
        
        describe(@"with missing fields", ^{
            __block BTConfiguration *clientTokenMissingFields;
            
            beforeEach(^{
                mutableClaims[BTConfigurationKeyPayPal][BTConfigurationKeyPayPalEnvironment] = @"live";
                [mutableClaims[BTConfigurationKeyPayPal] removeObjectForKey:BTConfigurationKeyPayPalMerchantName];
                [mutableClaims[BTConfigurationKeyPayPal] removeObjectForKey:BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl];
                [mutableClaims[BTConfigurationKeyPayPal] removeObjectForKey:BTConfigurationKeyPayPalMerchantUserAgreementUrl];
                
                clientTokenMissingFields = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:mutableClaims] error:nil];
            });
            
            describe(@"live environment", ^{
                it(@"returns a PayPal configuration object with a nil merchant name if not specified in the client tokent", ^{
                    expect(clientTokenMissingFields.payPalMerchantName).to.beNil();
                });
                
                it(@"returns a PayPal configuration object with a nil merchant user agreement url if not specified by the client token", ^{
                    expect(clientTokenMissingFields.payPalMerchantUserAgreementURL).to.beNil();
                });
                
                it(@"returns a PayPal configuration object with a nil privacy policy URL if not specified in the client tokent", ^{
                    expect(clientTokenMissingFields.payPalPrivacyPolicyURL).to.beNil();
                });
            });
            
            describe(@"offline environment", ^{
                beforeEach(^{
                    mutableClaims[BTConfigurationKeyPayPal][BTConfigurationKeyPayPalEnvironment] = @"offline";
                    clientTokenMissingFields = [[BTConfiguration alloc] initWithResponseParser:[BTAPIResponseParser parserWithDictionary:mutableClaims] error:nil];
                });
            });
        });
    });
});

SpecEnd
