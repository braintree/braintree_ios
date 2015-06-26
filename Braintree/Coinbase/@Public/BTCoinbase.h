#import <Foundation/Foundation.h>

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

///
/// Returns `YES` if the Coinbase iOS app is installed on the device.
///
/// @note This flag does not consider cases where `BTCoinbase` has been
/// disabled, or the gateway configuration has not enabled Coinbase as a
/// payment option, or when `returnURLScheme` is invalid. To check for those
/// conditions, use `providerAppSwitchAvailableForClient:`.
///
/// @see `providerAppSwitchAvailableForClient:`
@property (nonatomic, assign, readonly) BOOL isProviderAppInstalled;

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
