#import "BTClient_Internal.h"
#import "BTClientToken.h"
#import "BTClient+BTPaymentApplePay.h"
#import "BTPaymentApplePayConfiguration.h"


@implementation BTClient (BTPaymentApplePay)

- (BTPaymentApplePayConfiguration *)btPayment_applePayConfiguration {
    return [[BTPaymentApplePayConfiguration alloc] initWithDictionary:self.clientToken.claims[@"applePay"]];
}

@end
