#import "BTClientToken.h"

@class PayPalConfiguration;

extern NSString *const BTClientTokenPayPalNamespace;
extern NSString *const BTClientTokenPayPalKeyClientId;
extern NSString *const BTClientTokenPayPalKeyDirectBaseUrl;
extern NSString *const BTClientTokenPayPalKeyMerchantName;
extern NSString *const BTClientTokenPayPalKeyMerchantPrivacyPolicyUrl;
extern NSString *const BTClientTokenPayPalKeyMerchantUserAgreementUrl;
extern NSString *const BTClientTokenPayPalKeyEnvironment;
extern NSString *const BTClientTokenKeyPayPalEnabled;
extern NSString *const BTClientTokenPayPalEnvironmentCustom;
extern NSString *const BTClientTokenPayPalEnvironmentLive;
extern NSString *const BTClientTokenPayPalEnvironmentOffline;

// Default PayPal merchant name in offline mode
extern NSString *const BTClientTokenPayPalNonLiveDefaultValueMerchantName;

// Default PayPal privacy policy URL in offline mode
extern NSString *const BTClientTokenPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl;

// Default PayPal user agreement URL in offline mode
extern NSString *const BTClientTokenPayPalNonLiveDefaultValueMerchantUserAgreementUrl;

// Extensions to client token that interpret the PayPal specific
// configuration variables in the client token.
@interface BTClientToken (BTPayPal)

// Returns the PayPal client id determined by Braintree that
// can be used when initializing `PayPalMobile`.
//
// `nil` if PayPal is not enabled for the merchant.
- (NSString *)btPayPal_clientId;

// Returns a boolean if PayPal is enabled.
- (BOOL) btPayPal_isPayPalEnabled;

// Returns the PayPal environment name
- (NSString *)btPayPal_environment;

// Returns a `PayPalConfiguration` with preset configuration options
// determined by Braintree.
- (PayPalConfiguration *)btPayPal_configuration;

// Returns the base URL determined by Braintree that points
// to a PayPal stage to be used in when configuring `PayPalMobile`.
//
// @see PayPalMobile.h
//
// @return the PayPal stage URL, including a version path appropriate for the vendored PayPal mSDK, or `nil` if mock mode should be used
- (NSURL *)btPayPal_directBaseURL;

@end
