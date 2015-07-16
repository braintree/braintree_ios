#import "BTTokenizedPayPalCheckout_Internal.h"

@interface BTTokenizedPayPalCheckout ()
@property (nonatomic, readwrite, copy) NSString *email;
@property (nonatomic, readwrite, copy) NSString *firstName;
@property (nonatomic, readwrite, copy) NSString *lastName;
@property (nonatomic, readwrite, copy) NSString *phone;
@property (nonatomic, readwrite, strong) BTPostalAddress *billingAddress;
@property (nonatomic, readwrite, strong) BTPostalAddress *shippingAddress;
@end

@implementation BTTokenizedPayPalCheckout

@synthesize paymentMethodNonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                     email:(NSString *)email
                                 firstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                     phone:(NSString *)phone
                            billingAddress:(BTPostalAddress *)billingAddress
                           shippingAddress:(BTPostalAddress *)shippingAddress
{
    if (self = [super init]) {
        _paymentMethodNonce = nonce;
        _localizedDescription = description;
        _email = email;
        _firstName = firstName;
        _lastName = lastName;
        _phone = phone;
        _billingAddress = [billingAddress copy];
        _shippingAddress = [shippingAddress copy];
    }
    return self;
}

@end
