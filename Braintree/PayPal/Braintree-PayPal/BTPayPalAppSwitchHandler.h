@import Foundation;
#import "BTAppSwitching.h"
#import "BTAppSwitchErrors.h"
#import "BTErrors+BTPayPal.h"

@interface BTPayPalAppSwitchHandler : NSObject<BTAppSwitching>

+ (instancetype)sharedHandler;

@end
