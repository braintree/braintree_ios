#import "BTClientToken.h"
#import "BTAPIResponseParser.h"
#import "BTClientTokenApplePayStatusValueTransformer.h"
#import "BTClientTokenApplePayPaymentNetworksValueTransformer.h"
#import "BTClientTokenBooleanValueTransformer.h"

NSString *const BTClientTokenKeyAuthorizationFingerprint = @"authorizationFingerprint";
NSString *const BTClientTokenKeyClientApiURL = @"clientApiUrl";
NSString *const BTClientTokenKeyConfigURL = @"configUrl";
NSString *const BTClientTokenKeyChallenges = @"challenges";
NSString *const BTClientTokenKeyAnalytics = @"analytics";
NSString *const BTClientTokenKeyURL = @"url";
NSString *const BTClientTokenKeyMerchantId = @"merchantId";
NSString *const BTClientTokenKeyVersion = @"version";
NSString *const BTClientTokenKeyApplePay = @"applePay";
NSString *const BTClientTokenKeyStatus = @"status";
NSString *const BTClientTokenKeyMerchantAccountId = @"merchantAccountId";

NSString *const BTClientTokenKeyPayPalEnabled = @"paypalEnabled";
NSString *const BTClientTokenKeyPayPal = @"paypal";
NSString *const BTClientTokenKeyPayPalClientId = @"clientId";
NSString *const BTClientTokenKeyPayPalDirectBaseUrl = @"directBaseUrl";
NSString *const BTClientTokenKeyPayPalMerchantName = @"displayName";
NSString *const BTClientTokenKeyPayPalMerchantPrivacyPolicyUrl = @"privacyUrl";
NSString *const BTClientTokenKeyPayPalMerchantUserAgreementUrl = @"userAgreementUrl";
NSString *const BTClientTokenKeyPayPalEnvironment = @"environment";

NSString *const BTClientTokenPayPalBraintreeProxyBasePath = @"/v1/";
NSString *const BTClientTokenPayPalEnvironmentCustom = @"custom";
NSString *const BTClientTokenPayPalEnvironmentLive = @"live";
NSString *const BTClientTokenPayPalEnvironmentOffline = @"offline";

NSString *const BTClientTokenKeyPayPalDisableAppSwitch = @"touchDisabled";

NSString *const BTClientTokenKeyVenmo = @"venmo";

NSString *const BTClientTokenPayPalNonLiveDefaultValueMerchantName = @"Offline Test Merchant";
NSString *const BTClientTokenPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl = @"http://example.com/privacy";
NSString *const BTClientTokenPayPalNonLiveDefaultValueMerchantUserAgreementUrl = @"http://example.com/tos";

@interface BTClientToken ()

@property (nonatomic, readwrite, copy) NSString *authorizationFingerprint;
@property (nonatomic, readwrite, strong) NSURL *clientApiURL;
@property (nonatomic, readwrite, strong) BTAPIResponseParser *configuration;

@end

@implementation BTClientToken

- (instancetype)initWithClientTokenString:(NSString *)JSONString error:(NSError * __autoreleasing *)error {
    self = [super init];
    if (self) {
        self.configuration = [self decodeClientToken:JSONString error:error];
        self.authorizationFingerprint = [self.configuration stringForKey:BTClientTokenKeyAuthorizationFingerprint];
        self.clientApiURL = [self.configuration URLForKey:BTClientTokenKeyClientApiURL];

        if (![self validateClientToken:error]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)validateClientToken:(NSError *__autoreleasing*)error {
    if (error != NULL && *error) {
        return NO;
    }

    if ([self.authorizationFingerprint length] == 0) {
        if (error != NULL) {
        *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTMerchantIntegrationErrorInvalidClientToken
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Invalid client token. Please ensure your server is generating a valid Braintree ClientToken.",
                                                NSLocalizedFailureReasonErrorKey: @"Authorization fingerprint was not present or invalid." }];
        }
        return NO;
    }

    if (![self.clientApiURL isKindOfClass:[NSURL class]] || self.clientApiURL.absoluteString.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTMerchantIntegrationErrorInvalidClientToken
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Invalid client token: client api url was not present or invalid. Please ensure your server is generating a valid Braintree ClientToken."
                                                }];
        }
        return NO;
    }

    return YES;
}

- (NSString *)merchantId {
    return [self.configuration stringForKey:BTClientTokenKeyMerchantId];
}

- (NSString *)merchantAccountId {
    return [self.configuration stringForKey:BTClientTokenKeyMerchantAccountId];
}

- (NSDictionary *)applePayConfiguration {
    return [self.configuration dictionaryForKey:BTClientTokenKeyApplePay];
}

