#import <Foundation/Foundation.h>

@interface BTTestClientTokenFactory : NSObject

+ (NSString *)token;
+ (NSString *)tokenWithAnalyticsBatchSize:(NSUInteger)batchSize;
+ (NSString *)base64EncodedToken;
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
