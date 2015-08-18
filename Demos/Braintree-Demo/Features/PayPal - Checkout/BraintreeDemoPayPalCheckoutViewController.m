#import "BraintreeDemoPayPalCheckoutViewController.h"

#import <BraintreePayPal/BraintreePayPal.h>

@interface BraintreeDemoPayPalCheckoutViewController () <BTPayPalDriverDelegate>

@end

@implementation BraintreeDemoPayPalCheckoutViewController

- (UIView *)paymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Checkout with PayPal" forState:UIControlStateNormal];
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

    BTPayPalCheckoutRequest *checkout = [[BTPayPalCheckoutRequest alloc] initWithAmount:[NSDecimalNumber decimalNumberWithString:@"4.32"]];
    [driver checkoutWithCheckoutRequest:checkout completion:^(BTTokenizedPayPalCheckout * _Nullable tokenizedPayPalCheckout, NSError * _Nullable error) {
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

#pragma mark BTPayPalDriverDelegate

- (void)payPalDriverWillPerformAppSwitch:(__unused BTPayPalDriver *)payPalDriver {
    self.progressBlock(@"payPalDriverWillPerformAppSwitch:");
}

- (void)payPalDriverWillProcessAppSwitchResult:(__unused BTPayPalDriver *)payPalDriver {
    self.progressBlock(@"payPalDriverWillProcessAppSwitchResult:");
}

- (void)payPalDriver:(__unused BTPayPalDriver *)payPalDriver didPerformAppSwitchToTarget:(BTPayPalDriverAppSwitchTarget)target {
    switch (target) {
        case BTPayPalDriverAppSwitchTargetBrowser:
            self.progressBlock(@"payPalDriver:didPerformAppSwitchToTarget: browser");
            break;
        case BTPayPalDriverAppSwitchTargetPayPalApp:
            self.progressBlock(@"payPalDriver:didPerformAppSwitchToTarget: app");
            break;
    }
}


@end
