#import "BTCardFormViewController.h"
#import "BTDropInController.h"
#import "BTPaymentSelectionViewController.h"
#import "BTConfiguration.h"
#import "BTAPIClient_Internal.h"
#import "BTUIKBarButtonItem.h"
#if __has_include("BraintreeCard.h")
#import "BraintreeCard.h"
#else
#import <BraintreeCard/BraintreeCard.h>
#endif
#if __has_include("BraintreeUnionPay.h")
#import "BraintreeUnionPay.h"
#else
#import <BraintreeUnionPay.h>
#endif

@interface BTCardFormViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollViewContentWrapper;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong, readwrite) BTUIKCardNumberFormField *cardNumberField;
@property (nonatomic, strong, readwrite) BTUIKExpiryFormField *expirationDateField;
@property (nonatomic, strong, readwrite) BTUIKSecurityCodeFormField *securityCodeField;
@property (nonatomic, strong, readwrite) BTUIKPostalCodeFormField *postalCodeField;
@property (nonatomic, strong, readwrite) BTUIKMobileCountryCodeFormField *mobileCountryCodeField;
@property (nonatomic, strong, readwrite) BTUIKMobileNumberFormField *mobilePhoneField;
@property (nonatomic, strong) UIStackView *cardNumberErrorView;
@property (nonatomic, strong) UIStackView *cardNumberHeader;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) NSArray <BTUIKFormField *> *formFields;
@property (nonatomic, strong) NSMutableArray <BTUIKFormField *> *requiredFields;
@property (nonatomic, strong) NSMutableArray <BTUIKFormField *> *optionalFields;
@property (nonatomic, strong) UIStackView *cardNumberFooter;
@property (nonatomic, strong) BTUIKCardListLabel *cardList;
@property (nonatomic, getter=isCollapsed) BOOL collapsed;
@property (nonatomic, strong, nullable, readwrite) BTCardCapabilities *cardCapabilities;
@property (nonatomic) BOOL unionPayEnabledMerchant;
@property (nonatomic, assign) BOOL cardEntryDidBegin;
@property (nonatomic, assign) BOOL cardEntryDidFocus;
@end

@implementation BTCardFormViewController

#define ADD_CARD_BAR_BUTTON_ITEM_TAG 8292

#pragma mark - Lifecycle

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient request:(nonnull BTDropInRequest *)request {
    if (self = [super initWithAPIClient:apiClient request:request]) {
        _requiredFields = [NSMutableArray new];
        _optionalFields = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Using ivar so that setter is not called
    _collapsed = YES;
    self.unionPayEnabledMerchant = NO;
    self.formFields = @[];
    self.view.translatesAutoresizingMaskIntoConstraints = false;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView setAlwaysBounceVertical:NO];
    self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.scrollViewContentWrapper = [[UIView alloc] init];
    self.scrollViewContentWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.scrollViewContentWrapper];
    
    self.stackView = [self newStackView];
    [self.scrollViewContentWrapper addSubview:self.stackView];

    self.view.translatesAutoresizingMaskIntoConstraints = false;
    self.view.backgroundColor = [UIColor clearColor];
    
    NSDictionary *viewBindings = @{@"stackView":self.stackView,
                                   @"scrollView":self.scrollView,
                                   @"scrollViewContentWrapper": self.scrollViewContentWrapper};
    
    NSDictionary *metrics = @{};

    [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollViewContentWrapper]|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:viewBindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollViewContentWrapper(scrollView)]|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stackView]|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[stackView]-|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:viewBindings]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];

    [self.view addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [self setupForm];
    [self resetForm];
    [self showLoadingScreen:YES animated:NO];
    [self loadConfiguration];
}

#pragma mark - Setup

