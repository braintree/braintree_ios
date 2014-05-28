#import "BTPayPalViewController.h"
#import "PayPalMobile.h"

@interface BTPayPalViewController () <PayPalFuturePaymentDelegate>
@property (nonatomic, readwrite, strong) PayPalFuturePaymentViewController *payPalFuturePaymentViewController;
@end
