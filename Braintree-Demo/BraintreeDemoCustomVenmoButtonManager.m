#import "BraintreeDemoCustomVenmoButtonManager.h"

#import <Braintree/UIColor+BTUI.h>
#import <Braintree/BTClient.h>

@implementation BraintreeDemoCustomVenmoButtonManager

- (instancetype)initWithClient:(__unused BTClient *)client {
    self = [self init];
    if (self) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"Venmo (custom button)" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] forState:UIControlStateNormal];
        [_button setTitleColor:[[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] bt_adjustedBrightness:0.7] forState:UIControlStateHighlighted];
        [_button addTarget:self action:@selector(tappedCustomVenmo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)tappedCustomVenmo:(BraintreeDemoCustomVenmoButtonManager *)sender {
    NSLog(@"You tapped the Venmo button: %@", sender);
    [[[UIAlertView alloc] initWithTitle:@"Not Yet Implemented"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