- (void)setupForm
{
    self.nextButton = [[UIButton alloc] init];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.nextButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    
    self.cardNumberField = [[BTUIKCardNumberFormField alloc] init];
    self.cardNumberField.delegate = self;
    self.cardNumberField.cardNumberDelegate = self;
    self.expirationDateField = [[BTUIKExpiryFormField alloc] init];
    self.expirationDateField.delegate = self;
    self.securityCodeField = [[BTUIKSecurityCodeFormField alloc] init];
    self.securityCodeField.delegate = self;
    self.postalCodeField = [[BTUIKPostalCodeFormField alloc] init];
    self.postalCodeField.delegate = self;
    self.mobileCountryCodeField = [[BTUIKMobileCountryCodeFormField alloc] init];
    self.mobileCountryCodeField.delegate = self;
    self.mobilePhoneField = [[BTUIKMobileNumberFormField alloc] init];
    self.mobilePhoneField.delegate = self;

    self.cardNumberHeader = [self newStackView];
    self.cardNumberHeader.layoutMargins = UIEdgeInsetsMake(0, 40, 0, 40);
    self.cardNumberHeader.layoutMarginsRelativeArrangement = true;
    UILabel *cardNumberHeaderLabel = [[UILabel alloc] init];
    cardNumberHeaderLabel.numberOfLines = 0;
    cardNumberHeaderLabel.textAlignment = NSTextAlignmentCenter;
    cardNumberHeaderLabel.text = @"Enter your card details. Let's start with the card number...";
    [BTUIKAppearance styleLabelPrimary:cardNumberHeaderLabel];
    [self.cardNumberHeader addArrangedSubview:cardNumberHeaderLabel];
    [self addSpacerToStackView:self.cardNumberHeader beforeView:cardNumberHeaderLabel];
    [self.stackView addArrangedSubview:self.cardNumberHeader];

    self.formFields = @[self.cardNumberField, self.expirationDateField, self.securityCodeField, self.postalCodeField, self.mobileCountryCodeField, self.mobilePhoneField];
    
    for (NSUInteger i = 0; i < self.formFields.count; i++) {
        BTUIKFormField *formField = self.formFields[i];
        [self.stackView addArrangedSubview:formField];
        
        NSLayoutConstraint* heightConstraint = [formField.heightAnchor constraintEqualToConstant:44];
        // Setting the prioprity is necessary to avoid autolayout errors when UIStackView rotates
        heightConstraint.priority = UILayoutPriorityDefaultHigh;
        heightConstraint.active = YES;
        
        [formField updateConstraints];
    }
    
    self.cardNumberField.formLabel.text = @"";
    [self.cardNumberField updateConstraints];

    self.expirationDateField.hidden = YES;
    self.securityCodeField.hidden = YES;
    self.postalCodeField.hidden = YES;
    self.mobileCountryCodeField.hidden = YES;
    self.mobilePhoneField.hidden = YES;
    
    [self addSpacerToStackView:self.stackView beforeView:self.cardNumberField];
    [self addSpacerToStackView:self.stackView beforeView:self.expirationDateField];
    [self addSpacerToStackView:self.stackView beforeView:self.mobileCountryCodeField];
    
    self.cardNumberFooter = [self newStackView];
    self.cardNumberFooter.layoutMargins = UIEdgeInsetsMake(0, 40, 0, 40);
    self.cardNumberFooter.layoutMarginsRelativeArrangement = true;
    [self.stackView addArrangedSubview:self.cardNumberFooter];
    self.cardList = [BTUIKCardListLabel new];
    self.cardList.availablePaymentOptions = self.dropInRequest.displayCardTypes;
    [self.cardNumberFooter addArrangedSubview:self.cardList];
    [self addSpacerToStackView:self.cardNumberFooter beforeView:self.cardList];
    
    NSUInteger indexOfCardNumberField = [self.stackView.arrangedSubviews indexOfObject:self.cardNumberField];
    [self.stackView insertArrangedSubview:self.cardNumberFooter atIndex:(indexOfCardNumberField + 1)];
    
    [self updateFormBorders];

    //Error labels
    self.cardNumberErrorView = [self newStackViewForError:@"You must provide a valid Card Number."];
    [self cardNumberErrorHidden:YES];
}

