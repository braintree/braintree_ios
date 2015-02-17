#import "BraintreeDemoTokenizationDemoViewController.h"

#import <Braintree/Braintree.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <CardIO/CardIO.h>

#import "BraintreeDemoSettings.h"

@interface BraintreeDemoTokenizationDemoViewController () <CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, copy) void (^completionBlock)(NSString *);

@property (nonatomic, strong) IBOutlet UITextField *cardNumberField;
@property (nonatomic, strong) IBOutlet UITextField *expirationMonthField;
@property (nonatomic, strong) IBOutlet UITextField *expirationYearField;
@end

@implementation BraintreeDemoTokenizationDemoViewController

- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *))completionBlock {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.braintree = braintree;
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Tokenization";
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                              target:self
                                                                                              action:@selector(submitForm)],
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                                              target:self
                                                                                              action:@selector(setupDemoData)],
                                                ];

    UIButton *cardIOButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cardIOButton setTitle:@"Scan Card" forState:UIControlStateNormal];
    [cardIOButton addTarget:self action:@selector(presentCardIO) forControlEvents:UIControlEventTouchUpInside];
    cardIOButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:cardIOButton];
    NSDictionary *views = @{ @"expirationYearField": self.expirationYearField, @"cardIOButton": cardIOButton };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[expirationYearField]-[cardIOButton]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cardIOButton]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];

    [CardIOUtilities preload];

}
- (void)presentCardIO {
    CardIOPaymentViewController *cardIO = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    cardIO.collectExpiry = YES;
    cardIO.collectCVV = NO;
    cardIO.useCardIOLogo = YES;
    cardIO.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cardIO animated:YES completion:nil];

}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"Scanned a card with Card.IO: %@", [cardInfo redactedCardNumber]);

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

- (void)submitForm {
    NSLog(@"Tokenizing card!");
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
    request.number = self.cardNumberField.text;
    request.expirationMonth = self.expirationMonthField.text;
    request.expirationYear = self.expirationYearField.text;

    [self.braintree tokenizeCard:request
                      completion:^(NSString *nonce, NSError *error) {
                          [self.navigationItem.rightBarButtonItem setEnabled:YES];
                          if (error) {
                              NSLog(@"Error: %@", error);
                              [[[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[error localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil] show];
                          }

                          if (nonce) {
                              NSLog(@"Card tokenized -> Nonce Received: %@", nonce);
                              [UIAlertView showWithTitle:@"Success"
                                                 message:@"Nonce Received"
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil
                                                tapBlock:^(__unused UIAlertView *alertView, __unused NSInteger buttonIndex) {
                                                    self.completionBlock(nonce);
                                                }];
                          }
                      }];
}

- (void)setupDemoData {
    if ([BraintreeDemoSettings threeDSecureEnabled]) {
        self.cardNumberField.text = @"4000000000000002";
        self.expirationMonthField.text = @"12";
        self.expirationYearField.text = @"2020";
    } else {
        self.cardNumberField.text = @"4111111111111111";
        self.expirationMonthField.text = @"12";
        self.expirationYearField.text = @"2038";
    }
}

#pragma mark Table View Overrides

- (NSString *)tableView:(__unused UITableView *)tableView titleForHeaderInSection:(__unused NSInteger)section {
    return @"Custom Card Form";
}

@end
