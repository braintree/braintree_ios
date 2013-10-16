#import <Foundation/Foundation.h>

@interface BTHmac : NSObject

+ (NSString*)sign:(NSString*)data withKey:(NSString*)key;

@end