- (void)configurationLoaded:(__unused BTConfiguration *)configuration error:(NSError *)error {
    [self showLoadingScreen:NO animated:YES];
    if (!error) {
        self.collapsed = YES;
        self.unionPayEnabledMerchant = NO;
        BTJSON *unionPayJSON = self.configuration.json[@"unionPay"];
        if (![unionPayJSON isError] && [unionPayJSON[@"enabled"] isTrue] && !self.apiClient.tokenizationKey) {
            self.unionPayEnabledMerchant = YES;
            self.cardNumberField.state = BTUIKCardNumberFormFieldStateValidate;
            [self.cardNumberField setAccessoryViewHidden:NO animated:NO];
        }

        [self updateRequiredFields];
    }
}

- (void)updateRequiredFields {
    NSArray <NSString *> *challenges = [self.configuration.json[@"challenges"] asStringArray];
    self.requiredFields = [NSMutableArray arrayWithArray:@[self.cardNumberField, self.expirationDateField]];
    if ([challenges containsObject:@"cvv"]) {
        [self.requiredFields addObject:self.securityCodeField];
    }
    if ([challenges containsObject:@"postal_code"]) {
        [self.requiredFields addObject:self.postalCodeField];
    }
}

#pragma mark - Custom accessors

- (BTCardRequest *)cardRequest {
    if (![self isFormValid]) {
        return nil;
    }

    BTCard *card = [[BTCard alloc] initWithNumber:self.cardNumberField.text
                                  expirationMonth:self.expirationDateField.expirationMonth
                                   expirationYear:self.expirationDateField.expirationYear
                                              cvv:self.securityCodeField.text];
    card.shouldValidate = self.apiClient.tokenizationKey ? NO : YES;
    BTCardRequest *cardRequest = [[BTCardRequest alloc] initWithCard:card];

    if (self.cardCapabilities != nil && self.cardCapabilities.isUnionPay && self.cardCapabilities.isSupported) {
        cardRequest.mobileCountryCode = self.mobileCountryCodeField.text;
        cardRequest.mobilePhoneNumber = self.mobilePhoneField.text;
    }

    return cardRequest;
}

- (void)setCollapsed:(BOOL)collapsed {
    if (collapsed == self.collapsed) {
        return;
    }
    // Using ivar so that setter is not called
    _collapsed = collapsed;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.cardNumberFooter.hidden = !collapsed;
            self.cardNumberHeader.hidden = !collapsed;
            self.expirationDateField.hidden = collapsed;
            self.securityCodeField.hidden = ![self.requiredFields containsObject:self.securityCodeField] || collapsed;
            self.postalCodeField.hidden = ![self.requiredFields containsObject:self.postalCodeField] || collapsed;
            self.mobileCountryCodeField.hidden = ![self.requiredFields containsObject:self.mobileCountryCodeField] || collapsed;
            self.mobilePhoneField.hidden = ![self.requiredFields containsObject:self.mobilePhoneField] || collapsed;
            
            [self updateFormBorders];
        } completion:^(__unused BOOL finished) {
            self.cardNumberFooter.hidden = !collapsed;
            self.cardNumberHeader.hidden = !collapsed;
            self.expirationDateField.hidden = collapsed;
            self.securityCodeField.hidden = ![self.requiredFields containsObject:self.securityCodeField] || collapsed;
            self.postalCodeField.hidden = ![self.requiredFields containsObject:self.postalCodeField] || collapsed;
            self.mobileCountryCodeField.hidden = ![self.requiredFields containsObject:self.mobileCountryCodeField] || collapsed;
            self.mobilePhoneField.hidden = ![self.requiredFields containsObject:self.mobilePhoneField] || collapsed;
            
            [self updateFormBorders];
            [self updateSubmitButton];
        }];
    });
}

#pragma mark - Public methods

