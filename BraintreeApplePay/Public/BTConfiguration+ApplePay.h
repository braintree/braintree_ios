#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTConfiguration (ApplePay)

/// Indicates whether Apple Pay is enabled for the merchant account.
@property (nonatomic, readonly, assign) BOOL isApplePayEnabled;

@end
