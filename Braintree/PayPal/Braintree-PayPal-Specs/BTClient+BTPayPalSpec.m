#import "BTClient+BTPayPal.h"
#import "PayPalMobile.h"
#import "BTErrors+BTPayPal.h"
#import "BTClientToken+BTPayPal.h"

NSString *clientTokenStringFromNSDictionary(NSDictionary *dictionary) {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


SpecBegin(BTClient_BTPayPal)

describe(@"btPayPal_preparePayPalMobileWithError", ^{

    __block NSMutableDictionary *mutableClaims;

    beforeEach(^{

        NSDictionary *paypalClaims = @{
                                       BTClientTokenPayPalKeyClientId: @"PayPal-Test-Merchant-ClientId",
                                       BTClientTokenPayPalKeyMerchantName: @"PayPal Merchant",
                                       BTClientTokenPayPalKeyMerchantPrivacyPolicyUrl: @"http://merchant.example.com/privacy",
                                       BTClientTokenPayPalKeyMerchantUserAgreementUrl: @"http://merchant.example.com/tos",
                                       BTClientTokenPayPalKeyEnvironment: BTClientTokenPayPalEnvironmentCustom,
                                       BTClientTokenPayPalKeyDirectBaseUrl: @"http://api.paypal.example.com" };

        NSDictionary *baseClaims = @{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                      BTClientTokenKeyClientApiURL: @"http://gateway.example.com/client_api",
                                      BTClientTokenKeyPayPalEnabled: @YES,
                                      BTClientTokenPayPalNamespace: [paypalClaims mutableCopy]};


        mutableClaims = [baseClaims mutableCopy];
    });

    describe(@"with custom PayPal environment", ^{
        it(@"does not return an error with the valid set of claims", ^{
            NSString *clientTokenString = clientTokenStringFromNSDictionary(mutableClaims);
            NSError *error;
            BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];
            BOOL success = [client btPayPal_preparePayPalMobileWithError: &error];
            expect(error).to.beNil();
            expect(success).to.beTruthy();
        });

        it(@"returns an error if the client ID is present but the Base URL is missing", ^{
            [mutableClaims[@"paypal"] removeObjectForKey:@"directBaseUrl"];
            NSString *clientTokenString = clientTokenStringFromNSDictionary(mutableClaims);
            NSError *error;
            BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];

            BOOL success = [client btPayPal_preparePayPalMobileWithError: &error];

            expect(error.code).to.equal(BTMerchantIntegrationErrorPayPalConfiguration);
            expect(error.userInfo).notTo.beNil;
            expect(success).to.beFalsy();
        });

        it(@"returns an error if the PayPal Base URL is present but the client ID is missing", ^{
            [mutableClaims[@"paypal"] removeObjectForKey:@"clientId"];
            NSString *clientTokenString = clientTokenStringFromNSDictionary(mutableClaims);
            NSError *error;
            BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];

            [client btPayPal_preparePayPalMobileWithError: &error];

            expect(error.code).to.equal(BTMerchantIntegrationErrorPayPalConfiguration);
            expect(error.userInfo).notTo.beNil;
        });
    });

    describe(@"when the environment is not production", ^{
        describe(@"if the merchant privacy policy URL, merchant agreement URL, merchant name, and client ID are missing", ^{
            it(@"does not return an error", ^{
                [mutableClaims[@"paypal"] removeObjectForKey:BTClientTokenPayPalKeyMerchantPrivacyPolicyUrl];
                [mutableClaims[@"paypal"] removeObjectForKey:BTClientTokenPayPalKeyMerchantUserAgreementUrl];
                [mutableClaims[@"paypal"] removeObjectForKey:BTClientTokenPayPalKeyMerchantName];
                mutableClaims[@"paypal"][@"environment"] = BTClientTokenPayPalEnvironmentCustom;

                NSString* clientTokenString = clientTokenStringFromNSDictionary(mutableClaims);
                NSError *error;
                BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenString];

                [client btPayPal_preparePayPalMobileWithError: &error];

                expect(error).to.beNil();
            });
        });
    });



});

SpecEnd