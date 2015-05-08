#import "BraintreeDemoThreeDSecureViewController.h"
#import "ALView+PureLayout.h"

#import <Braintree/Braintree-3D-Secure.h>
#import <Braintree/BTThreeDSecure.h>


@interface BraintreeDemoThreeDSecureViewController ()
@property(nonatomic, strong) BTThreeDSecure *threeDSecure;
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

- (void)tappedToVerifyNewCard {
    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
    request.number = @"4000000000000002";
    request.expirationDate = @"12/2020";

    self.progressBlock(@"Verifying Card ending in 0002");

    [self.threeDSecure verifyCardWithDetails:request
                                      amount:[NSDecimalNumber decimalNumberWithString:@"10"]];
}

- (void)tappedToVerifyTokenizedCard {
    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
    request.number = @"4000000000000002";
    request.expirationDate = @"12/2020";

    self.progressBlock(@"Tokenizing card ending in 0002");

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

@end
