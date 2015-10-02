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
                            accountAddress:(BTPostalAddress *)accountAddress
                          clientMetadataId:(NSString *)clientMetadataId;

@end
