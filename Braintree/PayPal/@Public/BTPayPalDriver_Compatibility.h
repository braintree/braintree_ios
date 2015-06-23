#import "BTPayPalDriver.h"

/// Extensions to BTPayPalDriver to expose a private method to enable better backwards compatibility in BTPayPalAppSwitchHandler.
///
/// This file should be removed when BTPayPalAppSwitchHandler is removed.
@interface BTPayPalDriver ()
+ (BOOL)verifyAppSwitchConfigurationForClient:(BTClient *)client returnURLScheme:(NSString *)returnURLScheme error:(NSError * __autoreleasing *)error;

@end
