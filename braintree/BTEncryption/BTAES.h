#import <Foundation/Foundation.h>

@interface BTAES : NSObject

+ (NSString*) encrypt:(NSData*) data withKey:(NSString*) key;
+ (NSString*) encrypt:(NSData*) data withKey:(NSString*) key Iv:(NSData*) iv;

@end
