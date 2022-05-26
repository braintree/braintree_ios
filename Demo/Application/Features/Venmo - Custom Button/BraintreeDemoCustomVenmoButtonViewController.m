#import "BraintreeDemoCustomVenmoButtonViewController.h"
@import BraintreeVenmo;

@interface BraintreeDemoCustomVenmoButtonViewController ()

@property (nonatomic, strong) BTVenmoClient *venmoClient;

@end

@implementation BraintreeDemoCustomVenmoButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.venmoClient = [[BTVenmoClient alloc] initWithAPIClient:self.apiClient];
    self.title = NSLocalizedString(@"Custom Venmo Button", nil);
}

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Venmo (custom button)", nil) forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.darkGrayColor forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tappedCustomVenmo) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedCustomVenmo {
    self.progressBlock(@"Tapped Venmo - initiating Venmo auth");
    BTVenmoRequest *venmoRequest = [[BTVenmoRequest alloc] initWithPaymentMethodUsage:BTVenmoPaymentMethodUsageMultiUse];
    [venmoRequest setVault:YES];
    [self.venmoClient tokenizeVenmoAccountWithVenmoRequest:venmoRequest completion:^(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error) {
        if (venmoAccount) {
            self.progressBlock(@"Got a nonce 💎!");
            NSLog(@"%@", [venmoAccount debugDescription]);
            self.completionBlock(venmoAccount);
        } else if (error) {
            self.progressBlock(error.localizedDescription);
        } else {
            self.progressBlock(@"Canceled 🔰");
        }
    }];
}

@end
