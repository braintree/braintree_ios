#import "BraintreeDemoPayPalForceFuturePaymentViewController.h"
#import <BraintreeUI/BraintreeUI.h>
#import <BraintreePayPal/BraintreePayPal.h>
#import <BraintreePayPal/BTPayPalDriver_Internal.h>

@interface BraintreeDemoPayPalForceFuturePaymentViewController () <BTAppSwitchDelegate>
@end

@implementation BraintreeDemoPayPalForceFuturePaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PayPal (future payment button)";

    self.paymentButton.hidden = YES;
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
            return;
        }

        if (!configuration.isPayPalEnabled) {
            self.progressBlock(@"canCreatePaymentMethodWithProviderType: returns NO, hiding custom PayPal button");
        } else {
            self.paymentButton.hidden = NO;
        }
    }];
}

- (UIView *)paymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"PayPal (future payment button)" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor blueColor] bt_adjustedBrightness:0.5] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tappedCustomPayPal) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedCustomPayPal {
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];
    payPalDriver.appSwitchDelegate = self;
    [payPalDriver authorizeAccountWithAdditionalScopes:[NSSet set] forceFuturePaymentFlow:true completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
        if (tokenizedPayPalAccount) {
            self.progressBlock(@"Got a nonce 💎!");
            NSLog(@"%@", [tokenizedPayPalAccount debugDescription]);
            self.completionBlock(tokenizedPayPalAccount);
        } else if (error) {
            self.progressBlock(error.localizedDescription);
        } else {
            self.progressBlock(@"Canceled 🔰");
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
