#import "BTCardNonce.h"
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTCardNonce ()

- (instancetype)initWithPaymentMethodNonce:(nonnull NSString *)nonce
                               description:(nullable NSString *)description
                               cardNetwork:(BTCardNetwork)cardNetwork
                                   lastTwo:(nullable NSString *)lastTwo;

@end

NS_ASSUME_NONNULL_END
