#import "BraintreeDemoCustomPayPalButtonViewController.h"

#import <BraintreeUI/Braintree-Payments.h>
#import <BraintreeUI/UIColor+BTUI.h>

@interface BraintreeDemoCustomPayPalButtonViewController ()
@property(nonatomic, strong) BTPaymentProvider *paymentProvider;
@end

@implementation BraintreeDemoCustomPayPalButtonViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
    }
    return self;
}

- (UIView *)paymentButton {
    if ([self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypePayPal]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"PayPal (custom button)" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor blueColor] bt_adjustedBrightness:0.5] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(tappedCustomPayPal) forControlEvents:UIControlEventTouchUpInside];
        return button;
    } else {
        return nil;
    }
}

- (void)tappedCustomPayPal {
    self.progressBlock(@"Tapped PayPal - initiating PayPal auth using BTPaymentProvider");
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypePayPal];
}

@end
