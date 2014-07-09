#import "BraintreePayPalDemoViewController.h"
#import "BTClient+BTPayPal.h"

@interface BraintreePayPalDemoViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UILabel *nonceLabel;

@property (weak, nonatomic) IBOutlet BTPayPalButton *payPalButton;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *payPalButtonHeightConstraint;

@end

@implementation BraintreePayPalDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.payPalButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.payPalButton.client = [[BTClient alloc] initWithClientToken:[BTClient btPayPal_offlineTestClientToken]];
    self.payPalButton.presentationDelegate = nil;
    self.payPalButton.delegate = self;
}

- (IBAction)heightSliderValueDidChange:(UISlider *)slider {
    self.payPalButtonHeightConstraint.constant = slider.value * 100.0f;
    [self.view layoutIfNeeded];
}

- (IBAction)toggledShouldUseCustomPresentationDelegate:(UISwitch *)sender {
    self.payPalButton.presentationDelegate = (sender.on ? self : nil);
}

# pragma mark - BTPayPalButtonViewControllerPresenterDelegate implementation

- (void)payPalButton:(BTPayPalButton *)button requestsPresentationOfViewController:(UIViewController *)viewController {
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)payPalButton:(BTPayPalButton *)button requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BTPayPalButtonDelegate implementation

- (void)payPalButton:(BTPayPalButton *)button didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    NSLog(@"payPalButton:%@ addedPaymentMethod:(email:%@ nonce:%@)", button, paymentMethod.email, paymentMethod.nonce);
    self.emailLabel.text = paymentMethod.email;
    self.nonceLabel.text = paymentMethod.nonce;
}

- (void)payPalButton:(BTPayPalButton *)button didFailWithError:(NSError *)error {
    NSLog(@"payPalButton:%@ didFailWithError:%@", button, error);
    [[[UIAlertView alloc] initWithTitle:@"Fail"
                                message:[error description]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
