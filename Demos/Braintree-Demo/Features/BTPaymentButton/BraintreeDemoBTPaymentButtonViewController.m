#import <PureLayout/ALView+PureLayout.h>
#import "BraintreeDemoBTPaymentButtonViewController.h"
#import "Braintree.h"

@interface BraintreeDemoBTPaymentButtonViewController () <BTPaymentMethodCreationDelegate>
@end

@implementation BraintreeDemoBTPaymentButtonViewController

- (UIView *)paymentButton {
    return [self.braintree paymentButtonWithDelegate:self];
}


@end
