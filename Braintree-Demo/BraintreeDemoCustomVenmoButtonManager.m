#import "BraintreeDemoCustomVenmoButtonManager.h"

#import <Braintree/Braintree.h>

#import <Braintree/UIColor+BTUI.h>

@interface BraintreeDemoCustomVenmoButtonManager ()
@property (nonatomic, strong) BTClient *client;
@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;
@end

@implementation BraintreeDemoCustomVenmoButtonManager

@synthesize button = _button;

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate {
    self = [self init];
    if (self) {
        self.client = client;
        self.delegate = delegate;
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"Venmo (custom button)" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] forState:UIControlStateNormal];
        [_button setTitleColor:[[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] bt_adjustedBrightness:0.7] forState:UIControlStateHighlighted];
        [_button addTarget:self action:@selector(tappedCustomVenmo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (UIButton *)button {
    return [BTVenmoAppSwitchHandler isAvailableForClient:self.client] ? _button : nil;
}

- (void)tappedCustomVenmo:(BraintreeDemoCustomVenmoButtonManager *)sender {
    NSLog(@"You tapped the Venmo button: %@", sender);

    BTPaymentProvider *provider = [[BTPaymentProvider alloc] initWithClient:self.client];
    provider.delegate = self.delegate;
    [provider createPaymentMethod:BTPaymentProviderTypeVenmo];
}

@end
