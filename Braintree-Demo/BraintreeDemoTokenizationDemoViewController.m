#import "BraintreeDemoTokenizationDemoViewController.h"

#import <Braintree/Braintree.h>

@interface BraintreeDemoTokenizationDemoViewController ()

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

    self.title = @"Custom: Tokenization";
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                              target:self
                                                                                              action:@selector(submitForm)],
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                                              target:self
                                                                                              action:@selector(setupDemoData)]
                                                ];

    [self.cardNumberField becomeFirstResponder];
}

- (void)submitForm {
    NSLog(@"Tokenizing card!");
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.braintree tokenizeCardWithNumber:self.cardNumberField.text
                           expirationMonth:self.expirationMonthField.text
                            expirationYear:self.expirationYearField.text
                                completion:^(NSString *nonce, NSError *error) {
                                    [self.navigationItem.rightBarButtonItem setEnabled:YES];
                                    if (error) {
                                        NSLog(@"Error: %@", error);
                                        [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[error localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil] show];
                                    }

                                    if (nonce) {
                                        NSLog(@"Card tokenized -> Nonce Received: %@", nonce);
                                        self.completionBlock(nonce);
                                    }
                                }];
}

- (void)setupDemoData {
    self.cardNumberField.text = @"4111111111111111";
    self.expirationMonthField.text = @"12";
    self.expirationYearField.text = @"2038";
}

#pragma mark Table View Overrides

- (NSString *)tableView:(__unused UITableView *)tableView titleForHeaderInSection:(__unused NSInteger)section {
    return @"Custom Card Form";
}

@end