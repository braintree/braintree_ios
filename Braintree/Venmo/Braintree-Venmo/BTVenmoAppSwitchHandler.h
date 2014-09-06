#import <Foundation/Foundation.h>
#import "BTClient.h"
#import "BTAppSwitching.h"

@interface BTVenmoAppSwitchHandler : NSObject<BTAppSwitching>

+ (instancetype)sharedHandler;

/// Returns whether Venmo Touch is available
///
/// @param client A BTClient
///
/// @return YES if the Venmo app is installed
- (BOOL)isAvailableForClient:(BTClient*)client;

@end

