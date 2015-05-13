#import "BraintreeDemoBTUIPayPalButtonViewController.h"
#import "BTUIPaymentButtonCollectionViewCell.h"

@interface BraintreeDemoBTUIPayPalButtonViewController ()
@property(nonatomic, strong) BTPaymentProvider *paymentProvider;
@end

@implementation BraintreeDemoBTUIPayPalButtonViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BTUIPayPalButton+BTPaymentProvider";
}

- (UIView *)paymentButton {
    if ([self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypePayPal]) {
        BTUIPayPalButton *payPalButton = [[BTUIPayPalButton alloc] init];
        [payPalButton addTarget:self action:@selector(tappedPayPalButton) forControlEvents:UIControlEventTouchUpInside];
        return payPalButton;
    } else {
        self.progressBlock(@"canCreatePaymentMethodWithProviderType: returns NO, hiding PayPal button");
        return nil;
    }
}

- (void)tappedPayPalButton {
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypePayPal];
}

@end
