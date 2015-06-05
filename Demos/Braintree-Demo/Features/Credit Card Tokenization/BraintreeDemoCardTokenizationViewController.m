#import "BraintreeDemoCardTokenizationViewController.h"

#import <Braintree/Braintree.h>
#import <CardIO/CardIO.h>

#import "BraintreeDemoSettings.h"

@interface BraintreeDemoCardTokenizationViewController () <CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) IBOutlet UITextField *cardNumberField;
@property (nonatomic, strong) IBOutlet UITextField *expirationMonthField;
@property (nonatomic, strong) IBOutlet UITextField *expirationYearField;

@property (weak, nonatomic) IBOutlet UIButton *cardIOButton;
@property (weak, nonatomic) IBOutlet UIButton *autofillButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation BraintreeDemoCardTokenizationViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.braintree = [Braintree braintreeWithClientToken:clientToken];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Tokenization";
    self.edgesForExtendedLayout = UIRectEdgeBottom;

    [CardIOUtilities preload];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    self.progressBlock([NSString stringWithFormat:@"Scanned a card with Card.IO: %@", [cardInfo redactedCardNumber]]);

    if (cardInfo.expiryYear) {
        self.expirationYearField.text = [NSString stringWithFormat:@"%d", (int)cardInfo.expiryYear];
    }

    if (cardInfo.expiryMonth) {
        self.expirationMonthField.text = [NSString stringWithFormat:@"%d", (int)cardInfo.expiryMonth];
    }

    self.cardNumberField.text = cardInfo.cardNumber;

    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(__unused BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)submitForm {
    self.progressBlock(@"Tokenizing card details!");

    [self setFieldsEnabled:NO];

    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
    request.number = self.cardNumberField.text;
    request.expirationMonth = self.expirationMonthField.text;
    request.expirationYear = self.expirationYearField.text;

    [self.braintree tokenizeCard:request
                      completion:^(NSString *nonce, NSError *error) {
                          [self setFieldsEnabled:YES];
                          if (error) {
                              self.progressBlock([NSString stringWithFormat:@"Error: %@", error]);
                              [[[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[error localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil] show];
                          }

                          if (nonce) {
                              self.progressBlock([NSString stringWithFormat:@"Card tokenized -> Nonce Received: %@", nonce]);
                              self.completionBlock(nonce);
                          }
                      }];
}

- (IBAction)setupDemoData {
    self.cardNumberField.text = @"4111111111111111";
    self.expirationMonthField.text = @"12";
    self.expirationYearField.text = @"2038";
}

- (IBAction)presentCardIO {
    CardIOPaymentViewController *cardIO = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    cardIO.collectExpiry = YES;
    cardIO.collectCVV = NO;
    cardIO.useCardIOLogo = YES;
    cardIO.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cardIO animated:YES completion:nil];

}

- (void)setFieldsEnabled:(BOOL)enabled {
    self.cardNumberField.enabled = enabled;
    self.expirationMonthField.enabled = enabled;
    self.expirationYearField.enabled = enabled;
    self.submitButton.enabled = enabled;
    self.cardIOButton.enabled = enabled;
    self.autofillButton.enabled = enabled;

}

#pragma mark Table View Overrides

- (NSString *)tableView:(__unused UITableView *)tableView titleForHeaderInSection:(__unused NSInteger)section {
    return @"Custom Card Form";
}


@end
