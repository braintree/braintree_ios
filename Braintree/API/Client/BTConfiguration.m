#import "BTConfiguration.h"
#import "BTAPIResponseParser.h"
#import "BTClientTokenApplePayStatusValueTransformer.h"
#import "BTClientTokenApplePayPaymentNetworksValueTransformer.h"
#import "BTClientTokenBooleanValueTransformer.h"

NSString *const BTConfigurationKeyClientApiURL = @"clientApiUrl";
NSString *const BTConfigurationKeyChallenges = @"challenges";
NSString *const BTConfigurationKeyAnalytics = @"analytics";
NSString *const BTConfigurationKeyURL = @"url";
NSString *const BTConfigurationKeyMerchantId = @"merchantId";

NSString *const BTConfigurationKeyApplePay = @"applePay";
NSString *const BTConfigurationKeyStatus = @"status";
NSString *const BTConfigurationKeyMerchantAccountId = @"merchantAccountId";

NSString *const BTConfigurationKeyPayPalEnabled = @"paypalEnabled";
NSString *const BTConfigurationKeyPayPal = @"paypal";
NSString *const BTConfigurationKeyPayPalClientId = @"clientId";
NSString *const BTConfigurationKeyPayPalDirectBaseUrl = @"directBaseUrl";
NSString *const BTConfigurationKeyPayPalMerchantName = @"displayName";
NSString *const BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl = @"privacyUrl";
NSString *const BTConfigurationKeyPayPalMerchantUserAgreementUrl = @"userAgreementUrl";
NSString *const BTConfigurationKeyPayPalEnvironment = @"environment";

NSString *const BTConfigurationPayPalBraintreeProxyBasePath = @"/v1/";
NSString *const BTConfigurationPayPalEnvironmentCustom = @"custom";
NSString *const BTConfigurationPayPalEnvironmentLive = @"live";
NSString *const BTConfigurationPayPalEnvironmentOffline = @"offline";

NSString *const BTConfigurationKeyPayPalDisableAppSwitch = @"touchDisabled";

NSString *const BTConfigurationKeyVenmo = @"venmo";

NSString *const BTConfigurationKeyCoinbaseEnabled = @"coinbaseEnabled";
NSString *const BTConfigurationKeyCoinbase = @"coinbase";
NSString *const BTConfigurationKeyCoinbaseClientId = @"clientId";
NSString *const BTConfigurationKeyCoinbaseMerchantAccount = @"merchantAccount";
NSString *const BTConfigurationKeyCoinbaseScope = @"scopes";
NSString *const BTConfigurationKeyCoinbaseEnvironment = @"environment";

NSString *const BTConfigurationPayPalNonLiveDefaultValueMerchantName = @"Offline Test Merchant";
NSString *const BTConfigurationPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl = @"http://example.com/privacy";
NSString *const BTConfigurationPayPalNonLiveDefaultValueMerchantUserAgreementUrl = @"http://example.com/tos";

@interface BTConfiguration ()

@property (nonatomic, readwrite, strong) NSURL *clientApiURL;
@property (nonatomic, readwrite, strong) BTAPIResponseParser *configurationParser;

@end

@implementation BTConfiguration

- (instancetype)init {
    return nil;
}

- (instancetype)initWithResponseParser:(BTAPIResponseParser *)responseParser error:(NSError **)error {
    self = [super init];
    if (self) {
        self.configurationParser = responseParser;
        self.clientApiURL = [self.configurationParser URLForKey:BTConfigurationKeyClientApiURL];

        if (![self validateConfiguration:error]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)validateConfiguration:(NSError *__autoreleasing*)error {
    if (error != NULL && *error) {
        return NO;
    }

    if (![self.clientApiURL isKindOfClass:[NSURL class]] || self.clientApiURL.absoluteString.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTServerErrorUnexpectedError
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Invalid configuration: client api url was missing or invalid. Configuration request may have been intercepted. If error persists, contact Braintree support."
                                                }];
        }
        return NO;
    }

    return YES;
}

- (NSString *)merchantId {
    return [self.configurationParser stringForKey:BTConfigurationKeyMerchantId];
}

