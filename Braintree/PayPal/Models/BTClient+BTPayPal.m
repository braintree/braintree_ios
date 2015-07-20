#import "BTClient+BTPayPal.h"
#import "BTErrors+BTPayPal.h"

#import <PayPalMobile.h>
#import "BTClient_Internal.h"
#import "BTClient+Offline.h"

NSString *const BTClientPayPalMobileEnvironmentName = @"Braintree";
NSString *const BTPayPalScopeAddress = @"address";

NSString *const BTClientPayPalConfigurationError = @"The PayPal SDK could not be initialized. Perhaps client token did not contain a valid PayPal configuration.";

@implementation BTClient (BTPayPal)

+ (NSString *)btPayPal_offlineTestClientToken {
    NSDictionary *payPalClientTokenData = @{ BTConfigurationKeyPayPal: @{
                                                     BTConfigurationKeyPayPalMerchantName: @"Offline Test Merchant",
                                                     BTConfigurationKeyPayPalClientId: @"paypal-client-id",
                                                     BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl: @"http://example.com/privacy",
                                                     BTConfigurationKeyPayPalEnvironment: BTConfigurationPayPalEnvironmentOffline,
                                                     BTConfigurationKeyPayPalMerchantUserAgreementUrl: @"http://example.com/tos" }
                                             };

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self offlineTestClientTokenWithAdditionalParameters:payPalClientTokenData];
#pragma clang diagnostic pop
}

- (BOOL)btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)error {

    if ([self.configuration.btPayPal_environment isEqualToString:BTConfigurationPayPalEnvironmentOffline]) {
        [PayPalMobile initializeWithClientIdsForEnvironments:@{@"": @""}];
        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
    } else if ([self.configuration.btPayPal_environment isEqualToString: BTConfigurationPayPalEnvironmentLive]) {
        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction: self.configuration.btPayPal_clientId}];
        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
    } else if ([self.configuration.btPayPal_environment isEqualToString: BTConfigurationPayPalEnvironmentCustom]) {
        if (self.configuration.btPayPal_directBaseURL == nil || self.configuration.btPayPal_clientId == nil) {
            if (error) {
                *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                             code:BTMerchantIntegrationErrorPayPalConfiguration
                                         userInfo:@{ NSLocalizedDescriptionKey: BTClientPayPalConfigurationError }];
                return NO;
            }
        } else {
            [PayPalMobile addEnvironments:@{ BTClientPayPalMobileEnvironmentName:@{
                                                     @"api": [self.configuration.btPayPal_directBaseURL absoluteString] } }];
            [PayPalMobile initializeWithClientIdsForEnvironments:@{BTClientPayPalMobileEnvironmentName: self.configuration.btPayPal_clientId}];
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
    NSSet *defaultScopes = [NSSet setWithObjects:kPayPalOAuth2ScopeFuturePayments, kPayPalOAuth2ScopeEmail, nil];
    if (self.additionalPayPalScopes != nil) {
        return [self.additionalPayPalScopes setByAddingObjectsFromSet:defaultScopes];
    }
    return defaultScopes;
}

- (PayPalProfileSharingViewController *)btPayPal_profileSharingViewControllerWithDelegate:(id<PayPalProfileSharingDelegate>)delegate {
    return [[PayPalProfileSharingViewController alloc] initWithScopeValues:self.btPayPal_scopes
                                                             configuration:self.btPayPal_configuration
                                                                  delegate:delegate];
}

- (BOOL)btPayPal_isPayPalEnabled {
    return self.configuration.btPayPal_isPayPalEnabled;
}

- (NSString *)btPayPal_applicationCorrelationId {
    NSString *payPalEnvironment = self.configuration.btPayPal_environment;
    if (![payPalEnvironment isEqualToString:PayPalEnvironmentProduction] && ![payPalEnvironment isEqualToString:PayPalEnvironmentSandbox]) {
        return nil;
    }

    return [PayPalMobile clientMetadataID];
}

- (PayPalConfiguration *)btPayPal_configuration {
    PayPalConfiguration *configuration = [PayPalConfiguration new];

    if ([self.configuration.btPayPal_environment isEqualToString: BTConfigurationPayPalEnvironmentLive]) {
        configuration.merchantName = self.configuration.btPayPal_merchantName;
        configuration.merchantPrivacyPolicyURL = self.configuration.btPayPal_privacyPolicyURL;
        configuration.merchantUserAgreementURL = self.configuration.btPayPal_merchantUserAgreementURL;
    } else {
        configuration.merchantName = self.configuration.btPayPal_merchantName ?: BTConfigurationPayPalNonLiveDefaultValueMerchantName;
        configuration.merchantPrivacyPolicyURL = self.configuration.btPayPal_privacyPolicyURL ?: [NSURL URLWithString:BTConfigurationPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];
        configuration.merchantUserAgreementURL = self.configuration.btPayPal_merchantUserAgreementURL ?: [NSURL URLWithString:BTConfigurationPayPalNonLiveDefaultValueMerchantUserAgreementUrl];
    }

    return configuration;
}

- (NSString *)btPayPal_environment {
    return [self.configuration.btPayPal_environment isEqualToString:BTConfigurationPayPalEnvironmentLive] ? PayPalEnvironmentProduction : BTClientPayPalMobileEnvironmentName;
}

- (BOOL)btPayPal_isTouchDisabled {
    return self.configuration.btPayPal_isTouchDisabled;
}

@end
