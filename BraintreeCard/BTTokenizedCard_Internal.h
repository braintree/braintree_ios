#import "BTTokenizedCard.h"
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTTokenizedCard ()

- (instancetype)initWithPaymentMethodNonce:(nonnull NSString *)nonce
                               description:(nullable NSString *)description
                               cardNetwork:(BTCardNetwork)cardNetwork
                                   lastTwo:(nullable NSString *)lastTwo;

@end

NS_ASSUME_NONNULL_END