- (BTClientApplePayStatus)applePayStatus {
#if BT_ENABLE_APPLE_PAY
    return [[self.configuration responseParserForKey:BTClientTokenKeyApplePay] integerForKey:@"status" withValueTransformer:[BTClientTokenApplePayStatusValueTransformer sharedInstance]];
#else
    return BTClientApplePayStatusOff;
#endif
}

- (NSString *)applePayCurrencyCode {
    return [[self.configuration responseParserForKey:BTClientTokenKeyApplePay] stringForKey:@"currencyCode"];
}

- (NSString *)applePayCountryCode {
    return [[self.configuration responseParserForKey:BTClientTokenKeyApplePay] stringForKey:@"countryCode"];
}

- (NSString *)applePayMerchantIdentifier {
    return [[self.configuration responseParserForKey:BTClientTokenKeyApplePay] stringForKey:@"merchantIdentifier"];
}

- (NSArray *)applePaySupportedNetworks {
#if BT_ENABLE_APPLE_PAY
    return [[self.configuration responseParserForKey:BTClientTokenKeyApplePay] arrayForKey:@"supportedNetworks"
                                                withValueTransformer:[BTClientTokenApplePayPaymentNetworksValueTransformer sharedInstance]];
#else
    return @[];
#endif
}

- (instancetype)copyWithZone:(NSZone *)zone {
    BTClientToken *copiedClientToken = [[[self class] allocWithZone:zone] init];
    copiedClientToken.authorizationFingerprint = [_authorizationFingerprint copy];
    copiedClientToken.clientApiURL = [_clientApiURL copy];
    copiedClientToken.configuration = [self.configuration copy];
    return copiedClientToken;
}

- (NSSet *)challenges {
    return [self.configuration setForKey:BTClientTokenKeyChallenges];
}

- (BOOL)analyticsEnabled {
    return self.analyticsURL != nil;
}

- (NSURL *)analyticsURL {
    return [[self.configuration responseParserForKey:BTClientTokenKeyAnalytics] URLForKey:BTClientTokenKeyURL];
}

- (NSURL *)configURL {
    return [self.configuration URLForKey:BTClientTokenKeyConfigURL];
}


#pragma mark JSON Parsing

- (NSDictionary *)parseJSONString:(NSString *)rawJSONString error:(NSError * __autoreleasing *)error {
    NSData *rawJSONData = [rawJSONString dataUsingEncoding:NSUTF8StringEncoding];

    return [NSJSONSerialization JSONObjectWithData:rawJSONData options:0 error:error];
}


#pragma mark NSCoding 

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.authorizationFingerprint forKey:@"authorizationFingerprint"];
    [coder encodeObject:self.clientApiURL forKey:@"clientApiURL"];
    [coder encodeObject:self.configuration forKey:@"claims"];
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [self init];
    if (self){
        self.authorizationFingerprint = [decoder decodeObjectForKey:@"authorizationFingerprint"];
        self.clientApiURL = [decoder decodeObjectForKey:@"clientApiURL"];
        self.configuration = [decoder decodeObjectForKey:@"claims"];
    }
    return self;
}

#pragma mark Client Token Parsing

