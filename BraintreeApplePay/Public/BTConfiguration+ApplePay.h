#import <BraintreeCore/BraintreeCore.h>

@interface BTConfiguration (ApplePay)

/// Indicates whether Apple Pay is enabled for the merchant account.
@property (nonatomic, readonly, assign) BOOL isApplePayEnabled;

@end
