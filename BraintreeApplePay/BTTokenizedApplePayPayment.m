#import "BTTokenizedApplePayPayment.h"

@implementation BTTokenizedApplePayPayment

@synthesize paymentMethodNonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;
@synthesize type = _type;

- (instancetype)initWithPaymentMethodNonce:(NSString *)paymentMethodNonce
                               description:(NSString *)localizedDescription {
    if (self = [super init]) {
        _paymentMethodNonce = paymentMethodNonce;
        _localizedDescription = localizedDescription;
    }
    return self;
}

@end
