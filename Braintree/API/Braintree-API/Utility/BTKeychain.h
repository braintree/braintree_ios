#import <Foundation/Foundation.h>

@interface BTKeychain : NSObject

+ (BOOL)setString:(NSString *)string forKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;

@end