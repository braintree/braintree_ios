@import Foundation;

#import "BTAppSwitching.h"
#import "BTAppSwitchErrors.h"

@interface BTCoinbase : NSObject <BTAppSwitching>

+ (instancetype)sharedCoinbase;

@end
