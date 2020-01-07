#import "BraintreeDemoThreeDSecurePaymentFlowViewController.h"
#import "ALView+PureLayout.h"

#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeUI/BraintreeUI.h>
#import <BraintreePaymentFlow/BraintreePaymentFlow.h>
#import <CardinalMobile/CardinalMobile.h>

@interface BraintreeDemoThreeDSecurePaymentFlowViewController () <BTViewControllerPresentingDelegate, BTThreeDSecureRequestDelegate>
@property (nonatomic, strong) BTPaymentFlowDriver *paymentFlowDriver;
@property (nonatomic, strong) BTUICardFormView *cardFormView;
@property (nonatomic, strong) UILabel *callbackCountLabel;
@property (nonatomic) int callbackCount;
@end

@implementation BraintreeDemoThreeDSecurePaymentFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"3D Secure - Payment Flow", nil);

    self.cardFormView = [[BTUICardFormView alloc] initForAutoLayout];
    self.cardFormView.optionalFields = BTUICardFormOptionalFieldsNone;
    [self.view addSubview:self.cardFormView];
    [self.cardFormView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.cardFormView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.cardFormView autoPinEdgeToSuperviewEdge:ALEdgeRight];
}

- (UIView *)createPaymentButton {
    UIButton *verifyNewCardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [verifyNewCardButton setTitle:NSLocalizedString(@"Tokenize and Verify New Card", nil) forState:UIControlStateNormal];
    [verifyNewCardButton addTarget:self action:@selector(tappedToVerifyNewCard) forControlEvents:UIControlEventTouchUpInside];

    UIView *threeDSecureButtonsContainer = [[UIView alloc] initForAutoLayout];
    [threeDSecureButtonsContainer addSubview:verifyNewCardButton];

    [verifyNewCardButton autoPinEdgeToSuperviewEdge:ALEdgeTop];

    [verifyNewCardButton autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];

    self.callbackCountLabel = [[UILabel alloc] initForAutoLayout];
    self.callbackCountLabel.textAlignment = NSTextAlignmentCenter;
    self.callbackCountLabel.font = [UIFont systemFontOfSize:UIFont.smallSystemFontSize];
    [threeDSecureButtonsContainer addSubview:self.callbackCountLabel];
    [self.callbackCountLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:verifyNewCardButton withOffset:20];
    [self.callbackCountLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.callbackCountLabel autoPinEdgeToSuperviewEdge:ALEdgeRight];
    self.callbackCount = 0;
    [self updateCallbackCount];

    return threeDSecureButtonsContainer;
}

- (BTCard *)newCard {
    BTCard *card = [[BTCard alloc] init];
    if (self.cardFormView.valid &&
        self.cardFormView.number &&
        self.cardFormView.expirationMonth &&
        self.cardFormView.expirationYear) {
        card.number = self.cardFormView.number;
        card.expirationMonth = self.cardFormView.expirationMonth;
        card.expirationYear = self.cardFormView.expirationYear;
    } else {
        [self.cardFormView showTopLevelError:@"Not valid. Using default 3DS test card..."];
        card.number = @"4000000000001091";
        card.expirationMonth = @"01";
        card.expirationYear = @"2022";
        card.cvv = @"123";
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
    
    self.progressBlock([NSString stringWithFormat:@"Tokenizing card ending in %@", [card.number substringFromIndex:(card.number.length - 4)]]);
    
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
        request.shippingMethod = @"01";

        UiCustomization *ui = [UiCustomization new];
        ToolbarCustomization *toolbarCustomization = [ToolbarCustomization new];
        [toolbarCustomization setHeaderText:@"Braintree 3DS Checkout"];
        [toolbarCustomization setBackgroundColor:@"#FF5A5F"];
        [toolbarCustomization setButtonText:@"Close"];
        [toolbarCustomization setTextColor:@"#222222"];
        [toolbarCustomization setTextFontSize:18];
        [toolbarCustomization setTextFontName:@"AmericanTypewriter"];
        [ui setToolbarCustomization:toolbarCustomization];
        request.uiCustomization = ui;
        
        BTThreeDSecureV1UICustomization *v1UICustomization = [BTThreeDSecureV1UICustomization new];
        v1UICustomization.redirectButtonText = @"Return to Demo App";
        v1UICustomization.redirectDescription = @"Please use the button above if you are not automatically redirected to the app.";
        request.v1UICustomization = v1UICustomization;
        
        [self.paymentFlowDriver startPaymentFlow:request completion:^(BTPaymentFlowResult * _Nonnull result, NSError * _Nonnull error) {
            self.callbackCount++;
            [self updateCallbackCount];
            if (error) {
                if (error.code == BTPaymentFlowDriverErrorTypeCanceled) {
                    self.progressBlock(@"Cancelled🎲");
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

- (void)onLookupComplete:(__unused BTThreeDSecureRequest *)request result:(__unused BTThreeDSecureLookup *)result next:(void (^)(void))next {
    // Optionally inspect the result and prepare UI if a challenge is required
    next();
}

@end
