#import "BTClientToken.h"

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
@property (nonatomic, readwrite, strong) NSMutableDictionary *configuration;

- (NSDictionary *)decodeClientToken:(NSString *)rawClientTokenString error:(NSError **)error;

- (NSString *)parseAuthorizationFingerprint:(NSString *)authorizationFingerprint error:(NSError **)error;
- (NSURL *)parseAuthorizationURL:(NSString *)authorizationURLString error:(NSError **)error;
- (NSURL *)parseClientApiURL:(NSString *)clientApiURLString error:(NSError **)error;

@end

@implementation BTClientToken

- (instancetype)initWithClientTokenString:(NSString *)JSONString error:(NSError * __autoreleasing *)error {
    NSDictionary *configuration = [self decodeClientToken:JSONString error:error];

    if (!configuration) {
        return nil;
    }

    self = [super init];
    if (self) {
        self.authorizationFingerprint = [self parseAuthorizationFingerprint:configuration[BTClientTokenKeyAuthorizationFingerprint]
                                                                      error:error];
        self.clientApiURL = [self parseClientApiURL:([configuration[BTClientTokenKeyClientApiURL] isKindOfClass:[NSString class]] ? configuration[BTClientTokenKeyClientApiURL]: nil)
                                              error:error];

        if (!self.authorizationFingerprint || !self.clientApiURL) {
            if (error && !*error) {
                *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain code:BTMerchantIntegrationErrorInvalidClientToken userInfo:nil];
            }
            return nil;
        }

        self.configuration = [configuration mutableCopy];
    }
    return self;
}

- (NSString *)merchantId {
    return self.configuration[BTClientTokenKeyMerchantId];
}

- (NSDictionary *)applePayConfiguration {
    return self.configuration[BTClientTokenKeyApplePay];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    BTClientToken *copiedClientToken = [[[self class] allocWithZone:zone] init];
    copiedClientToken.authorizationFingerprint = [_authorizationFingerprint copy];
    copiedClientToken.clientApiURL = [_clientApiURL copy];
    copiedClientToken.configuration = [self.configuration copy];
    return copiedClientToken;
}

- (NSSet *)challenges {
    return [NSSet setWithArray:self.configuration[BTClientTokenKeyChallenges]];
}

- (BOOL)analyticsEnabled {
    return [self.configuration[BTClientTokenKeyAnalytics] isKindOfClass:[NSDictionary class]] && [self.configuration[BTClientTokenKeyAnalytics][BTClientTokenKeyURL] isKindOfClass:[NSString class]];
}

- (NSURL *)analyticsURL {
    return [NSURL URLWithString:self.configuration[BTClientTokenKeyAnalytics][BTClientTokenKeyURL]];
}

- (NSURL *)configURL {
    NSString *configURLString = self.configuration[BTClientTokenKeyConfigURL];
    return [NSURL URLWithString:configURLString];
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

- (NSDictionary *)decodeClientToken:(NSString *)rawClientTokenString error:(NSError * __autoreleasing *)error {
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

    return rawClientToken;
}

- (NSString *)parseAuthorizationFingerprint:(NSString *)authorizationFingerprint error:(NSError * __autoreleasing *)error {
    if ([authorizationFingerprint length] == 0) {
        if (error) {
            *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTMerchantIntegrationErrorInvalidClientToken
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Invalid client token. Please ensure your server is generating a valid Braintree ClientToken.",
                                                NSLocalizedFailureReasonErrorKey: @"Authorization fingerprint was not present or invalid." }];
        }
        return nil;
    }
    return authorizationFingerprint;
}

- (NSURL *)parseAuthorizationURL:(NSString *)authorizationURLString error:(NSError * __autoreleasing *)error {
    NSURL *authorizationURL = [authorizationURLString length] > 0 ? [NSURL URLWithString:authorizationURLString] : nil;
    if (!authorizationURL) {
        if (error) {
            *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTMerchantIntegrationErrorInvalidClientToken
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Invalid client token. Please ensure your server is generating a valid Braintree ClientToken.",
                                                NSLocalizedFailureReasonErrorKey: @"Authorization url was not present or invalid."
                                                }];
        }
        return nil;
    }

    return authorizationURL;
}

- (NSURL *)parseClientApiURL:(NSString *)clientApiURLString error:(NSError * __autoreleasing *)error {
    NSURL *clientApiURL = [clientApiURLString length] > 0 ? [NSURL URLWithString:clientApiURLString] : nil;

    if (!clientApiURL) {
        if (error) {
            *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTMerchantIntegrationErrorInvalidClientToken
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Invalid client token: client api url was not present or invalid. Please ensure your server is generating a valid Braintree ClientToken."
                                                }];
        }
        return nil;
    }

    return clientApiURL;
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

- (NSString *)btPayPal_clientId {
    return self.btPayPal_claims[BTClientTokenKeyPayPalClientId];
}

-(NSDictionary *)btPayPal_claims{
    return self.configuration[BTClientTokenKeyPayPal];
}

- (NSString*)btPayPal_environment {
    return self.btPayPal_claims[BTClientTokenKeyPayPalEnvironment];
}

- (NSURL *)btPayPal_directBaseURL {
    NSString *apiUrl = self.btPayPal_claims[BTClientTokenKeyPayPalDirectBaseUrl];
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
    return [self.configuration[BTClientTokenKeyPayPalEnabled] boolValue];
}

- (BOOL)btPayPal_isTouchDisabled {
    return [self.btPayPal_claims[BTClientTokenKeyPayPalDisableAppSwitch] boolValue];
}

- (NSString *)btPayPal_merchantName {
    BOOL isLive = [self.btPayPal_environment isEqualToString:BTClientTokenPayPalEnvironmentLive];
    NSString *defaultName = isLive ? nil : BTClientTokenPayPalNonLiveDefaultValueMerchantName;
    return self.btPayPal_claims[BTClientTokenKeyPayPalMerchantName] ?: defaultName;
}

- (NSURL *)btPayPal_merchantUserAgreementURL {
    NSString *urlString = self.btPayPal_claims[BTClientTokenKeyPayPalMerchantUserAgreementUrl];
    BOOL isLive = [self.btPayPal_environment isEqualToString:BTClientTokenPayPalEnvironmentLive];
    NSURL *defaultURL = isLive ? nil : [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantUserAgreementUrl];
    return urlString ? [NSURL URLWithString:urlString] : defaultURL;
}

- (NSURL *)btPayPal_privacyPolicyURL {
    NSString *urlString = self.btPayPal_claims[BTClientTokenKeyPayPalMerchantPrivacyPolicyUrl];
    BOOL isLive = [self.btPayPal_environment isEqualToString:BTClientTokenPayPalEnvironmentLive];
    NSURL *defaultURL = isLive ? nil : [NSURL URLWithString:BTClientTokenPayPalNonLiveDefaultValueMerchantPrivacyPolicyUrl];
    return urlString ? [NSURL URLWithString:urlString] : defaultURL;
}


#pragma mark Venmo

- (NSString *)btVenmo_status {
    id status = self.configuration[BTClientTokenKeyVenmo];
    if ([status isKindOfClass:[NSString class]]) {
        return status;
    } else {
        return nil;
    }
}

@end