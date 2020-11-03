#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTHTTP.h>
#elif SWIFT_PACKAGE
#import <BTHTTP.h>
#else
#import <BraintreeCore/BTHTTP.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTAPIHTTP : BTHTTP <NSURLSessionDelegate>

- (instancetype)initWithBaseURL:(NSURL *)URL accessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
