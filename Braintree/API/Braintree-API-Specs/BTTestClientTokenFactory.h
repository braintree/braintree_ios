#import <Foundation/Foundation.h>

@interface BTTestClientTokenFactory : NSObject

+ (NSString *)tokenWithVersion:(NSInteger)version;
+ (NSString *)tokenWithVersion:(NSInteger)version
                     overrides:(NSDictionary *)dictionary;

+ (NSMutableDictionary *)configuration;

#pragma mark Deprecated

//+ (NSString *)token;
//+ (NSString *)tokenWithAnalyticsUrl:(NSString *)analyticsUrl;
//+ (NSString *)base64EncodedToken;
//+ (NSString *)base64EncodedTokenWithMerchantId:(NSString *)merchantId;
//+ (NSString *)base64EncodedTokenFromDictionary:(NSDictionary *)dictionary;
//+ (NSString *)tokenWithPayPalClientId;
//+ (NSString *)invalidToken;
//+ (NSString *)tokenWithoutCustomerIdentifier;
//+ (NSString *)tokenWithoutAuthorizationUrl;
//+ (NSString *)tokenWithoutAuthorizationFingerprint;
//+ (NSString *)tokenWithoutClientApiUrl;
//+ (NSString *)tokenWithBlankAuthorizationUrl;
//+ (NSString *)tokenWithBlankAuthorizationFingerprint;
//+ (NSString *)tokenWithBlankClientApiUrl;
//
//+ (NSString *)tokenWithTestURLs;
//+ (NSString *)testURLScheme;

@end
