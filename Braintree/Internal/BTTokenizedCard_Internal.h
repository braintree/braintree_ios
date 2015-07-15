#import "BTTokenizedCard.h"
#import "BTJSON.h"

@interface BTTokenizedCard ()

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                               cardNetwork:(BTCardNetwork)cardNetwork
                                   lastTwo:(NSString *)lastTwo
                          threeDSecureJSON:(BTJSON *)threeDSecureJSON;

+ (instancetype)cardWithJSON:(BTJSON *)cardJSON;

@end
