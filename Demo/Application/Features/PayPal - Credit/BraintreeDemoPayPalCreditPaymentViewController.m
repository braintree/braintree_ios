#import "BraintreeDemoPayPalCreditPaymentViewController.h"
@import BraintreePayPal;

@interface BraintreeDemoPayPalCreditPaymentViewController () <BTAppSwitchDelegate>

@property (nonatomic, strong) UISegmentedControl *paypalTypeSwitch;

@end

@implementation BraintreeDemoPayPalCreditPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.paypalTypeSwitch = [[UISegmentedControl alloc] initWithItems:@[@"Checkout", @"Billing Agreement"]];
    self.paypalTypeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.paypalTypeSwitch.selectedSegmentIndex = 0;
    [self.view addSubview:self.paypalTypeSwitch];
    NSDictionary *viewBindings = @{
                                   @"view": self,
                                   @"paypalTypeSwitch":self.paypalTypeSwitch
                                   };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[paypalTypeSwitch]-(50)-|" options:0 metrics:nil views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[paypalTypeSwitch]-|" options:0 metrics:nil views:viewBindings]];

}

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"PayPal with Credit Offered", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:50.0/255 green:50.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(tappedPayPalOneTimePayment:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedPayPalOneTimePayment:(UIButton *)sender {
    
    if (self.paypalTypeSwitch.selectedSegmentIndex == 0) {
        self.progressBlock(@"Tapped - initiating Checkout payment with credit offered");
    } else {
        self.progressBlock(@"Tapped - initiating Billing Agreement payment with credit offered");
    }

    [sender setTitle:NSLocalizedString(@"Processing...", nil) forState:UIControlStateDisabled];
    [sender setEnabled:NO];

    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:self.apiClient];
    driver.appSwitchDelegate = self;

    if (self.paypalTypeSwitch.selectedSegmentIndex == 0) {
        BTPayPalCheckoutRequest *request = [[BTPayPalCheckoutRequest alloc] initWithAmount:@"4.30"];
        request.activeWindow = self.view.window;
        request.offerCredit = YES;

        [driver tokenizePayPalAccountWithPayPalRequest:request completion:^(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error) {
            [sender setEnabled:YES];
            
            if (error) {
                self.progressBlock(error.localizedDescription);
            } else if (payPalAccount) {
                self.completionBlock(payPalAccount);
            } else {
                self.progressBlock(@"Cancelled");
            }
        }];
    } else {
        BTPayPalVaultRequest *request = [[BTPayPalVaultRequest alloc] init];
        request.activeWindow = self.view.window;
        request.offerCredit = YES;

        [driver tokenizePayPalAccountWithPayPalRequest:request completion:^(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error) {
            [sender setEnabled:YES];
            
            if (error) {
                self.progressBlock(error.localizedDescription);
            } else if (payPalAccount) {
                self.completionBlock(payPalAccount);
            } else {
                self.progressBlock(@"Cancelled");
            }
        }];
    }
}

#pragma mark BTAppSwitchDelegate

- (void)appContextWillSwitch:(__unused id)appSwitcher {
   self.progressBlock(@"appContextWillSwitch:");
}

- (void)appContextDidReturn:(__unused id)appSwitcher {
    self.progressBlock(@"appContextDidReturn:");
}

@end
