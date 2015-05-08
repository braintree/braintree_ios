#import "BraintreeDemoCustomCoinbaseButtonViewController.h"

#import <Braintree/Braintree-Payments.h>
#import <Braintree/UIColor+BTUI.h>

@interface BraintreeDemoCustomCoinbaseButtonViewController ()
@property(nonatomic, strong) BTPaymentProvider *paymentProvider;
@end

@implementation BraintreeDemoCustomCoinbaseButtonViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
    }
    return self;
}

- (UIView *)paymentButton {
    if ([self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Coinbase (custom button)" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor blueColor] bt_adjustedBrightness:0.5] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(tappedCustomCoinbase) forControlEvents:UIControlEventTouchUpInside];
        return button;
    } else {
        return nil;
    }
}

- (void)tappedCustomCoinbase {
    self.progressBlock(@"Tapped Coinbase - initiating Coinbase auth using BTPaymentProvider");
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeCoinbase];
}

@end
