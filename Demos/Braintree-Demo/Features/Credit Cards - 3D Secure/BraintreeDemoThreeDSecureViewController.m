#import "BraintreeDemoThreeDSecureViewController.h"
#import "ALView+PureLayout.h"

#import <Braintree3DSecure/Braintree3DSecure.h>
#import <BraintreeUI/BraintreeUI.h>

@interface BraintreeDemoThreeDSecureViewController () <BTViewControllerPresentingDelegate>
@property (nonatomic, strong) BTThreeDSecureDriver *threeDSecure;
@property (nonatomic, strong) BTUICardFormView *cardFormView;
@end

@implementation BraintreeDemoThreeDSecureViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        _threeDSecure = [[BTThreeDSecureDriver alloc] initWithAPIClient:self.apiClient delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"3D Secure";

    self.cardFormView = [[BTUICardFormView alloc] initForAutoLayout];
    self.cardFormView.optionalFields = BTUICardFormOptionalFieldsNone;
    [self.view addSubview:self.cardFormView];
    [self.cardFormView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.cardFormView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.cardFormView autoPinEdgeToSuperviewEdge:ALEdgeRight];
}

- (UIView *)paymentButton {
    UIButton *verifyNewCardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [verifyNewCardButton setTitle:@"Tokenize and Verify New Card" forState:UIControlStateNormal];
    [verifyNewCardButton addTarget:self action:@selector(tappedToVerifyNewCard) forControlEvents:UIControlEventTouchUpInside];

    UIView *threeDSecureButtonsContainer = [[UIView alloc] initForAutoLayout];
    [threeDSecureButtonsContainer addSubview:verifyNewCardButton];

    [verifyNewCardButton autoPinEdgeToSuperviewEdge:ALEdgeTop];

    [verifyNewCardButton autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];

    return threeDSecureButtonsContainer;
}

- (BTCardTokenizationRequest *)cardRequest {
    BTCardTokenizationRequest *request = [[BTCardTokenizationRequest alloc] init];
    if (self.cardFormView.valid &&
        self.cardFormView.number &&
        self.cardFormView.expirationMonth &&
        self.cardFormView.expirationYear) {
        request.number = self.cardFormView.number;
        request.expirationMonth = self.cardFormView.expirationMonth;
        request.expirationYear = self.cardFormView.expirationYear;
    } else {
        [self.cardFormView showTopLevelError:@"Not valid. Using default 3DS test card..."];
        request.number = @"4000000000000002";
        request.expirationMonth = @"12";
        request.expirationYear = @"2020";
    }
    return request;
}

/// "Tokenize and Verify New Card"
- (void)tappedToVerifyNewCard {
    BTCardTokenizationRequest *request = [self cardRequest];

    self.progressBlock([NSString stringWithFormat:@"Tokenizing card ending in %@", [request.number substringFromIndex:(request.number.length - 4)]]);

    BTCardTokenizationClient *client = [[BTCardTokenizationClient alloc] initWithAPIClient:self.apiClient];
    [client tokenizeCard:request completion:^(BTTokenizedCard * _Nullable tokenizedCard, NSError * _Nullable error) {

        if (error) {
            self.progressBlock(error.localizedDescription);
            return;
        }

        self.progressBlock(@"Tokenized card, now verifying with 3DS");

        [self.threeDSecure verifyCardWithNonce:tokenizedCard.paymentMethodNonce
                                        amount:[NSDecimalNumber decimalNumberWithString:@"10"]
                                    completion:^(BTThreeDSecureTokenizedCard * _Nullable threeDSecureCard, NSError * _Nullable error)
         {
             if (error) {
                 self.progressBlock(error.localizedDescription);
                 return;
             }

             if (threeDSecureCard.liabilityShiftPossible && threeDSecureCard.liabilityShifted) {
                 self.progressBlock(@"Liability shift possible and liability shifted");
             } else {
                 self.progressBlock(@"3D Secure authentication was attempted but liability shift is not possible");
             }
             self.completionBlock(threeDSecureCard);
         }];
    }];
}

- (void)paymentDriver:(__unused id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(__unused id)driver requestsDismissalOfViewController:(__unused UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
