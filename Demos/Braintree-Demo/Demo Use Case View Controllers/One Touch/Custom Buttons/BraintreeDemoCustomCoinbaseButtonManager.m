#import "BraintreeDemoCustomCoinbaseButtonManager.h"

#import <Braintree/Braintree.h>

#import <Braintree/UIColor+BTUI.h>

@interface BraintreeDemoCustomCoinbaseButtonManager ()
@property (nonatomic, strong) BTClient *client;
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;
@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;
@end


@implementation BraintreeDemoCustomCoinbaseButtonManager
@synthesize button = _button;

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate {
    self = [self init];
    if (self) {
        self.client = client;
        self.delegate = delegate;

        self.paymentProvider = [[BTPaymentProvider alloc] initWithClient:self.client];
        self.paymentProvider.delegate = self.delegate;

        if ([self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase]) {
            _button = [UIButton buttonWithType:UIButtonTypeSystem];
            [_button setTitle:@"Coinbase" forState:UIControlStateNormal];
            [_button setBackgroundColor:[UIColor colorWithRed:0.227 green:0.294 blue:1.000 alpha:1.000]];
            [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_button setContentEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
            _button.layer.borderColor = [UIColor blackColor].CGColor;
            _button.layer.borderWidth = 1;
            _button.layer.cornerRadius = 5;
            [_button addTarget:self
                        action:@selector(tappedCustomCoinbase:)
              forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (UIButton *)button {
    return [self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase] ? _button : nil;
}

- (void)tappedCustomCoinbase:(__unused BraintreeDemoCustomCoinbaseButtonManager *)sender {
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeCoinbase];
}

@end


