#import "BTEnrollmentVerificationViewController.h"
#import "BTKBarButtonItem.h"

@interface BTEnrollmentVerificationViewController ()

@property (nonatomic, strong) NSString* mobilePhoneNumber;
@property (nonatomic, strong) NSString* mobileCountryCode;
@property (nonatomic, strong) BTEnrollmentHandler handler;
@property (nonatomic, strong) BTKFormField* smsTextField;
@property (nonatomic, strong) UILabel* smsSentLabel;

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
        self.navigationController.navigationBar.barTintColor = [BTKAppearance sharedInstance].barBackgroundColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [BTKAppearance sharedInstance].primaryTextColor, NSFontAttributeName:[UIFont fontWithName:[BTKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]}];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[BTKBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [BTKAppearance sharedInstance].sheetBackgroundColor;
    self.smsSentLabel = [UILabel new];
    self.smsSentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.smsSentLabel.textAlignment = NSTextAlignmentCenter;
    self.smsSentLabel.text = [NSString stringWithFormat:@"Enter the SMS code sent to\n+%@ %@", self.mobileCountryCode, self.mobilePhoneNumber];
    self.smsSentLabel.numberOfLines = 0;
    [self.view addSubview:self.smsSentLabel];
    [BTKAppearance styleLabelPrimary:self.smsSentLabel];

    self.smsTextField = [BTKFormField new];
    self.smsTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.smsTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.smsTextField.textField.placeholder = @"SMS Code";
    self.smsTextField.delegate = self;
    self.smsTextField.textField.inputAccessoryView = [[BTKInputAccessoryToolbar alloc] initWithDoneButtonForInput:self.smsTextField.textField];
    [self.view addSubview:self.smsTextField];

    NSDictionary* viewBindings = @{
                                   @"smsSentLabel": self.smsSentLabel,
                                   @"smsTextField": self.smsTextField
                                   };

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[smsSentLabel]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[smsTextField]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[smsSentLabel]-(20)-[smsTextField(44)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];
}

- (void)formFieldDidChange:(BTKFormField *)formField {
    if (formField.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirm {
    self.handler(self.smsTextField.text);
}

@end
