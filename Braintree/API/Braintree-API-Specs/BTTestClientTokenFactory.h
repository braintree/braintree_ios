#import <Foundation/Foundation.h>

@interface BTTestClientTokenFactory : NSObject

+ (NSString *)token;
+ (NSString *)tokenWithAnalyticsUrl:(NSString *)analyticsUrl;
+ (NSString *)base64EncodedToken;
+ (NSString *)base64EncodedTokenWithMerchantId:(NSString *)merchantId;
+ (NSString *)tokenWithPayPalClientId;
+ (NSString *)invalidToken;
+ (NSString *)tokenWithoutCustomerIdentifier;
+ (NSString *)tokenWithoutAuthorizationUrl;
+ (NSString *)tokenWithoutAuthorizationFingerprint;
+ (NSString *)tokenWithoutClientApiUrl;
+ (NSString *)tokenWithBlankAuthorizationUrl;
+ (NSString *)tokenWithBlankAuthorizationFingerprint;
+ (NSString *)tokenWithBlankClientApiUrl;

+ (NSString *)tokenWithTestURLs;
+ (NSString *)testURLScheme;

@end
