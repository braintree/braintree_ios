#import <UIKit/UIKit.h>
#import "BTHTTP.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTAPIHTTP : BTHTTP <NSURLSessionDelegate>

- (instancetype)initWithBaseURL:(NSURL *)URL accessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
