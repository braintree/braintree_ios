#import "BTApplePayCardNonce.h"

@implementation BTApplePayCardNonce

@synthesize nonce = _paymentMethodNonce;
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
