#import "BTClientToken.h"
#import "BTAPIResponseParser.h"
#import "BTClientTokenApplePayStatusValueTransformer.h"
#import "BTClientTokenApplePayPaymentNetworksValueTransformer.h"
#import "BTClientTokenBooleanValueTransformer.h"

NSString *const BTClientTokenKeyVersion = @"version";
NSString *const BTClientTokenKeyAuthorizationFingerprint = @"authorizationFingerprint";
NSString *const BTClientTokenKeyConfigURL = @"configUrl";

@interface BTClientToken ()

@property (nonatomic, readwrite, strong) BTAPIResponseParser *clientTokenParser;
@property (nonatomic, readwrite, copy) NSString *authorizationFingerprint;
@property (nonatomic, readwrite, strong) NSURL *configURL;

/// Returns an incomplete client token for manual initialization
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

@implementation BTClientToken

- (instancetype)init {
    return [super init];
}

- (instancetype)initWithClientTokenString:(NSString *)JSONString error:(NSError * __autoreleasing *)error {
    self = [super init];
    if (self) {
        // Client token must be decoded first because the other values are retrieved from it
        self.clientTokenParser = [self decodeClientToken:JSONString error:error];
        self.authorizationFingerprint = [self.clientTokenParser stringForKey:BTClientTokenKeyAuthorizationFingerprint];
        self.configURL = [self.clientTokenParser URLForKey:BTClientTokenKeyConfigURL];

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

    if (![self.configURL isKindOfClass:[NSURL class]] || self.configURL.absoluteString.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                         code:BTMerchantIntegrationErrorInvalidClientToken
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Invalid client token: config url was missing or invalid. Please ensure your server is generating a valid Braintree ClientToken."
                                                }];
        }
        return NO;
    }

    return YES;
}


- (instancetype)copyWithZone:(NSZone *)zone {
    BTClientToken *copiedClientToken = [[[self class] allocWithZone:zone] init];
    copiedClientToken.authorizationFingerprint = [_authorizationFingerprint copy];
    copiedClientToken.configURL = [_configURL copy];
    copiedClientToken.clientTokenParser = [self.clientTokenParser copy];
    return copiedClientToken;
}


#pragma mark JSON Parsing

- (NSDictionary *)parseJSONString:(NSString *)rawJSONString error:(NSError * __autoreleasing *)error {
    NSData *rawJSONData = [rawJSONString dataUsingEncoding:NSUTF8StringEncoding];

    return [NSJSONSerialization JSONObjectWithData:rawJSONData options:0 error:error];
}


#pragma mark NSCoding 

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.configURL forKey:@"configURL"];
    [coder encodeObject:self.authorizationFingerprint forKey:@"authorizationFingerprint"];
    [coder encodeObject:self.clientTokenParser forKey:@"claims"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self){
        self.configURL = [decoder decodeObjectForKey:@"configURL"];
        self.authorizationFingerprint = [decoder decodeObjectForKey:@"authorizationFingerprint"];
        self.clientTokenParser = [decoder decodeObjectForKey:@"claims"];
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
    return [NSString stringWithFormat:@"<BTClientToken: authorizationFingerprint:%@ configURL:%@>", self.authorizationFingerprint, self.configURL];
}

- (BOOL)isEqualToClientToken:(BTClientToken *)clientToken {
    return (self.clientTokenParser == clientToken.clientTokenParser) || [self.clientTokenParser isEqual:clientToken.clientTokenParser];
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

@end
