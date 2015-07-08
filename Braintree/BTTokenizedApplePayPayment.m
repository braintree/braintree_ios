#import "BTTokenizedApplePayPayment.h"

@implementation BTTokenizedApplePayPayment

@synthesize paymentMethodNonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;

- (instancetype)initWithPaymentMethodNonce:(NSString *)paymentMethodNonce
                               description:(NSString *)localizedDescription {
    if (self = [super init]) {
        _paymentMethodNonce = paymentMethodNonce;
        _localizedDescription = localizedDescription;
    }
    return self;
}

@end
