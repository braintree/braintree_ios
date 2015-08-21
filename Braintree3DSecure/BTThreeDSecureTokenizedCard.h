#import <BraintreeCard/BTTokenizedCard.h>

@interface BTThreeDSecureTokenizedCard : BTTokenizedCard

@property (nonatomic, readonly, assign) BOOL liabilityShifted;
@property (nonatomic, readonly, assign) BOOL liabilityShiftPossible;

#pragma mark - Internal

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                               cardNetwork:(BTCardNetwork)cardNetwork
                                   lastTwo:(NSString *)lastTwo
                          threeDSecureJSON:(BTJSON *)threeDSecureJSON;

@end
