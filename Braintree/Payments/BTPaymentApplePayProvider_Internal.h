#import "BTPaymentApplePayProvider.h"

@interface BTPaymentApplePayProvider ()

+ (BOOL)isSimulator;
- (BOOL)paymentAuthorizationViewControllerCanMakePayments;

#if BT_ENABLE_APPLE_PAY
- (UIViewController *)paymentAuthorizationViewControllerWithPaymentRequest:(PKPaymentRequest *)paymentRequest;
#endif

@end
