#import "BraintreeDemoPayPalVaultViewController.h"
@import BraintreePayPal;

@implementation BraintreeDemoPayPalVaultViewController

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"PayPal Vault", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:50.0/255 green:50.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(tappedPayPalVault:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedPayPalVault:(UIButton *)sender {
    self.progressBlock(@"Tapped PayPal - vault using BTPayPalDriver");
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
