#import "BTThreeDSecureTokenizedCard.h"

@interface BTThreeDSecureTokenizedCard ()

@property (nonatomic, readonly, strong) BTJSON *threeDSecureJSON;

@end

@implementation BTThreeDSecureTokenizedCard

- (BOOL)liabilityShifted {
    return self.threeDSecureJSON[@"liabilityShifted"].isTrue;
}

- (BOOL)liabilityShiftPossible {
    return self.threeDSecureJSON[@"liabilityShiftPossible"].isTrue;
}

@end
