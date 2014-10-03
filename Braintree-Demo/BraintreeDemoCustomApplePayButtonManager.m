#import "BraintreeDemoCustomApplePayButtonManager.h"

#import <Braintree/Braintree.h>

#import <Braintree/UIColor+BTUI.h>

@interface BraintreeDemoCustomApplePayButtonManager ()
@property (nonatomic, strong) BTClient *client;
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;
@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;
@end


@implementation BraintreeDemoCustomApplePayButtonManager
@synthesize button = _button;

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate {
    self = [self init];
    if (self) {
        self.client = client;
        self.delegate = delegate;

        self.paymentProvider = [[BTPaymentProvider alloc] initWithClient:self.client];
        self.paymentProvider.delegate = self.delegate;

        self.paymentProvider.paymentSummaryItems = @[
                                                     [PKPaymentSummaryItem summaryItemWithLabel:@"An amazing product"
                                                                                         amount:[NSDecimalNumber decimalNumberWithString:@"1"]],
                                                     [PKPaymentSummaryItem summaryItemWithLabel:@"An unbelievable price"
                                                                                         amount:[NSDecimalNumber decimalNumberWithString:@"1"]],
                                                     [PKPaymentSummaryItem summaryItemWithLabel:@"Grand Total"
                                                                                         amount:[NSDecimalNumber decimalNumberWithString:@"2"]]
                                                     ];

        self.paymentProvider.requiredBillingAddressFields = PKAddressFieldPostalAddress;

        if ([self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeApplePay]) {
            _button = [UIButton buttonWithType:UIButtonTypeCustom];
            [_button setImage:[UIImage imageNamed:@"ApplePayBTN_42pt__black_textLogo_"]
                     forState:UIControlStateNormal];
            [_button setTitleColor:[UIColor bt_colorFromHex:@"111111" alpha:1.0f]
                          forState:UIControlStateNormal];
            [_button setTitleColor:[[UIColor bt_colorFromHex:@"111111" alpha:1.0f]
                                    bt_adjustedBrightness:0.7] forState:UIControlStateHighlighted];
            _button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20];
            [_button addTarget:self
                        action:@selector(tappedCustomApplePay:)
              forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (UIButton *)button {
    return [self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeApplePay] ? _button : nil;
}

- (void)tappedCustomApplePay:(__unused BraintreeDemoCustomApplePayButtonManager *)sender {
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeApplePay];
}

@end

