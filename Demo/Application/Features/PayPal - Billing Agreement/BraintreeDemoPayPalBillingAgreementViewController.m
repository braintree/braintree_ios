#import "BraintreeDemoPayPalBillingAgreementViewController.h"
@import BraintreePayPal;

@implementation BraintreeDemoPayPalBillingAgreementViewController

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Billing Agreement with PayPal", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:50.0/255 green:50.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(tappedPayPalCheckout:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedPayPalCheckout:(UIButton *)sender {
    self.progressBlock(@"Tapped PayPal - initiating checkout using BTPayPalDriver");
    [sender setTitle:NSLocalizedString(@"Processing...", nil) forState:UIControlStateDisabled];
    [sender setEnabled:NO];

    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];
    BTPayPalVaultRequest *request = [[BTPayPalVaultRequest alloc] init];
    request.activeWindow = self.view.window;
    [driver tokenizePayPalAccountWithPayPalRequest:request completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalCheckout, NSError * _Nullable error) {
        [sender setEnabled:YES];

        if (error) {
            self.progressBlock(error.localizedDescription);
        } else if (tokenizedPayPalCheckout) {
            self.completionBlock(tokenizedPayPalCheckout);
        } else {
            self.progressBlock(@"Canceled");
        }
    }];
}

@end
