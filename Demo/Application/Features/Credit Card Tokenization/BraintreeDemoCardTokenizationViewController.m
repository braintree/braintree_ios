#import "BraintreeDemoCardTokenizationViewController.h"
@import BraintreeCard;

@interface BraintreeDemoCardTokenizationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *cardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *expirationMonthField;
@property (weak, nonatomic) IBOutlet UITextField *expirationYearField;
@property (weak, nonatomic) IBOutlet UISwitch *validateCardSwitch;

@property (weak, nonatomic) IBOutlet UIButton *autofillValidCardButton;
@property (weak, nonatomic) IBOutlet UIButton *autofillInvalidCardButton;
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
}

- (IBAction)submitForm {
    self.progressBlock(@"Tokenizing card details!");

    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    BTCard *card = [[BTCard alloc] initWithNumber:self.cardNumberField.text
                                  expirationMonth:self.expirationMonthField.text
                                   expirationYear:self.expirationYearField.text
                                              cvv:nil];
    card.shouldValidate = self.validateCardSwitch.isOn;

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

- (IBAction)autofillValidCard {
    self.cardNumberField.text = @"4111111111111111";
    self.expirationMonthField.text = @"12";
    self.expirationYearField.text = @"2038";
}

- (IBAction)autofillInvalidCard {
    self.cardNumberField.text = @"123123";
    self.expirationMonthField.text = @"XX";
    self.expirationYearField.text = @"XXXX";
}

- (void)setFieldsEnabled:(BOOL)enabled {
    self.cardNumberField.enabled = enabled;
    self.expirationMonthField.enabled = enabled;
    self.expirationYearField.enabled = enabled;
    self.submitButton.enabled = enabled;
    self.autofillValidCardButton.enabled = enabled;
    self.autofillInvalidCardButton.enabled = enabled;
}

@end
