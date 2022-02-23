#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTCacheDateValidator : NSObject
-(BOOL) isCacheInvalid:(NSCachedURLResponse *)cachedConfigurationResponse;
@end

NS_ASSUME_NONNULL_END
