#import "BTClientToken+BTPayPal.h"
#import "PayPalConfiguration.h"

NSString *const BTClientTokenPayPalNamespace = @"paypal";
NSString *const BTClientTokenPayPalKeyClientId = @"clientId";
NSString *const BTClientTokenPayPalKeyDirectBaseUrl = @"directBaseUrl";
NSString *const BTClientTokenPayPalKeyMerchantName = @"displayName";
NSString *const BTClientTokenPayPalKeyMerchantPrivacyPolicyUrl = @"privacyUrl";
NSString *const BTClientTokenPayPalKeyMerchantUserAgreementUrl = @"userAgreementUrl";
NSString *const BTClientTokenPayPalKeyEnvironment = @"environment";
NSString *const BTClientTokenKeyPayPalEnabled = @"paypalEnabled";
NSString *const BTClientTokenPayPalBraintreeProxyBasePath = @"/v1/";
NSString *const BTClientTokenPayPalEnvironmentCustom = @"custom";
NSString *const BTClientTokenPayPalEnvironmentLive = @"live";
NSString *const BTClientTokenPayPalEnvironmentOffline = @"offline";

NSString *const BTClientTokenPayPalNonLiveDefaultValueMerchantName = @"Offline Test Merchant";
NSString *const BTClientTokenPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl = @"http://example.com/privacy";
NSString *const BTClientTokenPayPalNonLiveDefaultValueMerchantUserAgreementUrl = @"http://example.com/tos";

@implementation BTClientToken (BTPayPal)

- (NSString *)btPayPal_clientId {
    return self.btPayPal_claims[BTClientTokenPayPalKeyClientId];
}

-(NSDictionary *)btPayPal_claims{
    return self.claims[BTClientTokenPayPalNamespace];
}

- (NSString*)btPayPal_environment {
    return self.btPayPal_claims[BTClientTokenPayPalKeyEnvironment];
}

- (PayPalConfiguration *)btPayPal_configuration {
    PayPalConfiguration *configuration = [PayPalConfiguration new];
    NSString *privacyPolicyURLString = self.btPayPal_claims[BTClientTokenPayPalKeyMerchantPrivacyPolicyUrl];
    NSString *userAgreementURLString = self.btPayPal_claims[BTClientTokenPayPalKeyMerchantUserAgreementUrl];
    if ([self.btPayPal_environment isEqualToString:BTClientTokenPayPalEnvironmentLive]) {
        configuration.merchantName = self.btPayPal_claims[BTClientTokenPayPalKeyMerchantName];
        configuration.merchantPrivacyPolicyURL = privacyPolicyURLString ? [NSURL URLWithString:privacyPolicyURLString] : nil;
        configuration.merchantUserAgreementURL = userAgreementURLString ? [NSURL URLWithString:userAgreementURLString] : nil;
    } else {
        configuration.merchantName = self.btPayPal_claims[BTClientTokenPayPalKeyMerchantName] ?: BTClientTokenPayPalNonLiveDefaultValueMerchantName;
        configuration.merchantPrivacyPolicyURL = privacyPolicyURLString ? [NSURL URLWithString:privacyPolicyURLString] : [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];
        configuration.merchantUserAgreementURL = userAgreementURLString ? [NSURL URLWithString:userAgreementURLString] : [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantUserAgreementUrl];
    }
    return configuration;
}

- (NSURL *)btPayPal_directBaseURL {
    NSString *apiUrl = self.btPayPal_claims[BTClientTokenPayPalKeyDirectBaseUrl];
    NSURL *directBaseURL;
    if (apiUrl == nil) {
        directBaseURL = nil;
    } else {
        NSString *urlString = [NSString stringWithFormat:@"%@%@", apiUrl, BTClientTokenPayPalBraintreeProxyBasePath];
        directBaseURL = [NSURL URLWithString:urlString];
    }
    return directBaseURL;
}

- (BOOL) btPayPal_isPayPalEnabled{
    return [self.claims[BTClientTokenKeyPayPalEnabled] boolValue];
}

@end
