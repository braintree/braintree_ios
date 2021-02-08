#import "BTPayPalAccountNonce_Internal.h"

@interface BTPayPalAccountNonce ()

@property (nonatomic, readwrite, copy) NSString *email;
@property (nonatomic, readwrite, copy) NSString *firstName;
@property (nonatomic, readwrite, copy) NSString *lastName;
@property (nonatomic, readwrite, copy) NSString *phone;
@property (nonatomic, readwrite, strong) BTPostalAddress *billingAddress;
@property (nonatomic, readwrite, strong) BTPostalAddress *shippingAddress;
@property (nonatomic, readwrite, copy) NSString *clientMetadataID;
@property (nonatomic, readwrite, copy) NSString *payerID;
@property (nonatomic, readwrite, strong) BTPayPalCreditFinancing *creditFinancing;

@end

@implementation BTPayPalAccountNonce

- (instancetype)initWithNonce:(NSString *)nonce
                        email:(NSString *)email
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        phone:(NSString *)phone
               billingAddress:(BTPostalAddress *)billingAddress
              shippingAddress:(BTPostalAddress *)shippingAddress
             clientMetadataID:(NSString *)clientMetadataID
                      payerID:(NSString *)payerID
                    isDefault:(BOOL)isDefault
              creditFinancing:(BTPayPalCreditFinancing *)creditFinancing {
    if (self = [super initWithNonce:nonce type:@"PayPal" isDefault:isDefault]) {
        _email = email;
        _firstName = firstName;
        _lastName = lastName;
        _phone = phone;
        _billingAddress = [billingAddress copy];
        _shippingAddress = [shippingAddress copy];
        _clientMetadataID = clientMetadataID;
        _payerID = payerID;
        _creditFinancing = creditFinancing;
    }
    return self;
}

@end
