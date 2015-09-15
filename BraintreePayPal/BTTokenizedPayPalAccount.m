#import "BTTokenizedPayPalAccount_Internal.h"

@implementation BTTokenizedPayPalAccount

@synthesize paymentMethodNonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;
@synthesize type = _type;

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                     email:(NSString *)email
                            accountAddress:(BTPostalAddress *)accountAddress
                          clientMetadataId:(NSString *)clientMetadataId
{
    if (self = [super init]) {
        _paymentMethodNonce = nonce;
        _localizedDescription = description;
        _email = email;
        _accountAddress = [accountAddress copy];
        _clientMetadataId = clientMetadataId;
        _type = @"PayPal";
    }
    return self;
}

@end

