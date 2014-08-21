#import <Foundation/Foundation.h>
#import "BTAppSwitching.h"

@interface BTPayPalAppSwitchHandler : NSObject<BTAppSwitching>

+ (instancetype)sharedHandler;

@end