- (void)resetForm {
    self.navigationItem.leftBarButtonItem = [[BTUIKBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[BTUIKBarButtonItem alloc] initWithTitle:@"Add Card" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.navigationItem.rightBarButtonItem.tag = ADD_CARD_BAR_BUTTON_ITEM_TAG;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    self.title = @"Card Details";
    for (BTUIKFormField *formField in self.formFields) {
        formField.text = @"";
        formField.hidden = YES;
    }
    // Using ivar so that setter is not called
    _collapsed = YES;
    self.unionPayEnabledMerchant = NO;
    self.cardNumberField.hidden = NO;
    [self.cardNumberField resetFormField];
    self.cardNumberFooter.hidden = NO;
    self.cardNumberHeader.hidden = NO;
    [self.cardList emphasizePaymentOption:BTUIKPaymentOptionTypeUnknown];
    [self updateFormBorders];
}

#pragma mark - Keyboard management

-(void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRectInWindow = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize keyboardSize = [self.view convertRect:keyboardRectInWindow fromView:nil].size;
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.bottom = keyboardSize.height;
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

- (void)keyboardWillHide:(__unused NSNotification *)notification
{
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.bottom = 0.0;
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

#pragma mark - Helper methods

- (void)updateFormBorders {
    self.cardNumberField.bottomBorder = YES;
    self.cardNumberField.topBorder = YES;
    
    self.mobileCountryCodeField.topBorder = YES;
    self.mobileCountryCodeField.interFieldBorder = YES;
    self.mobilePhoneField.bottomBorder = YES;
    
    NSArray *groupedFormFields = @[self.expirationDateField, self.securityCodeField, self.postalCodeField];
    BOOL topBorderAdded = NO;
    BTUIKFormField* lastVisibleFormField;
    for (NSUInteger i = 0; i < groupedFormFields.count; i++) {
        BTUIKFormField *formField = groupedFormFields[i];
        if (!formField.hidden) {
            if (!topBorderAdded) {
                formField.topBorder = YES;
                topBorderAdded = YES;
            } else {
                formField.topBorder = NO;
            }
            formField.bottomBorder = NO;
            formField.interFieldBorder = YES;
            lastVisibleFormField = formField;
        }
    }
    if (lastVisibleFormField) {
        lastVisibleFormField.bottomBorder = YES;
    }
}

- (UIView *)addSpacerToStackView:(UIStackView*)stackView beforeView:(UIView*)view {
    NSInteger indexOfView = [stackView.arrangedSubviews indexOfObject:view];
    if (indexOfView != NSNotFound) {
        UIView *spacer = [[UIView alloc] init];
        spacer.translatesAutoresizingMaskIntoConstraints = NO;
        [stackView insertArrangedSubview:spacer atIndex:indexOfView];
        NSLayoutConstraint *heightConstraint = [spacer.heightAnchor constraintEqualToConstant:36];
        heightConstraint.priority = UILayoutPriorityDefaultHigh;
        heightConstraint.active = true;
        return spacer;
    }
    return nil;
}

- (UIStackView *)newStackView {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis  = UILayoutConstraintAxisVertical;
    stackView.distribution  = UIStackViewDistributionFill;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 0;
    return stackView;
}

- (UIStackView *)newStackViewForError:(NSString*)errorText {
    UIStackView *newStackView = [self newStackView];
    UILabel *errorLabel = [UILabel new];
    errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [BTUIKAppearance styleSmallLabelPrimary:errorLabel];
    errorLabel.textColor = [BTUIKAppearance sharedInstance].errorForegroundColor;
    errorLabel.text = errorText;
    newStackView.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
    newStackView.layoutMarginsRelativeArrangement = true;
    [newStackView addArrangedSubview:errorLabel];
    return newStackView;
}

- (BOOL)isFormValid {
    __block BOOL isFormValid = YES;
    [self.requiredFields enumerateObjectsUsingBlock:^(BTUIKFormField * _Nonnull formField, __unused NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self.optionalFields containsObject:formField] && !formField.valid) {
            *stop = YES;
            isFormValid = NO;
        }
    }];
    return isFormValid;
}

- (void)updateSubmitButton {
    if (!self.collapsed && [self isFormValid] && self.navigationItem.rightBarButtonItem.tag == ADD_CARD_BAR_BUTTON_ITEM_TAG) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - Protocol conformance
#pragma mark FormField Delegate Methods

- (void)validateButtonPressed:(__unused BTUIKFormField *)formField {
    BTCardClient *unionPayClient = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    self.cardNumberField.state = BTUIKCardNumberFormFieldStateLoading;
    self.cardNumberErrorView.hidden = YES;
    [unionPayClient fetchCapabilities:self.cardNumberField.number completion:^(BTCardCapabilities * _Nullable cardCapabilities, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Sorry, there was an error. Please review your information and try again." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction: alertAction];
                [self presentViewController:alertController animated:YES completion:nil];
            });
            self.cardNumberErrorView.hidden = NO;
            self.cardNumberField.state = BTUIKCardNumberFormFieldStateValidate;
            return;
        }else if (cardCapabilities.isUnionPay && !cardCapabilities.isSupported) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"That card is not supported. Please try another card." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction: alertAction];
                [self presentViewController:alertController animated:YES completion:nil];
            });
            self.cardNumberErrorView.hidden = NO;
            self.cardNumberField.state = BTUIKCardNumberFormFieldStateValidate;
            return;
        }
        if (cardCapabilities.isUnionPay) {
            self.requiredFields = [NSMutableArray arrayWithArray:@[self.cardNumberField, self.expirationDateField]];
        } else {
            [self updateRequiredFields];
        }
        self.optionalFields = [NSMutableArray new];
        self.cardCapabilities = cardCapabilities;
        if (cardCapabilities.isUnionPay){
            [self.requiredFields addObject:self.mobileCountryCodeField];
            [self.requiredFields addObject:self.mobilePhoneField];
            if (cardCapabilities.isDebit) {
                [self.requiredFields addObject:self.securityCodeField];
                [self.optionalFields addObject:self.securityCodeField];
                [self.optionalFields addObject:self.expirationDateField];
            } else {
                [self.requiredFields addObject:self.securityCodeField];
            }
        }
        
        self.cardNumberField.state = BTUIKCardNumberFormFieldStateDefault;
        self.collapsed = NO;
        [self.expirationDateField becomeFirstResponder];
        [self formFieldDidChange:nil];
    }];
}

