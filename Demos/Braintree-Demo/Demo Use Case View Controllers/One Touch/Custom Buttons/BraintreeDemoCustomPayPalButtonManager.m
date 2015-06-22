#import "BraintreeDemoCustomPayPalButtonManager.h"

#import <Braintree/Braintree-Payments.h>
#import <Braintree/UIColor+BTUI.h>

@interface BraintreeDemoCustomPayPalButtonManager ()
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;
@end

@implementation BraintreeDemoCustomPayPalButtonManager

@synthesize button = _button;

- (id)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate {
    self = [self init];
    if (self) {
        self.paymentProvider = [[BTPaymentProvider alloc] initWithClient:client];
        self.paymentProvider.delegate = delegate;

        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"PayPal (custom button)" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_button setTitleColor:[[UIColor blueColor] bt_adjustedBrightness:0.5] forState:UIControlStateHighlighted];
        [_button addTarget:self action:@selector(tappedCustomPayPal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (UIButton *)button {
    return [self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypePayPal] ? _button : nil;
}

- (void)tappedCustomPayPal:(BraintreeDemoCustomPayPalButtonManager *)sender {
    NSLog(@"You tapped the custom PayPal button: %@", sender);
    NSLog(@"Tapped PayPal - initiating PayPal auth using BTPaymentProvider");
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypePayPal];
}

@end