- (NSString *)merchantAccountId {
    return [self.configurationParser stringForKey:BTConfigurationKeyMerchantAccountId];
}

- (BTClientApplePayStatus)applePayStatus {
#if BT_ENABLE_APPLE_PAY
    return [[self.configurationParser responseParserForKey:BTConfigurationKeyApplePay] integerForKey:@"status" withValueTransformer:[BTClientTokenApplePayStatusValueTransformer sharedInstance]];
#else
    return BTClientApplePayStatusOff;
#endif
}

- (NSString *)applePayCurrencyCode {
    return [[self.configurationParser responseParserForKey:BTConfigurationKeyApplePay] stringForKey:@"currencyCode"];
}

- (NSString *)applePayCountryCode {
    return [[self.configurationParser responseParserForKey:BTConfigurationKeyApplePay] stringForKey:@"countryCode"];
}

- (NSString *)applePayMerchantIdentifier {
    return [[self.configurationParser responseParserForKey:BTConfigurationKeyApplePay] stringForKey:@"merchantIdentifier"];
}

- (NSArray *)applePaySupportedNetworks {
#if BT_ENABLE_APPLE_PAY
    return [[self.configurationParser responseParserForKey:BTConfigurationKeyApplePay] arrayForKey:@"supportedNetworks"
                                                withValueTransformer:[BTClientTokenApplePayPaymentNetworksValueTransformer sharedInstance]];
#else
    return @[];
#endif
}

- (instancetype)copyWithZone:(NSZone *)zone {
    BTConfiguration *copiedConfiguration = [[[self class] allocWithZone:zone] initWithResponseParser:[self.configurationParser copy] error:NULL];
    copiedConfiguration.clientApiURL = self.clientApiURL;
    return copiedConfiguration;
}

- (NSSet *)challenges {
    return [self.configurationParser setForKey:BTConfigurationKeyChallenges];
}

- (BOOL)analyticsEnabled {
    return self.analyticsURL != nil;
}

- (NSURL *)analyticsURL {
    return [[self.configurationParser responseParserForKey:BTConfigurationKeyAnalytics] URLForKey:BTConfigurationKeyURL];
}


#pragma mark JSON Parsing

- (NSDictionary *)parseJSONString:(NSString *)rawJSONString error:(NSError * __autoreleasing *)error {
    NSData *rawJSONData = [rawJSONString dataUsingEncoding:NSUTF8StringEncoding];

    return [NSJSONSerialization JSONObjectWithData:rawJSONData options:0 error:error];
}


#pragma mark NSCoding 

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.clientApiURL forKey:@"clientApiURL"];
    [coder encodeObject:self.configurationParser forKey:@"claims"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self initWithResponseParser:[decoder decodeObjectForKey:@"claims"] error:NULL];
    if (self) {
        self.clientApiURL = [decoder decodeObjectForKey:@"clientApiURL"];
    }
    return self;
}

#pragma mark Configuration Parsing

- (BTAPIResponseParser *)decodeConfiguration:(NSString *)rawConfigurationString error:(NSError * __autoreleasing *)error {
    NSError *JSONError;

    NSDictionary *rawConfiguration = [self parseJSONString:rawConfigurationString error:&JSONError];

    if (!rawConfiguration || ![rawConfiguration isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTServerErrorUnexpectedError
                                     userInfo:@{ NSUnderlyingErrorKey: JSONError,
                                                 NSLocalizedDescriptionKey: @"Invalid configuration. Configuration request may have been intercepted. If this error persists, contact Braintree support.",
                                                 NSLocalizedFailureReasonErrorKey: @"Invalid JSON" }];
        }
        return nil;
    }

    // Note: "version" is intentionally ignored because it doesn't matter

    return [BTAPIResponseParser parserWithDictionary:rawConfiguration];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<BTConfiguration: clientApiURL:%@, analyticsURL:%@>", self.clientApiURL, self.analyticsURL];
}

- (BOOL)isEqualToConfiguration:(BTConfiguration *)configuration {
    return (self.configurationParser == configuration.configurationParser) || [self.configurationParser isEqual:configuration.configurationParser];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if ([object isKindOfClass:[BTConfiguration class]]) {
        return [self isEqualToConfiguration:object];
    }

    return NO;
}


