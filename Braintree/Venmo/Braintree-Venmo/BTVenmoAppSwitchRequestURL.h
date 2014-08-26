#import <Foundation/Foundation.h>

@interface BTVenmoAppSwitchRequestURL : NSObject

+ (BOOL)isAppSwitchAvailable;
+ (NSURL *)appSwitchURLForMerchantID:(NSString *)merchantID returnURLScheme:(NSString *)scheme;

@end
