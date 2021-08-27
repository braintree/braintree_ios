#import "BraintreeDemoThreeDSecurePaymentFlowViewController.h"
#import "Demo-Swift.h"
@import BraintreeThreeDSecure;

@interface BraintreeDemoThreeDSecurePaymentFlowViewController () <BTViewControllerPresentingDelegate, BTThreeDSecureRequestDelegate>

@property (nonatomic, strong) BTPaymentFlowDriver *paymentFlowDriver;
@property (nonatomic, strong) UILabel *callbackCountLabel;
@property (nonatomic, strong) CardFormView *cardFormView;
@property (nonatomic) int callbackCount;

@end

@implementation BraintreeDemoThreeDSecurePaymentFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"3D Secure - Payment Flow", nil);

    self.cardFormView = [[CardFormView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.cardFormView];
    self.cardFormView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cardFormView.hidePhoneNumberField = YES;

    [NSLayoutConstraint activateConstraints:@[
        [self.cardFormView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.cardFormView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.cardFormView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.cardFormView.heightAnchor constraintEqualToConstant:200]
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

        self.paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:self.apiClient];
        self.paymentFlowDriver.viewControllerPresentingDelegate = self;

        BTThreeDSecureRequest *request = [[BTThreeDSecureRequest alloc] init];
        request.threeDSecureRequestDelegate = self;
        request.amount = [NSDecimalNumber decimalNumberWithString:@"10.32"];
        request.nonce = tokenizedCard.nonce;
        request.versionRequested = BTThreeDSecureVersion2;
        request.accountType = BTThreeDSecureAccountTypeCredit;

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

        BTThreeDSecureV2UICustomization *ui = [BTThreeDSecureV2UICustomization new];
        BTThreeDSecureV2ToolbarCustomization *toolbarCustomization = [BTThreeDSecureV2ToolbarCustomization new];
        [toolbarCustomization setHeaderText:@"Braintree 3DS Checkout"];
        [toolbarCustomization setBackgroundColor:@"#FF5A5F"];
        [toolbarCustomization setButtonText:@"Close"];
        [toolbarCustomization setTextColor:@"#222222"];
        [toolbarCustomization setTextFontSize:18];
        [toolbarCustomization setTextFontName:@"AmericanTypewriter"];
        [ui setToolbarCustomization:toolbarCustomization];
        request.v2UICustomization = ui;

        BTThreeDSecureV1UICustomization *v1UICustomization = [BTThreeDSecureV1UICustomization new];
        v1UICustomization.redirectButtonText = @"Return to Demo App";
        v1UICustomization.redirectDescription = @"Please use the button above if you are not automatically redirected to the app.";
        request.v1UICustomization = v1UICustomization;

        [self.paymentFlowDriver startPaymentFlow:request completion:^(BTPaymentFlowResult * _Nonnull result, NSError * _Nonnull error) {
            self.callbackCount++;
            [self updateCallbackCount];
            if (error) {
                if (error.code == BTPaymentFlowDriverErrorTypeCanceled) {
                    self.progressBlock(@"Canceled 🎲");
                } else {
                    self.progressBlock(error.localizedDescription);
                }
            } else if (result) {
                BTThreeDSecureResult *threeDSecureResult = (BTThreeDSecureResult *)result;
                self.completionBlock(threeDSecureResult.tokenizedCard);

                if (threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShiftPossible && threeDSecureResult.tokenizedCard.threeDSecureInfo.liabilityShifted) {
                    self.progressBlock(@"Liability shift possible and liability shifted");
                } else {
                    self.progressBlock(@"3D Secure authentication was attempted but liability shift is not possible");
                }
            }
        }];

    }];
}

- (void)paymentDriver:(__unused id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(__unused id)driver requestsDismissalOfViewController:(__unused UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark BTThreeDSecureRequestDelegate

- (void)onLookupComplete:(__unused BTThreeDSecureRequest *)request lookupResult:(__unused BTThreeDSecureResult *)result next:(void (^)(void))next {
    // Optionally inspect the result and prepare UI if a challenge is required
    next();
}

@end
