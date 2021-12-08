#import "BraintreeDemoUnionPayViewController.h"
#import "Demo-Swift.h"
@import BraintreeUnionPay;

@interface BraintreeDemoUnionPayViewController () <UITextFieldDelegate>

@property (nonatomic, strong) BTCardFormView *cardFormView;
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

    [self layoutUIComponents];
}

#pragma mark - Layout UI

- (void)layoutUIComponents {
    self.cardFormView = [[BTCardFormView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.cardFormView];
    self.cardFormView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cardFormView.hidePostalCodeField = YES;
    self.cardFormView.hideCVVField = YES;

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

    [NSLayoutConstraint activateConstraints:@[
        [self.cardFormView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.cardFormView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.cardFormView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.cardFormView.heightAnchor constraintEqualToConstant:150]
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [self.submitButton.topAnchor constraintEqualToAnchor:self.cardFormView.bottomAnchor constant: 20.0],
        [self.submitButton.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.submitButton.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.submitButton.heightAnchor constraintEqualToConstant:50]
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [self.smsButton.topAnchor constraintEqualToAnchor:self.submitButton.bottomAnchor],
        [self.smsButton.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.smsButton.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.smsButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

#pragma mark - Actions

- (void)enroll:(__unused UIButton *)button {
    self.progressBlock(@"Enrolling card");

    BTCard *card = [BTCard new];
    if (self.cardFormView.cardNumber) {
        card.number = self.cardFormView.cardNumber;
    }
    if (self.cardFormView.expirationYear) {
        card.expirationYear = self.cardFormView.expirationYear;
    }
    if (self.cardFormView.expirationMonth) {
        card.expirationMonth = self.cardFormView.expirationMonth;
    }
    if (self.cardFormView.cvv) {
        card.cvv = self.cardFormView.cvv;
    }

    BTCardRequest *request = [[BTCardRequest alloc] initWithCard:card];
    request.mobileCountryCode = @"62";
    if (self.cardFormView.phoneNumber) {
        request.mobilePhoneNumber = self.cardFormView.phoneNumber;
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
    if (self.cardFormView.cardNumber) {
        card.number = self.cardFormView.cardNumber;
    }
    if (self.cardFormView.expirationYear) {
        card.expirationYear = self.cardFormView.expirationYear;
    }
    if (self.cardFormView.expirationMonth) {
        card.expirationMonth = self.cardFormView.expirationMonth;
    }
    if (self.cardFormView.cvv) {
        card.cvv = self.cardFormView.cvv;
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
