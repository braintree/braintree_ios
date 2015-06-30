#import "BTTokenizedCard.h"

@interface BTTokenizedCard ()

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                               cardNetwork:(BTCardNetwork)cardNetwork
                                   lastTwo:(NSString *)lastTwo
                          threeDSecureInfo:(BTThreeDSecureInfo *)threeDSecureInfo;
@end
