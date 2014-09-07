#import <Foundation/Foundation.h>
#import "BTClient.h"
#import "BTAppSwitching.h"
#import "BTVenmoErrors.h"

@interface BTVenmoAppSwitchHandler : NSObject<BTAppSwitching>

+ (instancetype)sharedHandler;

@end

