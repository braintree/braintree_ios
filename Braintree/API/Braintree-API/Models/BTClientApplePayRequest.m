#import "BTClientApplePayRequest.h"

@implementation BTClientApplePayRequest

- (instancetype)initWithApplePayPayment:(PKPayment *)payment {
    self = [super init];
    if (self) {
        _payment = payment;
    }
    return self;
}

@end
