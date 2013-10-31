#import <Foundation/Foundation.h>

@interface BTAES : NSObject

+ (NSData*) encrypt:(NSData*) data withKey:(NSData*) key;
+ (NSData*) encrypt:(NSData*) data withKey:(NSData*) key Iv:(NSData*) iv;

@end
