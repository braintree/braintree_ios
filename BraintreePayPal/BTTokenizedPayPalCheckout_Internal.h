#import "BTTokenizedPayPalCheckout.h"
#import "BTPostalAddress.h"

@interface BTTokenizedPayPalCheckout ()

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                     email:(NSString *)email
                                 firstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                                     phone:(NSString *)phone
                            billingAddress:(BTPostalAddress *)billingAddress
                           shippingAddress:(BTPostalAddress *)shippingAddress
                          clientMetadataId:(NSString *)clientMetadataId
                                   payerId:(NSString *)payerId;

@end
