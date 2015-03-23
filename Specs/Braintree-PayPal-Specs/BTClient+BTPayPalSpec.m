#import "BTClientToken.h"
#import "BTClient+BTPayPal.h"
#import "PayPalMobile.h"
#import "BTErrors+BTPayPal.h"
#import "BTTestClientTokenFactory.h"
#import "BTConfiguration.h"

NSString *clientTokenStringFromNSDictionary(NSDictionary *dictionary) {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return [data base64EncodedStringWithOptions:0];
}

SpecBegin(BTClient_BTPayPal)

__block NSMutableDictionary *mutableClaims;

beforeEach(^{

    NSDictionary *paypalClaims = @{
                                   BTConfigurationKeyPayPalMerchantName: @"PayPal Merchant",
                                   BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl: @"http://merchant.example.com/privacy",
                                   BTConfigurationKeyPayPalMerchantUserAgreementUrl: @"http://merchant.example.com/tos",
                                   BTConfigurationKeyPayPalClientId: @"PayPal-Test-Merchant-ClientId",
                                   BTConfigurationKeyPayPalDirectBaseUrl: @"http://api.paypal.example.com"
                                   };

    NSDictionary *baseClaims = @{
                                    BTConfigurationKeyClientApiURL: @"http://gateway.example.com/client_api",
                                    BTConfigurationKeyPayPalEnabled: @YES,
                                    BTConfigurationKeyPayPal: [paypalClaims mutableCopy] };


    mutableClaims = [baseClaims mutableCopy];
});


describe(@"btPayPal_preparePayPalMobileWithError", ^{

    describe(@"in Live PayPal environment", ^{
        describe(@"btPayPal_payPalEnvironment", ^{
            it(@"returns PayPal mSDK notion of Live", ^{
                mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentLive;
                BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims]];
                expect([client btPayPal_environment]).to.equal(PayPalEnvironmentProduction);
            });
        });
    });

    describe(@"with custom PayPal environment", ^{
        it(@"does not return an error with the valid set of claims", ^{
            mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;
            BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims]];
            NSError *error;
            BOOL success = [client btPayPal_preparePayPalMobileWithError:&error];
            expect(error).to.beNil();
            expect(success).to.beTruthy();
        });

        it(@"returns an error if the client ID is present but the Base URL is missing", ^{
            mutableClaims[@"paypal"][@"directBaseUrl"] = [NSNull null];
            mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;
            NSError *error;
            BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims]];

            BOOL success = [client btPayPal_preparePayPalMobileWithError:&error];

            expect(error.code).to.equal(BTMerchantIntegrationErrorPayPalConfiguration);
            expect(error.userInfo).notTo.beNil();
            expect(success).to.beFalsy();
        });

        it(@"returns an error if the PayPal Base URL is present but the client ID is missing", ^{
            mutableClaims[@"paypal"][@"clientId"] = [NSNull null];
            mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;
            NSError *error;
            BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims]];

            [client btPayPal_preparePayPalMobileWithError:&error];

            expect(error.code).to.equal(BTMerchantIntegrationErrorPayPalConfiguration);
            expect(error.userInfo).notTo.beNil();
        });

        describe(@"btPayPal_payPalEnvironment", ^{
            it(@"returns a pretty custom environment name", ^{
                mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;
                BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims]];
                expect([client btPayPal_environment]).to.equal(BTClientPayPalMobileEnvironmentName);
            });
        });
    });

    describe(@"when the environment is not production", ^{
        describe(@"if the merchant privacy policy URL, merchant agreement URL, merchant name, and client ID are missing", ^{
            it(@"does not return an error", ^{
                mutableClaims[@"paypal"][BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl] = [NSNull null];
                mutableClaims[@"paypal"][BTConfigurationKeyPayPalMerchantUserAgreementUrl] = [NSNull null];
                mutableClaims[@"paypal"][BTConfigurationKeyPayPalMerchantName] = [NSNull null];

                mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;

                NSError *error;
                BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims]];

                [client btPayPal_preparePayPalMobileWithError:&error];

                expect(error).to.beNil();
            });
        });

    });
});

describe(@"scopes", ^{
    it(@"includes email and future payments", ^{
        mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentLive;
        BTClient *client = [[BTClient alloc] initWithClientToken:[BTTestClientTokenFactory tokenWithVersion:2 overrides:mutableClaims]];

        NSSet *scopes = [client btPayPal_scopes];
        expect(scopes).to.contain(kPayPalOAuth2ScopeEmail);
        expect(scopes).to.contain(kPayPalOAuth2ScopeFuturePayments);
    });
});

SpecEnd
