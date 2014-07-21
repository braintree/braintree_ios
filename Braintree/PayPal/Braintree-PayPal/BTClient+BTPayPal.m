#import "BTClient+BTPayPal.h"
#import "BTClientToken+BTPayPal.h"
#import "BTErrors+BTPayPal.h"

#import <PayPalMobile.h>
#import "BTClient_Internal.h"
#import "BTClient+Offline.h"

NSString *BTClientPayPalMobileEnvironmentName = @"Braintree";
NSString *const BTClientPayPalConfigurationError = @"The PayPal SDK could not be initialized. Perhaps client token did not contain a valid PayPal configuration.";

@implementation BTClient (BTPayPal)

+ (NSString *)btPayPal_offlineTestClientToken {
    NSDictionary *payPalClientTokenData = @{ BTClientTokenPayPalNamespace: @{
                                                     BTClientTokenPayPalKeyMerchantName: @"Offline Test Merchant",
                                                     BTClientTokenPayPalKeyClientId: @"paypal-client-id",
                                                     BTClientTokenPayPalKeyMerchantPrivacyPolicyUrl: @"http://example.com/privacy",
                                                     BTClientTokenPayPalKeyEnvironment: BTClientTokenPayPalEnvironmentOffline,
                                                     BTClientTokenPayPalKeyMerchantUserAgreementUrl: @"http://example.com/tos" }
                                             };

    return [self offlineTestClientTokenWithAdditionalParameters:payPalClientTokenData];
}

- (void)btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)error {
    if ([self.clientToken.btPayPal_environment isEqualToString: BTClientTokenPayPalEnvironmentOffline]) {
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
                                         userInfo:@{ NSLocalizedDescriptionKey: BTClientPayPalConfigurationError}];
            }
        } else {
            [PayPalMobile addEnvironments:@{ BTClientPayPalMobileEnvironmentName:@{
                                                     @"api": [self.clientToken.btPayPal_directBaseURL absoluteString] } }];
            [PayPalMobile initializeWithClientIdsForEnvironments:@{BTClientPayPalMobileEnvironmentName: self.clientToken.btPayPal_clientId}];
            [PayPalMobile preconnectWithEnvironment:BTClientPayPalMobileEnvironmentName];
        }
        
    } else{
        if (error){
            *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                         code:BTMerchantIntegrationErrorPayPalConfiguration
                                     userInfo:@{ NSLocalizedDescriptionKey: BTClientPayPalConfigurationError}];
        }
    }
}

- (PayPalFuturePaymentViewController *)btPayPal_futurePaymentFutureControllerWithDelegate:(id<PayPalFuturePaymentDelegate>)delegate {
    return [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.clientToken.btPayPal_configuration delegate:delegate];
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

@end
