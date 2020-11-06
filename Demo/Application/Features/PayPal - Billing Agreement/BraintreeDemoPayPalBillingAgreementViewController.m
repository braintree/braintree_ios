#import "BraintreeDemoPayPalBillingAgreementViewController.h"
@import BraintreePayPal;

@interface BraintreeDemoPayPalBillingAgreementViewController () <BTAppSwitchDelegate>

@end

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
    driver.appSwitchDelegate = self;
    BTPayPalRequest *checkout = [[BTPayPalRequest alloc] init];
    checkout.activeWindow = self.view.window;
    [driver requestBillingAgreement:checkout completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalCheckout, NSError * _Nullable error) {
        [sender setEnabled:YES];

        if (error) {
            self.progressBlock(error.localizedDescription);
        } else if (tokenizedPayPalCheckout) {
            self.completionBlock(tokenizedPayPalCheckout);
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
