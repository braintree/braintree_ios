#import "BraintreeDemoCardTokenizationViewController.h"
#import "Demo-Swift.h"
@import BraintreeCard;
@import BraintreeCore;

@interface BraintreeDemoCardTokenizationViewController ()

@property (nonatomic, strong) BTCardFormView *cardFormView;
@property (nonatomic, strong) UIButton *autofillButton;
@end

@implementation BraintreeDemoCardTokenizationViewController

- (instancetype)initWithAuthorization:(NSString *)authorization {
    if (self = [super initWithAuthorization:authorization]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Card Tokenization", nil);

    self.cardFormView = [[BTCardFormView alloc] initWithFrame:CGRectZero];
    self.cardFormView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cardFormView.hidePhoneNumberField = YES;
    self.cardFormView.hidePostalCodeField = YES;

    [self setFieldsEnabled:YES];
    [self.view addSubview:self.cardFormView];

    self.autofillButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.autofillButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.autofillButton setTitle:NSLocalizedString(@"Autofill", nil) forState:UIControlStateNormal];
    [self.autofillButton addTarget:self action:@selector(tappedToAutofillCard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.autofillButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.cardFormView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.cardFormView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.cardFormView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.cardFormView.heightAnchor constraintEqualToConstant:200],

        [self.autofillButton.topAnchor constraintEqualToAnchor:self.cardFormView.bottomAnchor constant:10],
        [self.autofillButton.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:10],
        [self.autofillButton.heightAnchor constraintEqualToConstant:30],
    ]];
}

- (void)tappedSubmit {
    self.progressBlock(@"Tokenizing card details!");

    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    BTCard *card = [self newCard];

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

- (void)tappedToAutofillCard {
    self.cardFormView.cardNumberTextField.text = @"4111111111111111";
    self.cardFormView.cvvTextField.text = @"123";
    self.cardFormView.expirationTextField.text = self.generateFutureDate;
}

- (void)setFieldsEnabled:(BOOL)enabled {
    self.cardFormView.cardNumberTextField.enabled = enabled;
    self.cardFormView.expirationTextField.enabled = enabled;
    self.cardFormView.cvvTextField.enabled = enabled;
    self.autofillButton.enabled = enabled;
}

- (UIView *)createPaymentButton {
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    submitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(tappedSubmit) forControlEvents:UIControlEventTouchUpInside];

    UIView *cardButtonsContainer = [[UIView alloc] init];
    cardButtonsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [cardButtonsContainer addSubview:submitButton];

    [NSLayoutConstraint activateConstraints:@[
        [submitButton.topAnchor constraintEqualToAnchor:cardButtonsContainer.topAnchor],
        [submitButton.centerXAnchor constraintEqualToAnchor:cardButtonsContainer.centerXAnchor],
        [submitButton.leadingAnchor constraintEqualToAnchor:cardButtonsContainer.leadingAnchor],
        [submitButton.trailingAnchor constraintEqualToAnchor:cardButtonsContainer.trailingAnchor],
    ]];

    return cardButtonsContainer;
}

-(NSString *)generateFutureDate {
    NSString *monthString = @"12";

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy"];

    NSDate *futureYear = [[NSCalendar currentCalendar]dateByAddingUnit:NSCalendarUnitYear value:3 toDate:[NSDate date] options:0];
    NSString *yearString = [dateFormatter stringFromDate:futureYear];
    NSString *futureDateString = [NSString stringWithFormat:@"%@/%@", monthString, yearString];

    return futureDateString;
}

- (BTCard *)newCard {
    BTCard *card = [BTCard new];
    if (self.cardFormView.cardNumber != nil) {
        card.number = self.cardFormView.cardNumber;
    }
    if (self.cardFormView.expirationYear != nil) {
        card.expirationYear = self.cardFormView.expirationYear;
    }
    if (self.cardFormView.expirationMonth != nil) {
        card.expirationMonth = self.cardFormView.expirationMonth;
    }
    if (self.cardFormView.cvv != nil) {
        card.cvv = self.cardFormView.cvv;
    }

    return card;
}

@end
