#import "BraintreeDemoCustomPayPalButtonViewController.h"
#import <BraintreeUI/BraintreeUI.h>
#import <BraintreePayPal/BraintreePayPal.h>

@interface BraintreeDemoCustomPayPalButtonViewController ()
@end

@implementation BraintreeDemoCustomPayPalButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PayPal (custom button)";

    self.paymentButton.hidden = YES;
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        if (!configuration.isPayPalEnabled) {
            self.progressBlock(@"canCreatePaymentMethodWithProviderType: returns NO, hiding custom PayPal button");
        } else {
            self.paymentButton.hidden = NO;
        }
    }];
}

- (UIView *)paymentButton {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"PayPal (custom button)" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor blueColor] bt_adjustedBrightness:0.5] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(tappedCustomPayPal) forControlEvents:UIControlEventTouchUpInside];
        return button;
}

- (void)tappedCustomPayPal {
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];
    [payPalDriver authorizeAccountWithCompletion:^(BTTokenizedPayPalAccount * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
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

@end