- (void)formFieldDidBeginEditing:(__unused BTUIKFormField *)formField {
    if (!self.cardEntryDidFocus) {
        [self.apiClient sendAnalyticsEvent:@"ios.dropin2.card.focus"];
        self.cardEntryDidFocus = YES;
    }
}

- (void)formFieldDidChange:(BTUIKFormField *)formField {
    [self updateSubmitButton];
    [self cardNumberErrorHidden:self.cardNumberField.displayAsValid];
    if (!self.cardEntryDidBegin && formField.text.length > 0) {
        [self.apiClient sendAnalyticsEvent:@"ios.dropin2.add-card.start"];
        self.cardEntryDidBegin = YES;
    }
    if (self.collapsed && formField == self.cardNumberField && !self.unionPayEnabledMerchant) {
        BTUIKPaymentOptionType paymentMethodType = [BTUIKViewUtil paymentMethodTypeForCardType:self.cardNumberField.cardType];
        [self.cardList emphasizePaymentOption:paymentMethodType];
        if (formField.valid) {
            self.collapsed = NO;
            [self.expirationDateField becomeFirstResponder];
        }
    } else if (!self.collapsed && formField == self.cardNumberField && !self.unionPayEnabledMerchant) {
        self.collapsed = YES;
    }
    
    if (!self.collapsed && formField == self.cardNumberField && self.unionPayEnabledMerchant) {
        if (self.unionPayEnabledMerchant) {
            self.cardCapabilities = nil;
            self.cardNumberField.state = BTUIKCardNumberFormFieldStateValidate;
        }
        self.collapsed = YES;
    }
}

- (void)cardNumberErrorHidden:(BOOL)hidden {
    NSInteger indexOfCardNumberFormField = [self.stackView.arrangedSubviews indexOfObject:self.cardNumberField];
    if (indexOfCardNumberFormField != NSNotFound && !hidden) {
        [self.stackView insertArrangedSubview:self.cardNumberErrorView atIndex:indexOfCardNumberFormField + 1];
    } else if (self.cardNumberErrorView.superview != nil && hidden) {
        [self.cardNumberErrorView removeFromSuperview];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(__unused UITextField *)textField {
    return YES;
}

@end
