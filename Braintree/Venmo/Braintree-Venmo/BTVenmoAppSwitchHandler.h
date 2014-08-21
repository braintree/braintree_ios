#import <Foundation/Foundation.h>
#import "BTClient.h"
#import "BTAppSwitching.h"

@interface BTVenmoAppSwitchHandler : NSObject<BTAppSwitching>

+ (instancetype)sharedHandler;

@end

