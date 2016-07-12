#import "BTEnrollmentVerificationViewController.h"
#import "BTUIKBarButtonItem.h"

@interface BTEnrollmentVerificationViewController ()

@property (nonatomic, strong) NSString* mobilePhoneNumber;
@property (nonatomic, strong) NSString* mobileCountryCode;
@property (nonatomic, strong) BTEnrollmentHandler handler;
@property (nonatomic, strong) BTUIKFormField* smsTextField;
@property (nonatomic, strong) UILabel* smsSentLabel;
@property (nonatomic, strong) UIButton *resendSmsButton;
@end

@implementation BTEnrollmentVerificationViewController

- (instancetype)initWithPhone:(NSString *)mobilePhoneNumber
            mobileCountryCode:(NSString *)mobileCountryCode
                      handler:(BTEnrollmentHandler)handler {
    if (self = [super init]) {
        _mobilePhoneNumber = mobilePhoneNumber;
        _mobileCountryCode = mobileCountryCode;
        _handler = handler;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Confirm Enrollment";
    if (self.navigationController != nil) {
        self.navigationController.navigationBar.barTintColor = [BTUIKAppearance sharedInstance].barBackgroundColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [BTUIKAppearance sharedInstance].primaryTextColor, NSFontAttributeName:[UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]}];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[BTUIKBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [BTUIKAppearance sharedInstance].sheetBackgroundColor;
    self.smsSentLabel = [UILabel new];
    self.smsSentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.smsSentLabel.textAlignment = NSTextAlignmentCenter;
    self.smsSentLabel.text = [NSString stringWithFormat:@"Enter the SMS code sent to\n+%@ %@", self.mobileCountryCode, self.mobilePhoneNumber];
    self.smsSentLabel.numberOfLines = 0;
    [self.view addSubview:self.smsSentLabel];
    [BTUIKAppearance styleLabelPrimary:self.smsSentLabel];

    self.smsTextField = [BTUIKFormField new];
    self.smsTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.smsTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.smsTextField.textField.placeholder = @"SMS Code";
    self.smsTextField.delegate = self;
    self.smsTextField.textField.inputAccessoryView = [[BTUIKInputAccessoryToolbar alloc] initWithDoneButtonForInput:self.smsTextField.textField];
    [self.view addSubview:self.smsTextField];
    
    NSString *smsButtonText = @"Didn't get an SMS code?";
    self.resendSmsButton = [UIButton new];
    self.resendSmsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.resendSmsButton setTitle:smsButtonText forState:UIControlStateNormal];
    
    NSAttributedString *normalValidateButtonString = [[NSAttributedString alloc] initWithString:smsButtonText attributes:@{NSForegroundColorAttributeName:[BTUIKAppearance sharedInstance].tintColor, NSFontAttributeName:[UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]}];
    [self.resendSmsButton setAttributedTitle:normalValidateButtonString forState:UIControlStateNormal];
    NSAttributedString *disabledValidateButtonString = [[NSAttributedString alloc] initWithString:smsButtonText attributes:@{NSForegroundColorAttributeName:[BTUIKAppearance sharedInstance].disabledColor, NSFontAttributeName:[UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]}];
    [self.resendSmsButton setAttributedTitle:disabledValidateButtonString forState:UIControlStateDisabled];
    
    [self.resendSmsButton sizeToFit];
    [self.resendSmsButton layoutIfNeeded];
    [self.resendSmsButton addTarget:self action:@selector(resendTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resendSmsButton];

    NSDictionary* viewBindings = @{
                                   @"smsSentLabel": self.smsSentLabel,
                                   @"smsTextField": self.smsTextField,
                                   @"resendSmsButton": self.resendSmsButton
                                   };

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[smsSentLabel]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[smsTextField]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[resendSmsButton]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[smsSentLabel]-(20)-[smsTextField(44)]-[resendSmsButton]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];
}

- (void)formFieldDidChange:(BTUIKFormField *)formField {
    if (formField.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resendTapped {
    self.handler(@"", YES);
}

- (void)confirm {
    self.handler(self.smsTextField.text, NO);
}

@end
