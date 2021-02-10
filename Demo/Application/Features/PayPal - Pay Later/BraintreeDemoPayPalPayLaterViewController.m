#import "BraintreeDemoPayPalPayLaterViewController.h"
@import BraintreePayPal;

@implementation BraintreeDemoPayPalPayLaterViewController

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"PayPal with Pay Later Offered", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:50.0/255 green:50.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(tappedPaymentButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedPaymentButton:(UIButton *)sender {

    self.progressBlock(@"Tapped - initiating payment with Pay Later offered");

    [sender setTitle:NSLocalizedString(@"Processing...", nil) forState:UIControlStateDisabled];
    [sender setEnabled:NO];

    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];

    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:@"4.30"];
    request.activeWindow = self.view.window;
    request.offerPayLater = YES;

    [driver tokenizePayPalAccountWithPayPalRequest:request completion:^(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error) {
        [sender setEnabled:YES];

        if (error) {
            self.progressBlock(error.localizedDescription);
        } else if (payPalAccount) {
            self.completionBlock(payPalAccount);
        } else {
            self.progressBlock(@"Canceled");
        }
    }];
}

@end
