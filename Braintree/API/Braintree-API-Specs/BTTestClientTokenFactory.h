#import <Foundation/Foundation.h>

@interface BTTestClientTokenFactory : NSObject

+ (NSString *)tokenWithVersion:(NSInteger)version;
+ (NSString *)tokenWithVersion:(NSInteger)version
                     overrides:(NSDictionary *)dictionary;
+ (NSString *)tokenWithVersion:(NSInteger)version
                     overrides:(NSDictionary *)dictionary
               encodingOptions:(NSDataBase64EncodingOptions)encodingOptions;

+ (NSMutableDictionary *)configuration;

@end
