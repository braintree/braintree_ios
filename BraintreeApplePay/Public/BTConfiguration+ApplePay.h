#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTConfiguration (ApplePay)

/// Indicates whether Apple Pay is enabled for the merchant account.
@property (nonatomic, readonly, assign) BOOL isApplePayEnabled;

/// Returns the Apple Pay supported networks enabled for the merchant account.
@property (nonatomic, readonly, assign) NSArray *applePaySupportedNetworks;

/// Indicates if the Apple Pay merchant enabled payment networks are supported on this device.
@property (nonatomic, readonly, assign) BOOL canMakeApplePayPayments;

@end
