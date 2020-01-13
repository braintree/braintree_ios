#import "BraintreeDemoCardTokenizationViewController.h"
#import <BraintreeCard/BraintreeCard.h>

@interface BraintreeDemoCardTokenizationViewController ()

@property (nonatomic, strong) IBOutlet UITextField *cardNumberField;
@property (nonatomic, strong) IBOutlet UITextField *expirationMonthField;
@property (nonatomic, strong) IBOutlet UITextField *expirationYearField;

@property (weak, nonatomic) IBOutlet UIButton *autofillButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) BTAPIClient *apiClient;

@end

@implementation BraintreeDemoCardTokenizationViewController

- (instancetype)initWithAuthorization:(NSString *)authorization {
    if (self = [super initWithAuthorization:authorization]) {
        _apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Card Tokenization", nil);
    self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (IBAction)submitForm {
    self.progressBlock(@"Tokenizing card details!");

    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    BTCard *card = [[BTCard alloc] initWithNumber:self.cardNumberField.text
                                                                           expirationMonth:self.expirationMonthField.text
                                                                            expirationYear:self.expirationYearField.text
                                                                                       cvv:nil];

    [self setFieldsEnabled:NO];
    [cardClient tokenizeCard:card completion:^(BTCardNonce *tokenized, NSError *error) {
        [self setFieldsEnabled:YES];
        if (error) {
            self.progressBlock(error.localizedDescription);
            NSLog(@"Error: %@", error);
            return;
        }

        self.completionBlock(tokenized);
    }];
}

- (IBAction)setupDemoData {
    self.cardNumberField.text = [@"4111111111111111" copy];
    self.expirationMonthField.text = [@"12" copy];
    self.expirationYearField.text = [@"2038" copy];
}

- (void)setFieldsEnabled:(BOOL)enabled {
    self.cardNumberField.enabled = enabled;
    self.expirationMonthField.enabled = enabled;
    self.expirationYearField.enabled = enabled;
    self.submitButton.enabled = enabled;
    self.autofillButton.enabled = enabled;

}

@end
