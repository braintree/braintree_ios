#import "BraintreeDemoPayPalScopesViewController.h"

#import <BraintreePayPal/BraintreePayPal.h>
#import <BraintreeUI/BraintreeUI.h>

@interface BraintreeDemoPayPalScopesViewController ()
@property(nonatomic, strong) UITextView *addressTextView;
@end

@implementation BraintreeDemoPayPalScopesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.addressTextView = [[UITextView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 2) - 100, (self.view.bounds.size.width / 8) * 7, 200, 100)];
    [self.view addSubview:self.addressTextView];
    self.addressTextView.backgroundColor = [UIColor clearColor];

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
    [button setTitle:@"PayPal (Address Scope)" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor blueColor] bt_adjustedBrightness:0.5] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tappedCustomPayPal) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedCustomPayPal {
    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];
    self.progressBlock(@"Tapped PayPal - initiating authorization using BTPayPalDriver");

    [driver authorizeAccountWithAdditionalScopes:[NSSet setWithArray:@[@"address"]] completion:^(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
        } else if (tokenizedPayPalAccount) {
            self.completionBlock(tokenizedPayPalAccount);

            BTPostalAddress *address = tokenizedPayPalAccount.accountAddress;
            self.addressTextView.text = [NSString stringWithFormat:@"Address:\n%@\n%@\n%@ %@\n%@ %@", address.streetAddress, address.extendedAddress, address.locality, address.region, address.postalCode, address.countryCodeAlpha2];
        } else {
            self.progressBlock(@"Cancelled");
        }
    }];
}

@end
