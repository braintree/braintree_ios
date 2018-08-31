#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/**
 Category on BTConfiguration for LocalPayment
 */
@interface BTConfiguration (LocalPayment)

/**
 Indicates whether Local Payments are enabled for the merchant account.
 */
@property (nonatomic, readonly, assign) BOOL isLocalPaymentEnabled;

@end
