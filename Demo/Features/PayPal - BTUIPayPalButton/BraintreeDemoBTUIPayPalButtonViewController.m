#import "BraintreeDemoBTUIPayPalButtonViewController.h"
#import "BTUIPaymentButtonCollectionViewCell.h"
#import <BraintreePayPal/BraintreePayPal.h>
#import <BraintreeUI/BraintreeUI.h>

@interface BraintreeDemoBTUIPayPalButtonViewController () <BTAppSwitchDelegate>
@end

@implementation BraintreeDemoBTUIPayPalButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BTUIPayPalButton";

    self.paymentButton.hidden = YES;
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        if (error) {
            self.progressBlock(@"Failed to fetch configuration");
            NSLog(@"Failed to fetch configuration: %@", error);
            return;
        }

        if (!configuration.isPayPalEnabled) {
            self.progressBlock(@"canCreatePaymentMethodWithProviderType: returns NO, hiding PayPal button");
        } else {
            self.paymentButton.hidden = NO;
        }
    }];
}

- (UIView *)paymentButton {
    BTUIPayPalButton *payPalButton = [[BTUIPayPalButton alloc] init];
    [payPalButton addTarget:self action:@selector(tappedPayPalButton) forControlEvents:UIControlEventTouchUpInside];
    return payPalButton;
}

- (void)tappedPayPalButton {
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];
    payPalDriver.appSwitchDelegate = self;
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
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
