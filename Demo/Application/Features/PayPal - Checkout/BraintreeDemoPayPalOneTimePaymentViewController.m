#import "BraintreeDemoPayPalOneTimePaymentViewController.h"
@import BraintreePayPal;

@interface BraintreeDemoPayPalOneTimePaymentViewController () <BTAppContextSwitchDelegate>

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
    driver.appContextSwitchDelegate = self;
    BTPayPalRequest *request = [[BTPayPalRequest alloc] initWithAmount:@"4.30"];
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

#pragma mark BTAppContextSwitchDelegate

- (void)appContextSwitchHandlerWillStartSwitch:(__unused id<BTAppContextSwitchDriver>)driver {
   self.progressBlock(@"appContextSwitchHandlerWillStartSwitch:");
}

- (void)appContextSwitchDriverDidCompleteSwitch:(__unused id<BTAppContextSwitchDriver>)driver {
    self.progressBlock(@"appContextSwitchDriverDidCompleteSwitch:");
}

@end
