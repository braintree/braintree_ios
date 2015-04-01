@import Foundation;

#import "BTAppSwitching.h"
#import "BTAppSwitchErrors.h"

/// Manages the communication with the Coinbase app or browser for authorization
///
/// @see BTAppSwitching
@interface BTCoinbase : NSObject <BTAppSwitching>

+ (instancetype)sharedCoinbase;

/// Checks whether the Coinbase app is installed and accepting app switch authorization
///
/// @param client A BTClient
///
/// @return YES if the Coinbase native app is installed.
- (BOOL)providerAppSwitchAvailableForClient:(BTClient *)client;

@end
