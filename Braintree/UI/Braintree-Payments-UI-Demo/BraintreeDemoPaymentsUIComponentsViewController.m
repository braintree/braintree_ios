#import "BraintreeDemoPaymentsUIComponentsViewController.h"
#import <Braintree/BTUIPaymentMethodView.h>

@interface BraintreeDemoPaymentsUIComponentsViewController ()
@property (nonatomic, weak) IBOutlet BTUIPaymentMethodView *cardPaymentMethodView;
@property (nonatomic, weak) IBOutlet UISwitch *processingSwitch;
@end

@implementation BraintreeDemoPaymentsUIComponentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.processingSwitch setOn:self.cardPaymentMethodView.isProcessing];
}

- (IBAction)tappedCTAControl:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Tapped"
                               message:nil
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil] show];
}

- (IBAction)tappedSwapCardType {
    [self.cardPaymentMethodView setType:((self.cardPaymentMethodView.type+1) % (BTUIPaymentMethodTypePayPal+1))];
}

- (IBAction)toggledProcessingState:(UISwitch *)sender {
    self.cardPaymentMethodView.processing = sender.on;
}

@end
