#import "BraintreeDemoCustomVenmoButtonViewController.h"
#import <BraintreeVenmo/BraintreeVenmo.h>
#import <BraintreeUI/UIColor+BTUI.h>

@interface BraintreeDemoCustomVenmoButtonViewController ()
@end

@implementation BraintreeDemoCustomVenmoButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Custom Venmo Button";

    self.paymentButton.hidden = YES;
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
            NSLog(@"Failed to fetch configuration: %@", error);
            return;
        }

        if (configuration.isVenmoEnabled) {
            self.paymentButton.hidden = NO;
        } else {
            self.progressBlock(@"canCreatePaymentMethodWithProviderType returns NO, hiding Venmo button");
        }
    }];

}

- (UIView *)paymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Venmo (custom button)" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] bt_adjustedBrightness:0.7] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tappedCustomVenmo) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedCustomVenmo {
    self.progressBlock(@"Tapped Venmo - initiating Venmo auth");

    BTVenmoDriver *driver = [[BTVenmoDriver alloc] initWithAPIClient:self.apiClient];
    [driver authorizeWithCompletion:^(BTTokenizedCard * _Nullable tokenizedCard, NSError * _Nullable error) {
        if (tokenizedCard) {
            self.progressBlock(@"Got a nonce 💎!");
            NSLog(@"%@", [tokenizedCard debugDescription]);
            self.completionBlock(tokenizedCard);
        } else if (error) {
            self.progressBlock(error.localizedDescription);
        } else {
            self.progressBlock(@"Canceled 🔰");
        }
    }];
}

@end
