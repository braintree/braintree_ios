#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTConfiguration (Venmo)

/// 🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧
/// Force Venmo to be enabled. If false, Drop-In will not display the Venmo button and [BTVenmoDriver authorizationWithCompletion:] will return an error.
/// When set to true the Venmo button will be visible if it is also setup properly.
/// Defaults to false during the limited availability phase.
+ (void)enableVenmo:(BOOL)isEnabled;

/// Indicates whether Venmo is enabled for the merchant account.
@property (nonatomic, readonly, assign) BOOL isVenmoEnabled;

/// Returns the Access Token used by the Venmo app to tokenize on behalf of the merchant
@property (nonatomic, readonly, assign) NSString *venmoAccessToken;

@end
