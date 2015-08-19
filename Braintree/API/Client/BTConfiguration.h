#import <Foundation/Foundation.h>

#import "BTClientToken.h"
#import "BTAPIResponseParser.h"
#import "BTErrors.h"

typedef NS_ENUM(NSUInteger, BTClientApplePayStatus) {
    BTClientApplePayStatusOff = 0,
    BTClientApplePayStatusMock = 1,
    BTClientApplePayStatusProduction = 2,
};

extern NSString *const BTConfigurationKeyClientApiURL;
extern NSString *const BTConfigurationKeyChallenges;
extern NSString *const BTConfigurationKeyAnalytics;
extern NSString *const BTConfigurationKeyURL;
extern NSString *const BTConfigurationKeyMerchantId;
extern NSString *const BTConfigurationKeyVersion;
extern NSString *const BTConfigurationKeyApplePay;
extern NSString *const BTConfigurationKeyStatus;
extern NSString *const BTConfigurationKeyMerchantAccountId;

extern NSString *const BTConfigurationKeyPayPal;
extern NSString *const BTConfigurationKeyPayPalClientId;
extern NSString *const BTConfigurationKeyPayPalDirectBaseUrl;
extern NSString *const BTConfigurationKeyPayPalMerchantName;
extern NSString *const BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl;
extern NSString *const BTConfigurationKeyPayPalMerchantUserAgreementUrl;
extern NSString *const BTConfigurationKeyPayPalEnvironment;
extern NSString *const BTConfigurationKeyPayPalEnabled;
extern NSString *const BTConfigurationKeyPayPalCurrencyCode;

extern NSString *const BTConfigurationPayPalEnvironmentCustom;
extern NSString *const BTConfigurationPayPalEnvironmentLive;
extern NSString *const BTConfigurationPayPalEnvironmentOffline;

extern NSString *const BTConfigurationKeyPayPalDisableAppSwitch;

extern NSString *const BTConfigurationKeyVenmo;

extern NSString *const BTConfigurationKeyCoinbaseEnabled;
extern NSString *const BTConfigurationKeyCoinbase;
extern NSString *const BTConfigurationKeyCoinbaseClientId;
extern NSString *const BTConfigurationKeyCoinbaseMerchantAccount;
extern NSString *const BTConfigurationKeyCoinbaseScope;
extern NSString *const BTConfigurationKeyCoinbaseRedirectUri;

// Default PayPal merchant name in offline mode
extern NSString *const BTConfigurationPayPalNonLiveDefaultValueMerchantName;

// Default PayPal privacy policy URL in offline mode
extern NSString *const BTConfigurationPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl;

// Default PayPal user agreement URL in offline mode
extern NSString *const BTConfigurationPayPalNonLiveDefaultValueMerchantUserAgreementUrl;

@interface BTConfiguration : NSObject <NSCoding, NSCopying>

#pragma mark Braintree Client API

@property (nonatomic, readonly, strong) NSURL *clientApiURL;
@property (nonatomic, readonly, strong) NSURL *analyticsURL;
@property (nonatomic, readonly, copy) NSString *merchantId;
@property (nonatomic, readonly, copy) NSString *merchantAccountId;

- (BOOL)analyticsEnabled;

#pragma mark Credit Card Processing

@property (nonatomic, readonly, strong) NSSet *challenges;

#pragma mark PayPal

// Returns the PayPal client id determined by Braintree control panel settings
- (NSString *)payPalClientId;

// Returns a boolean if PayPal is enabled.
- (BOOL)payPalEnabled;

// Returns the PayPal environment name
- (NSString *)payPalEnvironment;

- (NSString *)payPalMerchantName;
- (NSURL *)payPalMerchantUserAgreementURL;
- (NSURL *)payPalPrivacyPolicyURL;
- (NSString *)payPalCurrencyCode;
- (BOOL)payPalUseBillingAgreement;

#pragma mark Coinbase

- (BOOL)coinbaseEnabled;
- (NSString *)coinbaseClientId;
- (NSString *)coinbaseMerchantAccount;
- (NSString *)coinbaseScope;
- (NSString *)coinbaseEnvironment;

#pragma mark Venmo

- (NSString *)btVenmo_status;

#pragma mark Apple Pay

- (BTClientApplePayStatus)applePayStatus;
- (NSString *)applePayCountryCode;
- (NSString *)applePayCurrencyCode;
- (NSString *)applePayMerchantIdentifier;
- (NSArray *)applePaySupportedNetworks;

#pragma mark -

//// Initialize Configuration with a configuration response parser fetched from Braintree.
- (instancetype)initWithResponseParser:(BTAPIResponseParser *)responseParser error:(NSError **)error NS_DESIGNATED_INITIALIZER;

@end
