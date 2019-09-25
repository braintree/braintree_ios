#import "BTCardNonce.h"
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTCardNonce ()

- (instancetype)initWithNonce:(nonnull NSString *)nonce
                  description:(nullable NSString *)description
                  cardNetwork:(BTCardNetwork)cardNetwork
                      lastTwo:(nullable NSString *)lastTwo
                    isDefault:(BOOL)isDefault
                     cardJSON:(BTJSON *)cardJSON
              authInsightJSON:(nullable BTJSON *)authInsightJSON;

/**
 Create a `BTCardNonce` object from JSON.
 */
+ (instancetype)cardNonceWithJSON:(BTJSON *)cardJSON;

/**
 Create a `BTCardNonce` object from GraphQL JSON.
 */
+ (instancetype)cardNonceWithGraphQLJSON:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END
