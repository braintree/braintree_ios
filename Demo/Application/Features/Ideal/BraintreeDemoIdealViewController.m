#import "BraintreeDemoIdealViewController.h"
@import BraintreePaymentFlow;

@interface BraintreeDemoIdealViewController () <BTViewControllerPresentingDelegate, BTLocalPaymentRequestDelegate>

@property (nonatomic, strong) BTPaymentFlowDriver *paymentFlowDriver;
@property (nonatomic, weak) UILabel *paymentIDLabel;

@end

@implementation BraintreeDemoIdealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressBlock(@"Loading iDEAL Merchant Account...");
    self.paymentButton.hidden = NO;
    [self setUpPaymentIDField];
    self.progressBlock(@"Ready!");
    self.title = NSLocalizedString(@"iDEAL", nil);
}

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Pay With iDEAL", nil) forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.darkGrayColor forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(idealButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setUpPaymentIDField {
    UILabel *paymentIDLabel = [[UILabel alloc] init];
    paymentIDLabel.translatesAutoresizingMaskIntoConstraints = NO;
    paymentIDLabel.numberOfLines = 0;
    [self.view addSubview:paymentIDLabel];
    [paymentIDLabel.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor constant:8.0].active = YES;
    [paymentIDLabel.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor constant:8.0].active = YES;
    [paymentIDLabel.topAnchor constraintEqualToAnchor:self.paymentButton.bottomAnchor constant:8.0].active = YES;
    [paymentIDLabel.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor constant:8.0].active = YES;
    self.paymentIDLabel = paymentIDLabel;
}

- (void)idealButtonTapped {
    self.paymentIDLabel.text = nil;
    [self startPaymentWithBank];
}

- (void)startPaymentWithBank {
    BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:@"sandbox_f252zhq7_hh4cpc39zq4rgjcg"];
    self.paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:client];
    self.paymentFlowDriver.viewControllerPresentingDelegate = self;

    BTLocalPaymentRequest *request = [[BTLocalPaymentRequest alloc] init];
    request.paymentType = @"ideal";
    request.paymentTypeCountryCode = @"NL";
    request.currencyCode = @"EUR";
    request.amount = @"1.01";
    request.givenName = @"Linh";
    request.surname = @"Ngo";
    request.phone = @"639847934";
    request.address = [BTPostalAddress new];
    request.address.countryCodeAlpha2 = @"NL";
    request.address.postalCode = @"2585 GJ";
    request.address.streetAddress = @"836486 of 22321 Park Lake";
    request.address.locality = @"Den Haag";
    request.email = @"lingo-buyer@paypal.com";
    request.shippingAddressRequired = NO;
    request.localPaymentFlowDelegate = self;

    void (^paymentFlowCompletionBlock)(BTPaymentFlowResult *, NSError *) = ^(BTPaymentFlowResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            if (error.code == BTPaymentFlowDriverErrorTypeCanceled) {
                self.progressBlock(@"Canceled 🎲");
            } else {
                self.progressBlock([NSString stringWithFormat:@"Error: %@", error]);
            }
        } else if (result) {
            BTLocalPaymentResult *localPaymentResult = (BTLocalPaymentResult *)result;
            BTPaymentMethodNonce *nonce = [[BTPaymentMethodNonce alloc] initWithNonce:localPaymentResult.nonce];
            self.completionBlock(nonce);
        }
    };

    [self.paymentFlowDriver startPaymentFlow:request completion:paymentFlowCompletionBlock];
}

#pragma mark BTViewControllerPresentingDelegate

- (void)paymentDriver:(__unused id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(__unused id)driver requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark BTIdealRequestDelegate

- (void)localPaymentStarted:(__unused BTLocalPaymentRequest *)request paymentID:(NSString *)paymentID start:(void (^)(void))start {
    self.paymentIDLabel.text = [NSString stringWithFormat:@"LocalPayment ID: %@", paymentID];
    // Do preprocessing if necessary before calling start()
    start();
}

@end
