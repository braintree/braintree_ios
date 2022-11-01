#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalCreditFinancing.h>
#import <Braintree/BTPayPalAccountNonce.h>
#else
#import <BraintreePayPal/BTPayPalCreditFinancing.h>
#import <BraintreePayPal/BTPayPalAccountNonce.h>
#endif

@interface BTPayPalAccountNonce ()

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
              creditFinancing:(BTPayPalCreditFinancing *)creditFinancing;

@end
