#import <Foundation/Foundation.h>

@interface BTVenmoAppSwitchURL : NSObject

+ (BOOL)isAppSwitchAvailable;
+ (NSURL *)appSwitchURLForMerchantID:(NSString *)merchantID returnURLScheme:(NSString *)scheme;

@end
