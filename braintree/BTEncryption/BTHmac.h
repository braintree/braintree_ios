#import <Foundation/Foundation.h>

@interface BTHmac : NSObject

+ (NSData*)sign:(NSData*)data withKey:(NSData*)key;

@end
