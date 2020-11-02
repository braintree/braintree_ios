#if __has_include(<Braintree/BraintreeCard.h>)
#import <Braintree/BTCardNonce.h>
#else
#import <BraintreeCard/BTCardNonce.h>
#endif

@class BTJSON;

NS_ASSUME_NONNULL_BEGIN

@interface BTCardNonce ()

- (instancetype)initWithNonce:(nonnull NSString *)nonce
                  cardNetwork:(BTCardNetwork)cardNetwork
              expirationMonth:(nullable NSString *)expirationMonth
               expirationYear:(nullable NSString *)expirationYear
               cardholderName:(nullable NSString *)cardholderName
                      lastTwo:(nullable NSString *)lastTwo
                     lastFour:(nullable NSString *)lastFour
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