- (BTAPIResponseParser *)decodeClientToken:(NSString *)rawClientTokenString error:(NSError * __autoreleasing *)error {
    NSError *JSONError;
    NSData *base64DecodedClientToken = [[NSData alloc] initWithBase64EncodedString:rawClientTokenString
                                                                           options:0];

    NSDictionary *rawClientToken;
    if (base64DecodedClientToken) {
        rawClientToken = [NSJSONSerialization JSONObjectWithData:base64DecodedClientToken options:0 error:&JSONError];
    } else {
        rawClientToken = [self parseJSONString:rawClientTokenString error:&JSONError];
    }

    if (!rawClientToken) {
        if (error) {
            *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTMerchantIntegrationErrorInvalidClientToken
                                     userInfo:@{ NSUnderlyingErrorKey: JSONError,
                                                 NSLocalizedDescriptionKey: @"Invalid client token. Please ensure your server is generating a valid Braintree ClientToken.",
                                                 NSLocalizedFailureReasonErrorKey: @"Invalid JSON" }];
        }
        return nil;
    }

    if (![rawClientToken isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTMerchantIntegrationErrorInvalidClientToken
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Invalid client token. Please ensure your server is generating a valid Braintree ClientToken.",
                                                NSLocalizedFailureReasonErrorKey: @"Invalid JSON. Expected to find an object at JSON root."
                                                }];
        }
        return nil;
    }

    NSError *clientTokenFormatError = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                          code:BTMerchantIntegrationErrorInvalidClientToken
                                                      userInfo:@{
                                                                 NSLocalizedDescriptionKey: @"Invalid client token format. Please pass the client token string directly as it is generated by the server-side SDK.",
                                                                 NSLocalizedFailureReasonErrorKey: @"Unsupported client token format."
                                                                 }];

    switch ([rawClientToken[BTClientTokenKeyVersion] integerValue]) {
        case 1:
            if (base64DecodedClientToken) {
                if (error) {
                    *error = clientTokenFormatError;
                }
                return nil;
            }
            break;
        case 2:
            /* FALLTHROUGH */
        case 3:
            if (!base64DecodedClientToken) {
                if (error) {
                    *error = clientTokenFormatError;
                }
                return nil;
            }
            break;
        default:
            if (error) {
                *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                             code:BTMerchantIntegrationErrorInvalidClientToken
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Invalid client token version. Please ensure your server is generating a valid Braintree ClientToken with a server-side SDK that is compatible with this version of Braintree iOS.",
                                                    NSLocalizedFailureReasonErrorKey: @"Unsupported client token version."
                                                    }];
            }
            return nil;
    }

    return [BTAPIResponseParser parserWithDictionary:rawClientToken];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<BTClientToken: authorizationFingerprint:%@ configURL:%@, clientApiURL:%@, analyticsURL:%@>", self.authorizationFingerprint, self.configURL, self.clientApiURL, self.analyticsURL];
}

- (BOOL)isEqualToClientToken:(BTClientToken *)clientToken {
    return (self.configuration == clientToken.configuration) || [self.configuration isEqual:clientToken.configuration];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if ([object isKindOfClass:[BTClientToken class]]) {
        return [self isEqualToClientToken:object];
    }

    return NO;
}


#pragma mark PayPal

-(BTAPIResponseParser *)btPayPal_claims {
    return [self.configuration responseParserForKey:BTClientTokenKeyPayPal];
}

- (NSString *)btPayPal_clientId {
    return [self.btPayPal_claims stringForKey:BTClientTokenKeyPayPalClientId];
}

- (NSString *)btPayPal_environment {
    return [self.btPayPal_claims stringForKey:BTClientTokenKeyPayPalEnvironment];
}

- (NSURL *)btPayPal_directBaseURL {
    NSString *apiUrl = [self.btPayPal_claims stringForKey:BTClientTokenKeyPayPalDirectBaseUrl];
    NSURL *directBaseURL;
    if (apiUrl == nil) {
        directBaseURL = nil;
    } else {
        NSString *urlString = [NSString stringWithFormat:@"%@%@", apiUrl, BTClientTokenPayPalBraintreeProxyBasePath];
        directBaseURL = [NSURL URLWithString:urlString];
    }
    return directBaseURL;
}

- (BOOL) btPayPal_isPayPalEnabled {
    return [self.configuration boolForKey:BTClientTokenKeyPayPalEnabled
                     withValueTransformer:[BTClientTokenBooleanValueTransformer sharedInstance]];
}

- (BOOL)btPayPal_isTouchDisabled {
    return [self.btPayPal_claims boolForKey:BTClientTokenKeyPayPalDisableAppSwitch
                       withValueTransformer:[BTClientTokenBooleanValueTransformer sharedInstance]];
}

- (BOOL)btPayPal_isLive {
    return [self.btPayPal_environment isEqualToString:BTClientTokenPayPalEnvironmentLive];
}

- (NSString *)btPayPal_merchantName {
    NSString *defaultName = self.btPayPal_isLive ? nil : BTClientTokenPayPalNonLiveDefaultValueMerchantName;
    return [self.btPayPal_claims stringForKey:BTClientTokenKeyPayPalMerchantName] ?: defaultName;
}

- (NSURL *)btPayPal_merchantUserAgreementURL {
    NSURL *defaultURL = self.btPayPal_isLive ? nil : [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantUserAgreementUrl];

    NSURL *url = [self.btPayPal_claims URLForKey:BTClientTokenKeyPayPalMerchantUserAgreementUrl];

    return url ?: defaultURL;
}

- (NSURL *)btPayPal_privacyPolicyURL {
    NSURL *defaultURL = self.btPayPal_isLive ? nil : [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];

    NSURL *url = [self.btPayPal_claims URLForKey:BTClientTokenKeyPayPalMerchantPrivacyPolicyUrl];

    return url ?: defaultURL;
}


#pragma mark Venmo

- (NSString *)btVenmo_status {
    return [self.configuration stringForKey:BTClientTokenKeyVenmo];
}

@end
