#import "BraintreeDemoPayPalScopesViewController.h"
#import "BraintreeUI.h"
@import BraintreePayPal;

@interface BraintreeDemoPayPalScopesViewController () <BTViewControllerPresentingDelegate>

@property(nonatomic, strong) UILabel *addressLabel;

@end

@implementation BraintreeDemoPayPalScopesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.addressLabel = [[UILabel alloc] init];
    self.addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.addressLabel.numberOfLines = 0;
    self.addressLabel.backgroundColor = UIColor.blueColor;
    [self.view addSubview:self.addressLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.addressLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:10],
        [self.addressLabel.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-10],
        [self.addressLabel.topAnchor constraintEqualToAnchor:self.paymentButton.bottomAnchor constant:20]
    ]];

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

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"PayPal (Address Scope)", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor blueColor] bt_adjustedBrightness:0.5] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tappedCustomPayPal) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedCustomPayPal {
    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];
    driver.viewControllerPresentingDelegate = self;
    self.progressBlock(@"Tapped PayPal - initiating authorization using BTPayPalDriver");

    [driver authorizeAccountWithAdditionalScopes:[NSSet setWithArray:@[@"address"]] completion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
        } else if (tokenizedPayPalAccount) {
            self.completionBlock(tokenizedPayPalAccount);

            BTPostalAddress *address = tokenizedPayPalAccount.shippingAddress;
            self.addressLabel.text = [NSString stringWithFormat:@"Address:\n%@\n%@\n%@ %@\n%@ %@", address.streetAddress, address.extendedAddress, address.locality, address.region, address.postalCode, address.countryCodeAlpha2];
        } else {
            self.progressBlock(@"Cancelled");
        }
    }];
}

- (void)paymentDriver:(__unused id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(__unused id)driver requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
