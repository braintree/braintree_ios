#import "BraintreeDemoThreeDSecurePaymentFlowViewController.h"
#import "Demo-Swift.h"
@import BraintreeThreeDSecure;
@import BraintreeCore;
@import BraintreeCard;
@import BraintreePaymentFlow;

#import <BraintreeThreeDSecure/BraintreeThreeDSecure-Swift.h>

@interface BraintreeDemoThreeDSecurePaymentFlowViewController () <BTThreeDSecureRequestDelegate>

@property (nonatomic, strong) BTThreeDSecureClient *threeDSecureClient;
@property (nonatomic, strong) UILabel *callbackCountLabel;
@property (nonatomic, strong) BTCardFormView *cardFormView;
@property (nonatomic, strong) UIButton *autofillButton3DS;
@property (nonatomic) int callbackCount;

@end

NSInteger const BTThreeDSecureCancelCode = 5;

@implementation BraintreeDemoThreeDSecurePaymentFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"3D Secure - Payment Flow", nil);

    self.cardFormView = [[BTCardFormView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.cardFormView];
    self.cardFormView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cardFormView.hidePhoneNumberField = YES;

    self.autofillButton3DS = [UIButton buttonWithType:UIButtonTypeSystem];
    self.autofillButton3DS.translatesAutoresizingMaskIntoConstraints = NO;
    [self.autofillButton3DS setTitle:NSLocalizedString(@"Autofill 3DS Card", nil) forState:UIControlStateNormal];
    [self.autofillButton3DS addTarget:self action:@selector(tappedToAutofill3DSCard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.autofillButton3DS];

    [NSLayoutConstraint activateConstraints:@[
        [self.cardFormView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.cardFormView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.cardFormView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.cardFormView.heightAnchor constraintEqualToConstant:200],
        
        [self.autofillButton3DS.topAnchor constraintEqualToAnchor:self.cardFormView.bottomAnchor constant:10],
        [self.autofillButton3DS.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:10],
        [self.autofillButton3DS.heightAnchor constraintEqualToConstant:30],
    ]];
}

- (UIView *)createPaymentButton {
    UIButton *verifyNewCardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    verifyNewCardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [verifyNewCardButton setTitle:NSLocalizedString(@"Tokenize and Verify New Card", nil) forState:UIControlStateNormal];
    [verifyNewCardButton addTarget:self action:@selector(tappedToVerifyNewCard) forControlEvents:UIControlEventTouchUpInside];

    UIView *threeDSecureButtonsContainer = [[UIView alloc] init];
    threeDSecureButtonsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [threeDSecureButtonsContainer addSubview:verifyNewCardButton];

    self.callbackCountLabel = [[UILabel alloc] init];
    self.callbackCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.callbackCountLabel.textAlignment = NSTextAlignmentCenter;
    self.callbackCountLabel.font = [UIFont systemFontOfSize:UIFont.smallSystemFontSize];
    [threeDSecureButtonsContainer addSubview:self.callbackCountLabel];
    self.callbackCount = 0;
    [self updateCallbackCount];
    
    self.centerYConstant = 100;

    [NSLayoutConstraint activateConstraints:@[
        [verifyNewCardButton.topAnchor constraintEqualToAnchor:threeDSecureButtonsContainer.topAnchor],
        [verifyNewCardButton.centerXAnchor constraintEqualToAnchor:threeDSecureButtonsContainer.centerXAnchor],
        [verifyNewCardButton.leadingAnchor constraintEqualToAnchor:threeDSecureButtonsContainer.leadingAnchor],
        [verifyNewCardButton.trailingAnchor constraintEqualToAnchor:threeDSecureButtonsContainer.trailingAnchor],
        [self.callbackCountLabel.topAnchor constraintEqualToAnchor:verifyNewCardButton.bottomAnchor constant:20.0],
        [self.callbackCountLabel.centerXAnchor constraintEqualToAnchor:threeDSecureButtonsContainer.centerXAnchor]
    ]];

    return threeDSecureButtonsContainer;
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
    if (self.cardFormView.postalCode != nil) {
        card.postalCode = self.cardFormView.postalCode;
    }

    return card;
}

- (void)updateCallbackCount {
    self.callbackCountLabel.text = [NSString stringWithFormat:@"Callback Count: %i", self.callbackCount];
}

-(void)tappedToAutofill3DSCard {
    self.cardFormView.cardNumberTextField.text = @"4000000000001091";
    self.cardFormView.expirationTextField.text = self.generateFutureDate;
    self.cardFormView.cvvTextField.text = @"123";
    self.cardFormView.postalCodeTextField.text = @"12345";
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

/// "Tokenize and Verify New Card"
- (void)tappedToVerifyNewCard {
    self.callbackCount = 0;
    [self updateCallbackCount];

    BTCard *card = [self newCard];

    BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    [client tokenizeCard:card completion:^(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error) {

        if (error) {
            self.progressBlock(error.localizedDescription);
            return;
        }

        self.progressBlock(@"Tokenized card, now verifying with 3DS");

        self.threeDSecureClient = [[BTThreeDSecureClient alloc] initWithAPIClient:self.apiClient];

        BTThreeDSecureRequest *request = [[BTThreeDSecureRequest alloc] init];
        request.threeDSecureRequestDelegate = self;
        request.amount = [NSDecimalNumber decimalNumberWithString:@"10.32"];
        request.nonce = tokenizedCard.nonce;
        request.accountType = BTThreeDSecureAccountTypeCredit;
        request.requestedExemptionType = BTThreeDSecureRequestedExemptionTypeLowValue;

        BTThreeDSecurePostalAddress *billingAddress = [BTThreeDSecurePostalAddress new];
        billingAddress.givenName = @"Jill";
        billingAddress.surname = @"Doe";
        billingAddress.streetAddress = @"555 Smith St.";
        billingAddress.extendedAddress = @"#5";
        billingAddress.locality = @"Oakland";
        billingAddress.region = @"CA";
        billingAddress.countryCodeAlpha2 = @"US";
        billingAddress.postalCode = @"12345";
        billingAddress.phoneNumber = @"8101234567";
        request.billingAddress = billingAddress;
        request.email = @"test@example.com";
        request.shippingMethod = BTThreeDSecureShippingMethodSameDay;
        
        // MARK: v2 Customization

        BTThreeDSecureV2UICustomization *ui = [BTThreeDSecureV2UICustomization new];
        BTThreeDSecureV2ToolbarCustomization *toolbarCustomization = [BTThreeDSecureV2ToolbarCustomization new];
        [toolbarCustomization setHeaderText:@"Braintree 3DS Checkout"];
        [toolbarCustomization setBackgroundColor:@"#FF5A5F"];
        [toolbarCustomization setButtonText:@"Close"];
        [toolbarCustomization setTextColor:@"#222222"];
        [toolbarCustomization setTextFontSize:18];
        [toolbarCustomization setTextFontName:@"AmericanTypewriter"];
        
        BTThreeDSecureV2ButtonCustomization *buttonCustomization = [BTThreeDSecureV2ButtonCustomization new];
        [buttonCustomization setBackgroundColor:@"#FFC0CB"];
        [buttonCustomization setCornerRadius:20];
        
        BTThreeDSecureV2TextBoxCustomization *textBoxCustomization = [BTThreeDSecureV2TextBoxCustomization new];
        [textBoxCustomization setBorderColor:@"#ADD8E6"];
        [textBoxCustomization setCornerRadius:10];
        [textBoxCustomization setBorderWidth:5];
        
        BTThreeDSecureV2LabelCustomization *labelCustomization = [BTThreeDSecureV2LabelCustomization new];
        [labelCustomization setHeadingTextColor:@"#A020F0"];
        [labelCustomization setHeadingTextFontSize:24];
        [labelCustomization setHeadingTextFontName:@"AmericanTypewriter"];
        
        [ui setToolbarCustomization:toolbarCustomization];
        [ui setButtonCustomization:buttonCustomization buttonType:BTThreeDSecureV2ButtonTypeVerify];
        [ui setTextBoxCustomization:textBoxCustomization];
        [ui setLabelCustomization:labelCustomization];

        request.v2UICustomization = ui;
        
        [self.threeDSecureClient startPaymentFlow:request completion:^(BTPaymentFlowResult * _Nonnull result, NSError * _Nonnull error) {
            self.callbackCount++;
            [self updateCallbackCount];
            if (error) {
                if (error.code == BTThreeDSecureCancelCode) {
                    self.progressBlock(@"Canceled 🎲");
                } else {
                    self.progressBlock(error.localizedDescription);
                }
            } else if (result) {
                BTThreeDSecureResult *threeDSecureResult = (BTThreeDSecureResult *)result;
                self.nonceStringCompletionBlock(threeDSecureResult.tokenizedCard.nonce);

                if (threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShiftPossible && threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShifted) {
                    self.progressBlock(@"Liability shift possible and liability shifted");
                } else {
                    self.progressBlock(@"3D Secure authentication was attempted but liability shift is not possible");
                }
            }
        }];

    }];
}

#pragma mark BTThreeDSecureRequestDelegate

- (void)onLookupComplete:(__unused BTThreeDSecureRequest *)request lookupResult:(__unused BTThreeDSecureResult *)result next:(void (^)(void))next {
    // Optionally inspect the result and prepare UI if a challenge is required
    next();
}

@end
