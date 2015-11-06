#import "BraintreeDemoBTUIVenmoButtonViewController.h"
#import <BraintreeVenmo/BraintreeVenmo.h>
#import <BraintreeUI/BraintreeUI.h>

@interface BraintreeDemoBTUIVenmoButtonViewController ()
@end

@implementation BraintreeDemoBTUIVenmoButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BTUIVenmoButton";

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

- (UIControl *)paymentButton {
    BTUIVenmoButton *venmoButton = [[BTUIVenmoButton alloc] init];
    [venmoButton addTarget:self action:@selector(tappedPayPalButton) forControlEvents:UIControlEventTouchUpInside];
    return venmoButton;
}

- (void)tappedPayPalButton {
    self.progressBlock(@"Tapped Venmo - initiating Venmo auth");

    BTVenmoDriver *driver = [[BTVenmoDriver alloc] initWithAPIClient:self.apiClient];
    [driver authorizeWithCompletion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
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
