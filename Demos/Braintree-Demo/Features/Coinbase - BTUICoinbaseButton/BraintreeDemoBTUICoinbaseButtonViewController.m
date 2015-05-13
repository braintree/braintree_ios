#import "BraintreeDemoBTUICoinbaseButtonViewController.h"
#import "BTUIPaymentButtonCollectionViewCell.h"

@interface BraintreeDemoBTUICoinbaseButtonViewController ()
@property(nonatomic, strong) BTPaymentProvider *paymentProvider;
@end

@implementation BraintreeDemoBTUICoinbaseButtonViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BTUICoinbaseButton+BTPaymentProvider";
}

- (UIView *)paymentButton {
    if ([self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase]) {
        BTUICoinbaseButton *payPalButton = [[BTUICoinbaseButton alloc] init];
        [payPalButton addTarget:self action:@selector(tappedCoinbaseButton) forControlEvents:UIControlEventTouchUpInside];
        return payPalButton;
    } else {
        self.progressBlock(@"canCreatePaymentMethodWithProviderType: returns NO, hiding Coinbase button");
        return nil;
    }
}

- (void)tappedCoinbaseButton {
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeCoinbase];
}

@end
