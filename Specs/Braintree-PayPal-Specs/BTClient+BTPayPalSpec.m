#import "BTClientToken.h"
#import "BTClient+BTPayPal.h"
#import "PayPalMobile.h"
#import "BTErrors+BTPayPal.h"
#import "BTConfiguration.h"
#import "BTClient+Offline.h"

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

  NSDictionary *baseClaims = @{                                     BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint", // Note: BTConfiguration should not contain authorization fingerprint
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
                BTClient *client = [[BTClient alloc] initWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:mutableClaims]];
              
              
                expect([client btPayPal_environment]).to.equal(PayPalEnvironmentProduction);
            });
        });
    });

    fdescribe(@"with custom PayPal environment", ^{
        it(@"does not return an error with the valid set of claims", ^{
            mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;
//            mutableClaims[@"paypal"][@"clientId"] = @"a_paypal_client_id";
 //           mutableClaims[@"paypal"][@"directBaseU"] = @"http://api.paypal.example.com";
            NSString *clientTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:mutableClaims];
            NSError *error;
            BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
            BOOL success = [client btPayPal_preparePayPalMobileWithError:&error];
            expect(error).to.beNil();
            expect(success).to.beTruthy();
        });

        it(@"returns an error if the client ID is present but the Base URL is missing", ^{
            [mutableClaims[@"paypal"] removeObjectForKey:@"directBaseUrl"];
          mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;
          NSString *clientTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:mutableClaims];
          NSError *error;
          BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];

            BOOL success = [client btPayPal_preparePayPalMobileWithError:&error];

            expect(error.code).to.equal(BTMerchantIntegrationErrorPayPalConfiguration);
            expect(error.userInfo).notTo.beNil();
            expect(success).to.beFalsy();
        });

        it(@"returns an error if the PayPal Base URL is present but the client ID is missing", ^{
            [mutableClaims[@"paypal"] removeObjectForKey:@"clientId"];
          mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;
          NSString *clientTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:mutableClaims];
          NSError *error;
            BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];

            [client btPayPal_preparePayPalMobileWithError:&error];

            expect(error.code).to.equal(BTMerchantIntegrationErrorPayPalConfiguration);
            expect(error.userInfo).notTo.beNil();
        });

        describe(@"btPayPal_payPalEnvironment", ^{
            it(@"returns a pretty custom environment name", ^{
                mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;
              BTClient *client = [[BTClient alloc] initWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:mutableClaims]];
                expect([client btPayPal_environment]).to.equal(BTClientPayPalMobileEnvironmentName);
            });
        });
    });

    describe(@"when the environment is not production", ^{
        describe(@"if the merchant privacy policy URL, merchant agreement URL, merchant name, and client ID are missing", ^{
            it(@"does not return an error", ^{
                [mutableClaims[@"paypal"] removeObjectForKey:BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl];
                [mutableClaims[@"paypal"] removeObjectForKey:BTConfigurationKeyPayPalMerchantUserAgreementUrl];
                [mutableClaims[@"paypal"] removeObjectForKey:BTConfigurationKeyPayPalMerchantName];
                mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentCustom;

                NSString* clientTokenString = clientTokenStringFromNSDictionary(mutableClaims);
                NSError *error;
                BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];

                [client btPayPal_preparePayPalMobileWithError:&error];

                expect(error).to.beNil();
            });
        });

    });
});

describe(@"scopes", ^{
    it(@"includes email and future payments", ^{
      mutableClaims[@"paypal"][@"environment"] = BTConfigurationPayPalEnvironmentLive;
      NSString *clientTokenString = [BTClient offlineTestClientTokenWithAdditionalParameters:mutableClaims];
      BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];

        NSSet *scopes = [client btPayPal_scopes];
        expect(scopes).to.contain(kPayPalOAuth2ScopeEmail);
        expect(scopes).to.contain(kPayPalOAuth2ScopeFuturePayments);
    });
});

SpecEnd
