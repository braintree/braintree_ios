#import <Foundation/Foundation.h>

@interface BTVenmoAppSwitchRequestURL : NSObject

/// Whether app to the Venmo app is available
+ (BOOL)isAppSwitchAvailable;

/// Create an app switch URL
///
/// @param merchantID The merchant ID
/// @param scheme     The return URL scheme, e.g. "com.yourcompany.Your-App.payments"
/// @param offline    Whether the Venmo app should be in "offline" mode, useful for testing/development
///
/// @return The resulting URL
+ (NSURL *)appSwitchURLForMerchantID:(NSString *)merchantID returnURLScheme:(NSString *)scheme offline:(BOOL)offline error:(NSError * __autoreleasing *)error;

@end
