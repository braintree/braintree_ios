#import "BTTokenizedPayPalAccount.h"
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTTokenizedPayPalAccount ()

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