#pragma mark PayPal

- (BTAPIResponseParser *)btPayPal_claims {
    return [self.configurationParser responseParserForKey:BTConfigurationKeyPayPal];
}

- (NSString *)btPayPal_clientId {
    return [self.btPayPal_claims stringForKey:BTConfigurationKeyPayPalClientId];
}

- (NSString *)btPayPal_environment {
    return [self.btPayPal_claims stringForKey:BTConfigurationKeyPayPalEnvironment];
}

- (NSURL *)btPayPal_directBaseURL {
    NSString *apiUrl = [self.btPayPal_claims stringForKey:BTConfigurationKeyPayPalDirectBaseUrl];
    NSURL *directBaseURL;
    if (apiUrl == nil) {
        directBaseURL = nil;
    } else {
        NSString *urlString = [NSString stringWithFormat:@"%@%@", apiUrl, BTConfigurationPayPalBraintreeProxyBasePath];
        directBaseURL = [NSURL URLWithString:urlString];
    }
    return directBaseURL;
}

- (BOOL)btPayPal_isPayPalEnabled {
    return [self.configurationParser boolForKey:BTConfigurationKeyPayPalEnabled
                     withValueTransformer:[BTClientTokenBooleanValueTransformer sharedInstance]];
}

- (BOOL)btPayPal_isTouchDisabled {
    return [self.btPayPal_claims boolForKey:BTConfigurationKeyPayPalDisableAppSwitch
                       withValueTransformer:[BTClientTokenBooleanValueTransformer sharedInstance]];
}

- (BOOL)btPayPal_isLive {
    return [self.btPayPal_environment isEqualToString:BTConfigurationPayPalEnvironmentLive];
}

- (NSString *)btPayPal_merchantName {
    NSString *defaultName = self.btPayPal_isLive ? nil : BTConfigurationPayPalNonLiveDefaultValueMerchantName;
    return [self.btPayPal_claims stringForKey:BTConfigurationKeyPayPalMerchantName] ?: defaultName;
}

- (NSURL *)btPayPal_merchantUserAgreementURL {
    NSURL *defaultURL = self.btPayPal_isLive ? nil : [NSURL URLWithString:BTConfigurationPayPalNonLiveDefaultValueMerchantUserAgreementUrl];

    NSURL *url = [self.btPayPal_claims URLForKey:BTConfigurationKeyPayPalMerchantUserAgreementUrl];

    return url ?: defaultURL;
}

- (NSURL *)btPayPal_privacyPolicyURL {
    NSURL *defaultURL = self.btPayPal_isLive ? nil : [NSURL URLWithString:BTConfigurationPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];

    NSURL *url = [self.btPayPal_claims URLForKey:BTConfigurationKeyPayPalMerchantPrivacyPolicyUrl];

    return url ?: defaultURL;
}

#pragma mark Coinbase

- (BTAPIResponseParser *)coinbaseConfiguration {
    return [self.configurationParser responseParserForKey:BTConfigurationKeyCoinbase];
}

- (BOOL)coinbaseEnabled {
    return ([self coinbaseConfiguration] &&
            [self coinbaseClientId] &&
            [self coinbaseScope] &&
            [self.configurationParser boolForKey:BTConfigurationKeyCoinbaseEnabled
                            withValueTransformer:[BTClientTokenBooleanValueTransformer sharedInstance]]);
}

- (NSString *)coinbaseClientId {
    return [self.coinbaseConfiguration stringForKey:BTConfigurationKeyCoinbaseClientId];
}

- (NSString *)coinbaseMerchantAccount {
    return [self.coinbaseConfiguration stringForKey:BTConfigurationKeyCoinbaseMerchantAccount];
}

- (NSString *)coinbaseScope {
    return [self.coinbaseConfiguration stringForKey:BTConfigurationKeyCoinbaseScope];
}

- (NSString *)coinbaseEnvironment {
    return [self.coinbaseConfiguration stringForKey:BTConfigurationKeyCoinbaseEnvironment];
}

#pragma mark Venmo

- (NSString *)btVenmo_status {
    return [self.configurationParser stringForKey:BTConfigurationKeyVenmo];
}

@end
