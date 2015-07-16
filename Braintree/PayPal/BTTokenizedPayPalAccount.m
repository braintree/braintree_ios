#import "BTTokenizedPayPalAccount_Internal.h"

@implementation BTTokenizedPayPalAccount

@synthesize paymentMethodNonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                     email:(NSString *)email
                            accountAddress:(BTPostalAddress *)accountAddress
{
    if (self = [super init]) {
        _paymentMethodNonce = nonce;
        _localizedDescription = description;
        _email = email;
        _accountAddress = [accountAddress copy];
    }
    return self;
}

@end

