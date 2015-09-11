#import "BraintreeDemoPayPalBillingAgreementViewController.h"

#import <BraintreePayPal/BraintreePayPal.h>

@interface BraintreeDemoPayPalBillingAgreementViewController () <BTAppSwitchDelegate>

@end

@implementation BraintreeDemoPayPalBillingAgreementViewController

- (UIView *)paymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Billing Agreement with PayPal" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:50.0/255 green:50.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(tappedPayPalCheckout:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedPayPalCheckout:(UIButton *)sender {
    self.progressBlock(@"Tapped PayPal - initiating checkout using BTPayPalDriver");

    [sender setTitle:@"Processing..." forState:UIControlStateDisabled];
    [sender setEnabled:NO];

    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];
    driver.delegate = self;

    BTPayPalCheckoutRequest *checkout = [[BTPayPalCheckoutRequest alloc] init];
    [driver billingAgreementWithCheckoutRequest:checkout completion:^(BTTokenizedPayPalCheckout * _Nullable tokenizedPayPalCheckout, NSError * _Nullable error) {
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

- (void)appSwitcherWillPerformAppSwitch:(__unused id)appSwitcher {
   self.progressBlock(@"paymentDriverWillPerformAppSwitch:");
}

- (void)appSwitcherWillProcessPaymentInfo:(__unused id)appSwitcher {
    self.progressBlock(@"paymentDriverWillProcessPaymentInfo:");
}

- (void)appSwitcher:(__unused id)appSwitcher didPerformSwitchToTarget:(BTAppSwitchTarget)target {
    switch (target) {
        case BTAppSwitchTargetWebBrowser:
            self.progressBlock(@"appSwitcher:didPerformSwitchToTarget: browser");
            break;
        case BTAppSwitchTargetNativeApp:
            self.progressBlock(@"appSwitcher:didPerformSwitchToTarget: app");
            break;
        case BTAppSwitchTargetUnknown:
            self.progressBlock(@"appSwitcher:didPerformSwitchToTarget: unknown");
            break;
    }
}

@end
