#if __has_include(<Braintree/BraintreeCore.h>) // CocoaPods
#import <Braintree/BTHTTP.h>

#elif SWIFT_PACKAGE // SPM
// The only way SPM can find BTHTTP.h is using quoted includes,
// so we need to silence the warning.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wquoted-include-in-framework-header"
#import "BTHTTP.h"
#pragma clang diagnostic pop

#else // Carthage
#import <BraintreeCore/BTHTTP.h>

#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTAPIHTTP : BTHTTP <NSURLSessionDelegate>

- (instancetype)initWithBaseURL:(NSURL *)URL accessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
