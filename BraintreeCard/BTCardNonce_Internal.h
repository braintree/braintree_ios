#import "BTCardNonce.h"
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTCardNonce ()

- (instancetype)initWithNonce:(nonnull NSString *)nonce
                  description:(nullable NSString *)description
                  cardNetwork:(BTCardNetwork)cardNetwork
                      lastTwo:(nullable NSString *)lastTwo
                    isDefault:(BOOL)isDefault
                     cardJSON:(BTJSON *)cardJSON;


/**
 Create a `BTCardNonce` object from JSON.
 */
+ (instancetype)cardNonceWithJSON:(BTJSON *)cardJSON;

/**
 Create a `BTCardNonce` object from GraphQL JSON.
 */
+ (instancetype)cardNonceWithGraphQLJSON:(BTJSON *)cardJSON;

@end

NS_ASSUME_NONNULL_END
