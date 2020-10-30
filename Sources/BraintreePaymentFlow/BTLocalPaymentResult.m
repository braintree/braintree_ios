#import <BraintreePaymentFlow/BTLocalPaymentResult.h>
#import <BraintreeCore/BraintreeCore.h>

@implementation BTLocalPaymentResult

- (instancetype)initWithNonce:(NSString *)nonce
                         type:(NSString *)type
                        email:(NSString *)email
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        phone:(NSString *)phone
               billingAddress:(BTPostalAddress *)billingAddress
              shippingAddress:(BTPostalAddress *)shippingAddress
             clientMetadataId:(NSString *)clientMetadataId
                      payerId:(NSString *)payerId
{
    if (self = [super init]) {
        _nonce = nonce;
        _type = type;
        _email = email;
        _firstName = firstName;
        _lastName = lastName;
        _phone = phone;
        _billingAddress = [billingAddress copy];
        _shippingAddress = [shippingAddress copy];
        _clientMetadataId = clientMetadataId;
        _payerId = payerId;
    }
    return self;
}

@end
