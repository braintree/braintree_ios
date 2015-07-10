#import "BTTokenizedPayPalAccount.h"
#import "BTPostalAddress.h"

@interface BTTokenizedPayPalAccount ()

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                     email:(NSString *)email
                            accountAddress:(BTPostalAddress *)accountAddress;

@end
