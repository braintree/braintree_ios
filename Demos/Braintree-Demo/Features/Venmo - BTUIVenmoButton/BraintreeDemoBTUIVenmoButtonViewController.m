#import "BraintreeDemoBTUIVenmoButtonViewController.h"

@interface BraintreeDemoBTUIVenmoButtonViewController ()
@property(nonatomic, strong) BTPaymentProvider *paymentProvider;
@end

@implementation BraintreeDemoBTUIVenmoButtonViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.braintree = [Braintree braintreeWithClientToken:clientToken];
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BTUIVenmoButton+BTPaymentProvider";
}

- (UIControl *)paymentButton {
    if ([self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeVenmo]) {
        BTUIPayPalButton *payPalButton = [[BTUIPayPalButton alloc] init];
        [payPalButton addTarget:self action:@selector(tappedPayPalButton) forControlEvents:UIControlEventTouchUpInside];
        return payPalButton;
    } else {
        self.progressBlock(@"canCreatePaymentMethodWithProviderType returns NO, hiding Venmo button");
        return nil;
    }
}

- (void)tappedPayPalButton {
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeVenmo];
}

@end
