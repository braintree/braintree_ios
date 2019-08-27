#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTURLUtils : NSObject

+ (NSString *)queryStringWithDictionary:(NSDictionary *)dict;
+ (NSDictionary<NSString *, NSString *> *)queryParametersForURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
