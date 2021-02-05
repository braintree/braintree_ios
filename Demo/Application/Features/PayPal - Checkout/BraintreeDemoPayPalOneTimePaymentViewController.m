#import "BraintreeDemoPayPalOneTimePaymentViewController.h"
@import BraintreePayPal;

@interface BraintreeDemoPayPalOneTimePaymentViewController () <BTAppSwitchDelegate>

@end

@implementation BraintreeDemoPayPalOneTimePaymentViewController

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"PayPal one-time payment", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:50.0/255 green:50.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(tappedPayPalOneTimePayment:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedPayPalOneTimePayment:(UIButton *)sender {
    self.progressBlock(@"Tapped PayPal - initiating one-time payment using BTPayPalDriver");

    [sender setTitle:NSLocalizedString(@"Processing...", nil) forState:UIControlStateDisabled];
    [sender setEnabled:NO];

    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];
    driver.appSwitchDelegate = self;
    BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:@"4.30"];
    request.activeWindow = self.view.window;
    [driver requestOneTimePayment:request completion:^(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error) {
        [sender setEnabled:YES];

        if (error) {
            self.progressBlock(error.localizedDescription);
        } else if (payPalAccount) {
            self.completionBlock(payPalAccount);
        } else {
            self.progressBlock(@"Cancelled");
        }
    }];
}

#pragma mark BTAppSwitchDelegate

- (void)appContextWillSwitch:(__unused id)appSwitcher {
   self.progressBlock(@"appContextWillSwitch:");
}

- (void)appContextDidReturn:(__unused id)appSwitcher {
    self.progressBlock(@"appContextDidReturn:");
}

@end
