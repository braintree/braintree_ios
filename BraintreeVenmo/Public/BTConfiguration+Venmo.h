#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTConfiguration (Venmo)

/// Indicates whether Venmo is enabled for the merchant account.
@property (nonatomic, readonly, assign) BOOL isVenmoEnabled;

@end
