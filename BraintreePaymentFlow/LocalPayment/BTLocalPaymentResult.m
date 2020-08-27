#import "BTLocalPaymentResult.h"

#import <BraintreeCore/BTPostalAddress.h>

@implementation BTLocalPaymentResult

- (instancetype)initWithNonce:(NSString *)nonce
                  description:(NSString *)description
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
        _localizedDescription = description;
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
