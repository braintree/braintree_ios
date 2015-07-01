#import "BTTokenizedPayPalAccount_Internal.h"

@implementation BTTokenizedPayPalAccount

@synthesize paymentMethodNonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce description:(NSString *)description email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName billingAddress:(BTPostalAddress *)billingAddress shippingAddress:(BTPostalAddress *)shippingAddress {
    self = [super init];
    if (self) {
        _paymentMethodNonce = nonce;
        _localizedDescription = description;
        _email = email;
        _firstName = firstName;
        _lastName = lastName;
        _billingAddress = billingAddress;
        _shippingAddress = shippingAddress;
    }
    return self;
}

@end
