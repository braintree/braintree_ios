@import Foundation;

#import "BTAppSwitching.h"
#import "BTAppSwitchErrors.h"

/// Manages the communication with the Coinbase app or browser for authorization
///
/// This is a beta integration option. For details, see https://www.braintreepayments.com/features/coinbase
///
/// @see BTAppSwitching
@interface BTCoinbase : NSObject <BTAppSwitching>

@property (nonatomic, assign) BOOL storeInVault;

/// Dynamically disable Coinbase support on the client-side,
/// e.g. for certain customers, geographies, devices, etc.
///
/// Example:
/// `[BTCoinbase sharedCoinbase].disabled = [CoinbaseOAuth isAppOAuthAuthenticationAvailable] ? NO : YES;`
@property (nonatomic, assign) BOOL disabled;

+ (instancetype)sharedCoinbase;

/// Checks whether the Coinbase app is installed (and accepting app switch authorization)
/// and Braintree is configured for Coinbase app switch. This requires a returnURLScheme
/// to be set and for Coinbase to be enabled in your Braintree Control Panel.
///
/// @param client A BTClient
///
/// @return YES if the Coinbase native app is available for app switch.
///
/// @see `+[Braintree setReturnURLScheme:]`
- (BOOL)providerAppSwitchAvailableForClient:(BTClient *)client;

@end
