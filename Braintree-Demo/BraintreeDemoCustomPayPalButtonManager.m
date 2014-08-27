#import "BraintreeDemoCustomPayPalButtonManager.h"

#import <Braintree/BTPayPalAdapter.h>
#import <Braintree/BTClient+BTPayPal.h>
#import <Braintree/UIColor+BTUI.h>

@interface BraintreeDemoCustomPayPalButtonManager ()
@property (nonatomic, strong) BTPayPalAdapter *payPalAdapter;
@end

@implementation BraintreeDemoCustomPayPalButtonManager

- (id)initWithClient:(BTClient *)client {
    self = [self init];
    if (self) {
        self.payPalAdapter = [[BTPayPalAdapter alloc] initWithClient:client];

        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"PayPal (custom button)" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_button setTitleColor:[[UIColor blueColor] bt_adjustedBrightness:0.5] forState:UIControlStateHighlighted];
        [_button addTarget:self action:@selector(tappedCustomPayPal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setDelegate:(id<BTPayPalAdapterDelegate>)delegate {
    _delegate = delegate;
    self.payPalAdapter.delegate = delegate;
}

- (void)tappedCustomPayPal:(BraintreeDemoCustomPayPalButtonManager *)sender {
    NSLog(@"You tapped the PayPal button: %@", sender);

    NSLog(@"Tapped PayPal - initiating PayPal auth using BTPayPalAdapter");
    [self.payPalAdapter initiatePayPalAuth];
}

@end
