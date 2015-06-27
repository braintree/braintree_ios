#import "BTPaymentApplePayProvider.h"

@interface BTPaymentApplePayProvider ()

+ (BOOL)isSimulator;
- (BOOL)paymentAuthorizationViewControllerCanMakePayments;

@end
