#import "BraintreeDemoThreeDSecureViewController.h"
#import "ALView+PureLayout.h"

#import <Braintree/Braintree-3D-Secure.h>
#import <Braintree/BTThreeDSecure.h>

#import <Braintree/BTCardPaymentMethod.h>

@interface BraintreeDemoThreeDSecureViewController ()
@property(nonatomic, strong) BTThreeDSecure *threeDSecure;
@property(nonatomic, strong) BTUICardFormView *cardFormView;
@end

@implementation BraintreeDemoThreeDSecureViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.threeDSecure = [[BTThreeDSecure alloc] initWithClient:self.braintree.client
                                                          delegate:self];
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

    UIButton *verifyFromNonceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [verifyFromNonceButton setTitle:@"Verify Nonce" forState:UIControlStateNormal];
    [verifyFromNonceButton addTarget:self action:@selector(tappedToVerifyTokenizedCard) forControlEvents:UIControlEventTouchUpInside];

    UIView *threeDSecureButtonsContainer = [[UIView alloc] initForAutoLayout];
    [threeDSecureButtonsContainer addSubview:verifyNewCardButton];
    [threeDSecureButtonsContainer addSubview:verifyFromNonceButton];

    [verifyNewCardButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [verifyNewCardButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:verifyFromNonceButton withOffset:-10];
    [verifyFromNonceButton autoPinEdgeToSuperviewEdge:ALEdgeBottom];

    [verifyNewCardButton autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
    [verifyFromNonceButton autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];

    return threeDSecureButtonsContainer;
}

- (BTClientCardRequest *)cardRequest {
    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
    if (self.cardFormView.valid &&
        self.cardFormView.number &&
        self.cardFormView.expirationMonth &&
        self.cardFormView.expirationYear) {
        request.number = self.cardFormView.number;
        request.expirationDate = [NSString stringWithFormat:@"%@/%@",
                                  self.cardFormView.expirationMonth,
                                  self.cardFormView.expirationYear];
    } else {
        [self.cardFormView showTopLevelError:@"Not valid. Using default 3DS test card..."];
        request.number = @"4000000000000002";
        request.expirationDate = @"12/2020";
    }
    return request;
}

/// "Tokenize and Verify New Card"
- (void)tappedToVerifyNewCard {
    BTClientCardRequest *request = [self cardRequest];

    self.progressBlock([NSString stringWithFormat:@"Verifying Card ending in %@", [request.number substringFromIndex:(request.number.length - 4)]]);

    [self.threeDSecure verifyCardWithDetails:request
                                      amount:[NSDecimalNumber decimalNumberWithString:@"10"]];
}

/// "Verify Nonce"
- (void)tappedToVerifyTokenizedCard {
    BTClientCardRequest *request = [self cardRequest];

    self.progressBlock([NSString stringWithFormat:@"Tokenizing Card ending in %@", [request.number substringFromIndex:(request.number.length - 4)]]);

    [self.braintree tokenizeCard:request
                     completion:^(NSString *nonce, NSError *error) {
                         if (error) {
                         self.progressBlock(error.localizedDescription);
                         } else {
                             self.progressBlock(@"Got a nonce. Verifying with 3DS.");

                             [self.threeDSecure verifyCardWithNonce:nonce

                                                             amount:[NSDecimalNumber decimalNumberWithString:@"10"]];
                         }
                     }];
}

- (void)paymentMethodCreator:(__unused id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    
    if ([paymentMethod isKindOfClass:[BTCardPaymentMethod class]]) {
        BTCardPaymentMethod *cardPaymentMethod = (BTCardPaymentMethod *)paymentMethod;
        
        // 3.8.1 changed:
        // [cardPaymentMethod.threeDSecureInfo[@"liabilityShiftPossible"] boolValue] -> cardPaymentMethod.threeDSecureInfo.liabilityShiftPossible
        // [cardPaymentMethod.threeDSecureInfo[@"liabilityShifted"] boolValue] -> cardPaymentMethod.threeDSecureInfo.liabilityShifted
        
        if (cardPaymentMethod.threeDSecureInfo.liabilityShiftPossible && cardPaymentMethod.threeDSecureInfo.liabilityShifted) {
            NSLog(@"liability shift possible and liability shifted");
            
        } else {
            NSLog(@"3D Secure authentication was attempted but liability shift is not possible");
            
        }
    }
    
    [super paymentMethodCreator:sender didCreatePaymentMethod:paymentMethod];
}

@end
