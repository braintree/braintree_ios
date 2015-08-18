#import <Foundation/Foundation.h>
#import <BraintreeCore/BTNullability.h>

BT_ASSUME_NONNULL_BEGIN

@interface BTVenmoAppSwitchRequestURL : NSObject

/// The base app switch URL for Venmo
/// Does not include specific parameters
+ (NSURL *)baseAppSwitchURL;

/// Create an app switch URL
///
/// @param merchantID The merchant ID
/// @param scheme     The return URL scheme, e.g. "com.yourcompany.Your-App.payments"
/// @param bundleName The bundle display name for the current app
/// @param offline    Whether the Venmo app should be in "offline" mode, useful for testing/development
///
/// @return The resulting URL
+ (NSURL *)appSwitchURLForMerchantID:(NSString *)merchantID
                     returnURLScheme:(NSString *)scheme
                   bundleDisplayName:(NSString *)bundleName
                             offline:(BOOL)offline;

@end

BT_ASSUME_NONNULL_END
