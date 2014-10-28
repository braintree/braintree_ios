#import "BTClient+BTPayPal.h"
#import "BTErrors+BTPayPal.h"

#import <PayPalMobile.h>
#import "BTClient_Internal.h"
#import "BTClient+Offline.h"

NSString *const BTClientPayPalMobileEnvironmentName = @"Braintree";
NSString *const BTClientPayPalConfigurationError = @"The PayPal SDK could not be initialized. Perhaps client token did not contain a valid PayPal configuration.";

@implementation BTClient (BTPayPal)

+ (NSString *)btPayPal_offlineTestClientToken {
    NSDictionary *payPalClientTokenData = @{ BTClientTokenKeyPayPal: @{
                                                     BTClientTokenKeyPayPalMerchantName: @"Offline Test Merchant",
                                                     BTClientTokenKeyPayPalClientId: @"paypal-client-id",
                                                     BTClientTokenKeyPayPalMerchantPrivacyPolicyUrl: @"http://example.com/privacy",
                                                     BTClientTokenKeyPayPalEnvironment: BTClientTokenPayPalEnvironmentOffline,
                                                     BTClientTokenKeyPayPalMerchantUserAgreementUrl: @"http://example.com/tos" }
                                             };

    return [self offlineTestClientTokenWithAdditionalParameters:payPalClientTokenData];
}

- (BOOL)btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)error {

    if ([self.clientToken.btPayPal_environment isEqualToString:BTClientTokenPayPalEnvironmentOffline]) {
        [PayPalMobile initializeWithClientIdsForEnvironments:@{@"": @""}];
        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
    } else if ([self.clientToken.btPayPal_environment isEqualToString: BTClientTokenPayPalEnvironmentLive]) {
        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction: self.clientToken.btPayPal_clientId}];
        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
    } else if ([self.clientToken.btPayPal_environment isEqualToString: BTClientTokenPayPalEnvironmentCustom]) {
        if (self.clientToken.btPayPal_directBaseURL == nil || self.clientToken.btPayPal_clientId == nil) {
            if (error) {
                *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                             code:BTMerchantIntegrationErrorPayPalConfiguration
                                         userInfo:@{ NSLocalizedDescriptionKey: BTClientPayPalConfigurationError }];
                return NO;
            }
        } else {
            [PayPalMobile addEnvironments:@{ BTClientPayPalMobileEnvironmentName:@{
                                                     @"api": [self.clientToken.btPayPal_directBaseURL absoluteString] } }];
            [PayPalMobile initializeWithClientIdsForEnvironments:@{BTClientPayPalMobileEnvironmentName: self.clientToken.btPayPal_clientId}];
            [PayPalMobile preconnectWithEnvironment:BTClientPayPalMobileEnvironmentName];
        }
    } else {
        if (error){
            *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                         code:BTMerchantIntegrationErrorPayPalConfiguration
                                     userInfo:@{ NSLocalizedDescriptionKey: BTClientPayPalConfigurationError}];
            return NO;
        }
    }

    return YES;
}

- (NSSet *)btPayPal_scopes {
    return [NSSet setWithObjects:kPayPalOAuth2ScopeFuturePayments, kPayPalOAuth2ScopeEmail, nil];
}

- (PayPalProfileSharingViewController *)btPayPal_profileSharingViewControllerWithDelegate:(id<PayPalProfileSharingDelegate>)delegate {
    return [[PayPalProfileSharingViewController alloc] initWithScopeValues:self.btPayPal_scopes
                                                             configuration:self.btPayPal_configuration
                                                                  delegate:delegate];
}

- (BOOL) btPayPal_isPayPalEnabled {
    return self.clientToken.btPayPal_isPayPalEnabled;
}

- (NSString *)btPayPal_applicationCorrelationId {
    NSString *payPalEnvironment = self.clientToken.btPayPal_environment;
    if (![payPalEnvironment isEqualToString:PayPalEnvironmentProduction] && ![payPalEnvironment isEqualToString:PayPalEnvironmentSandbox]) {
        return nil;
    }

    return [PayPalMobile applicationCorrelationIDForEnvironment:self.clientToken.btPayPal_environment];
}

- (PayPalConfiguration *)btPayPal_configuration {
    PayPalConfiguration *configuration = [PayPalConfiguration new];

    if ([self.clientToken.btPayPal_environment isEqualToString: BTClientTokenPayPalEnvironmentLive]) {
        configuration.merchantName = self.clientToken.btPayPal_merchantName;
        configuration.merchantPrivacyPolicyURL = self.clientToken.btPayPal_privacyPolicyURL;
        configuration.merchantUserAgreementURL = self.clientToken.btPayPal_merchantUserAgreementURL;
    } else {
        configuration.merchantName = self.clientToken.btPayPal_merchantName ?: BTClientTokenPayPalNonLiveDefaultValueMerchantName;
        configuration.merchantPrivacyPolicyURL = self.clientToken.btPayPal_privacyPolicyURL ?: [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];
        configuration.merchantUserAgreementURL = self.clientToken.btPayPal_merchantUserAgreementURL ?: [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantUserAgreementUrl];
    }

    return configuration;
}

- (NSString *)btPayPal_environment {
    return [self.clientToken.btPayPal_environment isEqualToString:BTClientTokenPayPalEnvironmentLive] ? PayPalEnvironmentProduction : BTClientPayPalMobileEnvironmentName;
}

- (BOOL)btPayPal_isTouchDisabled {
    return self.clientToken.btPayPal_isTouchDisabled;
}

@end
