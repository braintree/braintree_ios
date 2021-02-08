#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTLocalPaymentResult.h>
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreePaymentFlow/BTLocalPaymentResult.h>
#import <BraintreeCore/BraintreeCore.h>
#endif

@implementation BTLocalPaymentResult

- (instancetype)initWithNonce:(NSString *)nonce
                         type:(NSString *)type
                        email:(NSString *)email
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        phone:(NSString *)phone
               billingAddress:(BTPostalAddress *)billingAddress
              shippingAddress:(BTPostalAddress *)shippingAddress
             clientMetadataID:(NSString *)clientMetadataID
                      payerID:(NSString *)payerID
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
        _clientMetadataID = clientMetadataID;
        _payerID = payerID;
    }
    return self;
}

@end
