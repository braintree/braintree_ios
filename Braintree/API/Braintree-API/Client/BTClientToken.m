#import "BTClientToken.h"

NSString *const BTClientTokenKeyAuthorizationFingerprint = @"authorizationFingerprint";
NSString *const BTClientTokenKeyClientApiURL = @"clientApiUrl";
NSString *const BTClientTokenKeyChallenges = @"challenges";
NSString *const BTClientTokenKeyAnalytics = @"analytics";
NSString *const BTClientTokenKeyURL = @"url";

@interface BTClientToken ()

@property (nonatomic, readwrite, copy) NSString *authorizationFingerprint;
@property (nonatomic, readwrite, strong) NSURL *clientApiURL;
@property (nonatomic, readwrite, strong) NSDictionary *claims;

- (NSDictionary *)decodeClientToken:(NSString *)rawClientTokenString error:(NSError **)error;

- (NSString *)parseAuthorizationFingerprint:(NSString *)authorizationFingerprint error:(NSError **)error;
- (NSURL *)parseAuthorizationURL:(NSString *)authorizationURLString error:(NSError **)error;
- (NSURL *)parseClientApiURL:(NSString *)clientApiURLString error:(NSError **)error;
@end

@implementation BTClientToken

- (instancetype)initWithClientTokenString:(NSString *)JSONString error:(NSError * __autoreleasing *)error {
    NSDictionary *claims = [self decodeClientToken:JSONString error:error];

    if (!claims) {
        return nil;
    }

    self = [self initWithClaims:claims
                          error:error];
    return self;
}

- (instancetype)initWithClaims:(NSDictionary *)claims
                         error:(NSError * __autoreleasing *)error {
    self = [self init];
    if (self) {
        self.authorizationFingerprint = [self parseAuthorizationFingerprint:claims[BTClientTokenKeyAuthorizationFingerprint]
                                                                      error:error];
        self.clientApiURL = [self parseClientApiURL:([claims[BTClientTokenKeyClientApiURL] isKindOfClass:[NSString class]] ? claims[BTClientTokenKeyClientApiURL]: nil)
                                              error:error];

        self.claims = claims;

        if (!self.authorizationFingerprint || !self.clientApiURL) {
            if (error && !*error) {
                *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain code:BTMerchantIntegrationErrorInvalidClientToken userInfo:nil];
            }
            return nil;
        }
    }
    return self;
}

- (NSSet *)challenges {
    return [NSSet setWithArray:self.claims[BTClientTokenKeyChallenges]];
}

- (BOOL)isAnalyticsEnabled {
    return [self.claims[BTClientTokenKeyAnalytics] isKindOfClass:[NSDictionary class]] && [self.claims[BTClientTokenKeyAnalytics][BTClientTokenKeyURL] isKindOfClass:[NSString class]];
}

- (NSURL *)analyticsURL {
    return [NSURL URLWithString:self.claims[BTClientTokenKeyAnalytics][BTClientTokenKeyURL]];
}

#pragma mark JSON Parsing

- (NSDictionary *)parseJSONString:(NSString *)rawJSONString error:(NSError * __autoreleasing *)error {
    NSData *rawJSONData = [rawJSONString dataUsingEncoding:NSUTF8StringEncoding];

    return [NSJSONSerialization JSONObjectWithData:rawJSONData options:0 error:error];
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
                                                NSUnderlyingErrorKey: JSONError,
                                                NSLocalizedDescriptionKey: @"Invalid client token. Please ensure your server is generating a valid Braintree ClientToken.",
                                                NSLocalizedFailureReasonErrorKey: @"Invalid JSON. Expected to find an object at JSON root."
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
    return [NSString stringWithFormat:@"<BTClientToken: authorizationFingerprint:%@ clientApiURL:%@, analyticsURL:%@>", self.authorizationFingerprint, self.clientApiURL, self.analyticsURL];
}

@end
