#import <Foundation/Foundation.h>
#import "BTClient.h"
#import "BTAppSwitching.h"

@interface BTVenmoAppSwitchHandler : NSObject<BTAppSwitching>

+ (instancetype)sharedHandler;

/// Returns whether Venmo Touch is available
///
/// @return true if the Venmo app is installed
+ (BOOL)isAvailable;

@end

