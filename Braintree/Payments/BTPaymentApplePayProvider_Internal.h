#import "BTPaymentApplePayProvider.h"

@interface BTPaymentApplePayProvider ()

+ (BOOL)isSimulator;
- (UIViewController *)paymentAuthorizationViewControllerWithPaymentRequest:(PKPaymentRequest *)paymentRequest;
- (BOOL)paymentAuthorizationViewControllerCanMakePayments;

@end
