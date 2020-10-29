#if SWIFT_PACKAGE
#import "BTPayPalCreditFinancingAmount.h"
#else
#import <BraintreePayPal/BTPayPalCreditFinancingAmount.h>
#endif

@interface BTPayPalCreditFinancingAmount ()

- (instancetype)initWithCurrency:(NSString *)currency value:(NSString *)value;

@end
