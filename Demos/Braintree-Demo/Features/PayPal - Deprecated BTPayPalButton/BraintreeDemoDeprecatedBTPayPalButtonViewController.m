#import "BraintreeDemoDeprecatedBTPayPalButtonViewController.h"

@interface BraintreeDemoDeprecatedBTPayPalButtonViewController () <BTPayPalButtonDelegate, BTPayPalButtonViewControllerPresenterDelegate>
@property(nonatomic, strong) BTPayPalButton *paymentProvider;
@end

@implementation BraintreeDemoDeprecatedBTPayPalButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Deprecated BTPayPalButton";
}

- (UIView *)paymentButton {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BTPayPalButton *payPalButton = [self.braintree payPalButtonWithDelegate:self];
#pragma clang diagnostic pop

    [payPalButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    payPalButton.presentationDelegate = self;
    payPalButton.delegate = self;

    return payPalButton;
}


#pragma mark BTPayPalButtonDelegate

- (void)payPalButton:(__unused BTPayPalButton *)button didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    self.completionBlock(paymentMethod);
}

- (void)payPalButton:(__unused BTPayPalButton *)button didFailWithError:(NSError *)error {
    self.progressBlock(error.localizedDescription);
}

- (void)payPalButtonWillCreatePayPalPaymentMethod:(__unused BTPayPalButton *)button {
    self.progressBlock(@"PayPal Button will create");
}

- (void)payPalButtonDidCancel:(__unused BTPayPalButton *)button {
    self.progressBlock(@"PayPal Button did cancel");
}


#pragma mark BTPayPalButtonViewControllerPresentationDelegate

- (void)payPalButton:(__unused BTPayPalButton *)button requestsPresentationOfViewController:(UIViewController *)viewController {
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)payPalButton:(__unused BTPayPalButton *)button requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
