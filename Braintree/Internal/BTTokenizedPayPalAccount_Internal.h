#import "BTTokenizedPayPalAccount.h"
#import "BTPostalAddress.h"

@interface BTTokenizedPayPalAccount ()

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                     email:(NSString *)email
                                 firstName:(NSString *)firstName
                                  lastName:(NSString *)lastName
                            billingAddress:(BTPostalAddress *)billingAddress
                           shippingAddress:(BTPostalAddress *)shippingAddress;
@end
