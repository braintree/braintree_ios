#import <Braintree/Braintree.h>

@interface BTThreeDSecureTokenizedCard : BTTokenizedCard

@property (nonatomic, readonly, assign) BOOL liabilityShifted;
@property (nonatomic, readonly, assign) BOOL liabilityShiftPossible;

@end
