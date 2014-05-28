#import "BraintreePayPalDemoViewController.h"
#import "BTClient+BTPayPal.h"

@interface BraintreePayPalDemoViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet BTPayPalControl *payPalControl;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *payPalControlWidthConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *payPalControlHeightConstraint;

@end

@implementation BraintreePayPalDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.payPalControl setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.payPalControl.client = [[BTClient alloc] initWithClientToken:[BTClient btPayPal_offlineTestClientToken]];
    self.payPalControl.presentationDelegate = nil;
    self.payPalControl.delegate = self;
}

- (IBAction)heightSliderValueDidChange:(UISlider *)slider {
    self.payPalControlHeightConstraint.constant = slider.value * 100.0f;
    [self.view layoutIfNeeded];
}

- (IBAction)widthSliderValueDidChange:(UISlider *)slider {
    self.payPalControlWidthConstraint.constant = slider.value * 280.0f;
    [self.view layoutIfNeeded];
}

- (IBAction)toggledShouldUseCustomPresentationDelegate:(UISwitch *)sender {
    self.payPalControl.presentationDelegate = (sender.on ? self : nil);
}

# pragma mark - BTPayPalControlViewControllerPresenterDelegate implementation

- (void)payPalControl:(BTPayPalControl *)control requestsPresentationOfViewController:(UIViewController *)viewController {
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)payPalControl:(BTPayPalControl *)control requestsDismissalOfViewController:(UIViewController *)viewController {
    [self.progressBar setProgress:0.0f animated:NO];
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BTPayPalControlDelegate implementation

- (void)payPalControl:(BTPayPalControl *)control didCreatePayPalPaymentMethod:(NSString *)paymentMethod {
    NSLog(@"payPalControl:%@ addedPaymentMethod:%@", control, paymentMethod);
}

- (void)payPalControl:(BTPayPalControl *)control didFailWithError:(NSError *)error {
    NSLog(@"payPalControl:%@ didFailWithError:%@", control, error);
    [[[UIAlertView alloc] initWithTitle:@"Fail"
                                message:[error description]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
