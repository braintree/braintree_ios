#import "BraintreeDemoCustomVenmoButtonViewController.h"
@import BraintreeVenmo;

@interface BraintreeDemoCustomVenmoButtonViewController ()

@property (nonatomic, strong) BTVenmoDriver *venmoDriver;

@end

@implementation BraintreeDemoCustomVenmoButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.venmoDriver = [[BTVenmoDriver alloc] initWithAPIClient:self.apiClient];
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
    BTVenmoRequest *venmoRequest = [[BTVenmoRequest alloc] init];
    [venmoRequest setVault:YES];
    [venmoRequest setPaymentMethodUsage:BTVenmoPaymentMethodUsageMultiUse];

    [venmoRequest setCollectCustomerShippingAddress:YES];
    [venmoRequest setCollectCustomerBillingAddress:YES];
    [venmoRequest setTotalAmount:@"30"];
    [venmoRequest setTaxAmount:@"1.1"];
    [venmoRequest setDiscountAmount:@"1.1"];
    [venmoRequest setShippingAmount:@"0"];
    BTVenmoLineItem *lineItem = [[BTVenmoLineItem alloc] initWithQuantity:@1 unitAmount:@"30" name:@"item-1" kind: BTVenmoLineItemKindDebit];
    [lineItem setUnitTaxAmount:@"1"];
    [venmoRequest setLineItems:[NSArray arrayWithObject: lineItem]];

    [self.venmoDriver tokenizeVenmoAccountWithVenmoRequest:venmoRequest completion:^(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error) {
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
