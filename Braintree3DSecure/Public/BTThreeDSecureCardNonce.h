#if __has_include("BraintreeCard.h")
#import "BTCardNonce.h"
#else
#import <BraintreeCard/BTCardNonce.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information about a tokenized 3D Secure card payment.
 */
@interface BTThreeDSecureCardNonce : BTCardNonce

/**
 True if the 3D Secure liability shift has occurred.
 */
@property (nonatomic, readonly, assign) BOOL liabilityShifted;

/**
 True if the 3D Secure liability shift is possible.
 */
@property (nonatomic, readonly, assign) BOOL liabilityShiftPossible;

#pragma mark - Internal

/**
 Used to initialize a `BTThreeDSecureCardNonce`.
 */
- (instancetype)initWithNonce:(NSString *)nonce
                  description:(nullable NSString *)description
                  cardNetwork:(BTCardNetwork)cardNetwork
                      lastTwo:(nullable NSString *)lastTwo
             threeDSecureJSON:(BTJSON *)threeDSecureJSON
                    isDefault:(BOOL)isDefault
                     cardJSON:(BTJSON *)cardJSON;
;

@end

NS_ASSUME_NONNULL_END
