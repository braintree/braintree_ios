#import "BTClient+Testing.h"
#import <PureLayout/PureLayout.h>
#import "PayPalMobile.h"

#import "BTCoinbaseAcceptanceSpecViewController.h"

NSString *const BTCoinbaseAcceptanceSpecCoinbaseScheme = @"com.coinbase.oauth-authorize";

@implementation BTCoinbaseAcceptanceSpecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor whiteColor];
    [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                             BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                             BTClientTestConfigurationKeyCustomer:@YES,
                                             BTClientTestConfigurationKeyClientTokenVersion: @2 }
                                    async:YES
                               completion:^(BTClient *client) {
                                   id mockApplication = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
                                   [[mockApplication stub] openURL:[OCMArg isNotEqual:BTCoinbaseAcceptanceSpecCoinbaseScheme]];
                                   [[mockApplication stub] canOpenURL:[OCMArg isNotEqual:BTCoinbaseAcceptanceSpecCoinbaseScheme]];
                                   self.provider = [[BTPaymentProvider alloc] initWithClient:client];
                                   self.provider.delegate = self;
                                   UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                                   button.translatesAutoresizingMaskIntoConstraints = NO;
                                   [button setTitle:@"Coinbase" forState:UIControlStateNormal];
                                   [button addTarget:self action:@selector(tappedCoinbase) forControlEvents:UIControlEventTouchUpInside];
                                   [self.view addSubview:button];
                                   [button autoCenterInSuperviewMargins];
                                   
                                   [mockApplication stopMocking];
                               }];

    self.statusLabel = [[UILabel alloc] initForAutoLayout];
    self.statusLabel.text = @"Uninitialized";
    [self.view addSubview:self.statusLabel];
    [self.statusLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:8];
    [self.statusLabel autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
}

- (void)tappedCoinbase {
    [self.provider createPaymentMethod:BTPaymentProviderTypeCoinbase];
}

#pragma mark BTPaymentMethodCreateDelegate

- (void)paymentMethodCreatorWillProcess:(id)sender {
    self.statusLabel.text = @"Processing...";
}

- (void)paymentMethodCreatorDidCancel:(id)sender {
    self.statusLabel.text = @"Canceled";
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error {
    self.statusLabel.text = [NSString stringWithFormat:@"Failed with error. %@", error.localizedDescription];
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(id)sender {
    self.statusLabel.text = @"Performing app switch";
}

- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([paymentMethod isKindOfClass:[BTCoinbasePaymentMethod class]]) {
        self.statusLabel.text = [NSString stringWithFormat:@"Got a ฿ nonce! %@", paymentMethod];
    }
}

- (void)paymentMethodCreator:(id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentMethodCreator:(id)sender requestsDismissalOfViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
