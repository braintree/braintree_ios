#import "BraintreeDemoUnionPayViewController.h"
#import "Demo-Swift.h"
@import BraintreeUnionPay;

@interface BraintreeDemoUnionPayViewController () <UITextFieldDelegate>

@property (nonatomic, strong) CardFormView *cardFormView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *smsButton;
@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, strong) BTCardClient *cardClient;
@property (nonatomic, copy) NSString *lastCardNumber;

@end

@implementation BraintreeDemoUnionPayViewController

- (instancetype)initWithAuthorization:(NSString *)authorization {
    if (self = [super initWithAuthorization:authorization]) {
        _apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
        _cardClient = [[BTCardClient alloc] initWithAPIClient:_apiClient];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"UnionPay", nil);
    self.edgesForExtendedLayout = UIRectEdgeBottom;

    UINib *cardFormNib = [UINib nibWithNibName:@"CardFormView" bundle:nil];
    self.cardFormView = [cardFormNib instantiateWithOwner:self options:nil][0];
    self.cardFormView.hidePostalCodeField = YES;
    self.cardFormView.hideCVVTextField = YES;
    self.cardFormView.cardNumberTextField.delegate = self;

    [self.view addSubview:self.cardFormView];

    [NSLayoutConstraint activateConstraints:@[
        [self.cardFormView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.cardFormView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.cardFormView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor]
    ]];

    self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.submitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];

    self.smsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.smsButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.smsButton.hidden = YES;
    [self.smsButton setTitle:NSLocalizedString(@"Send SMS", nil) forState:UIControlStateNormal];
    [self.smsButton addTarget:self action:@selector(enroll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.smsButton];

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[cardFormView]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:@{@"cardFormView" : self.cardFormView}]];
    [self.view addConstraint:[NSLayoutConstraint
                               constraintWithItem:self.submitButton
                               attribute:NSLayoutAttributeCenterX
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeCenterX
                               multiplier:1
                               constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                               constraintWithItem:self.smsButton
                               attribute:NSLayoutAttributeCenterX
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeCenterX
                               multiplier:1
                               constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                               constraintWithItem:self.cardFormView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeTop
                               multiplier:1
                               constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                               constraintWithItem:self.cardFormView
                               attribute:NSLayoutAttributeBottom
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.smsButton
                               attribute:NSLayoutAttributeTop
                               multiplier:1
                               constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                               constraintWithItem:self.smsButton
                               attribute:NSLayoutAttributeBottom
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.submitButton
                               attribute:NSLayoutAttributeTop
                               multiplier:1
                               constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                               constraintWithItem:self.submitButton
                               attribute:NSLayoutAttributeBottom
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeBottom
                               multiplier:1
                               constant:0]];
}

#pragma mark - Actions

- (void)enroll:(__unused UIButton *)button {
    self.progressBlock(@"Enrolling card");

    BTCard *card = [BTCard new];
    if (self.cardFormView.cardNumberTextField &&
        self.cardFormView.expirationMonthTextField &&
        self.cardFormView.expirationYearTextField &&
        self.cardFormView.cvvTextField) {
        card.number = self.cardFormView.cardNumberTextField.text;
        card.expirationMonth = self.cardFormView.expirationMonthTextField.text;
        card.expirationYear = self.cardFormView.expirationYearTextField.text;
        card.cvv = self.cardFormView.cvvTextField.text;
    }

    BTCardRequest *request = [[BTCardRequest alloc] initWithCard:card];
    request.mobileCountryCode = @"62";
    if (self.cardFormView.phoneNumberTextField.text) {
        request.mobilePhoneNumber = self.cardFormView.phoneNumberTextField.text;
    }

    [self.cardClient enrollCard:request completion:^(NSString * _Nullable enrollmentID, BOOL smsCodeRequired, NSError * _Nullable error) {
        if (error) {
            NSMutableString *errorMessage = [NSMutableString stringWithFormat:@"Error enrolling card: %@", error.localizedDescription];
            if (error.localizedFailureReason) {
                [errorMessage appendString:[NSString stringWithFormat:@". %@", error.localizedFailureReason]];
            }
            self.progressBlock(errorMessage);
            return;
        }
        
        request.enrollmentID = enrollmentID;
        
        if (smsCodeRequired) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SMS Auth Code", nil) message:NSLocalizedString(@"SMSAuthCodeMessage", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:nil];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Submit", nil) style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction * _Nonnull action) {
                UITextField *codeTextField = [alertController.textFields firstObject];
                NSString *authCode = codeTextField.text;
                request.smsCode = authCode;
                
                self.progressBlock(@"Tokenizing card");
                
                [self.cardClient tokenizeCard:request options:nil completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
                    if (error) {
                        self.progressBlock([NSString stringWithFormat:@"Error tokenizing card: %@", error.localizedDescription]);
                        return;
                    }
                    
                    self.completionBlock(tokenizedCard);
                }];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [self.cardClient tokenizeCard:request options:nil completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
                if (error) {
                    NSMutableString *errorMessage = [NSMutableString stringWithFormat:@"Error tokenizing card: %@", error.localizedDescription];
                    if (error.localizedFailureReason) {
                        [errorMessage appendString:[NSString stringWithFormat:@". %@", error.localizedFailureReason]];
                    }
                    self.progressBlock(errorMessage);
                    return;
                }
                
                self.completionBlock(tokenizedCard);
            }];
        }
    }];
}

- (void)submit:(__unused UIButton *)button {
    self.progressBlock(@"Tokenizing card");

    BTCard *card = [BTCard new];
    if (self.cardFormView.cardNumberTextField &&
        self.cardFormView.expirationMonthTextField &&
        self.cardFormView.expirationYearTextField &&
        self.cardFormView.cvvTextField) {
        card.number = self.cardFormView.cardNumberTextField.text;
        card.expirationMonth = self.cardFormView.expirationMonthTextField.text;
        card.expirationYear = self.cardFormView.expirationYearTextField.text;
        card.cvv = self.cardFormView.cvvTextField.text;
    }

    [self.cardClient tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {
        if (error) {
            self.progressBlock([NSString stringWithFormat:@"Error tokenizing card: %@", error.localizedDescription]);
            return;
        }

        self.completionBlock(tokenizedCard);
    }];
}

#pragma mark - Private methods

- (void)fetchCapabilities:(NSString *)cardNumber {
    [self.cardClient fetchCapabilities:cardNumber completion:^(BTCardCapabilities * _Nullable cardCapabilities, NSError * _Nullable error) {
        if (error) {
            self.progressBlock([NSString stringWithFormat:@"Error fetching capabilities: %@", error.localizedDescription]);
            return;
        }

        if (cardCapabilities.isSupported) {
            self.smsButton.hidden = NO;
            self.submitButton.hidden = NO;
        } else {
            self.progressBlock([NSString stringWithFormat:@"This UnionPay card cannot be processed, please try another card."]);
            self.submitButton.hidden = YES;
        }

        if (cardCapabilities.isDebit) {
            NSLog(@"Debit card");
        } else {
            NSLog(@"Credit card");
        }
    }];
}

#pragma mark - UITextFieldDelegate methods

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.cardFormView.cardNumberTextField.text &&
        ![self.cardFormView.cardNumberTextField.text isEqualToString:self.lastCardNumber]) {
        [self fetchCapabilities:self.cardFormView.cardNumberTextField.text];
        self.lastCardNumber = self.cardFormView.cardNumberTextField.text;
    }
}

@end
