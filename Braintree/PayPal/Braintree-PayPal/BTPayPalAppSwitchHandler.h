#import <Foundation/Foundation.h>
#import "BTAppSwitching.h"
#import "BTErrors+BTPayPal.h"

@interface BTPayPalAppSwitchHandler : NSObject<BTAppSwitching>

+ (instancetype)sharedHandler;

@end
