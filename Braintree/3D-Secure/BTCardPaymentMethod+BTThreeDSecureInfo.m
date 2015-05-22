#import "BTCardPaymentMethod+BTThreeDSecureInfo.h"
#import "BTCardPaymentMethod_Mutable.h"

@implementation BTCardPaymentMethod (BTThreeDSecureInfo)

- (BTThreeDSecureInfo *)threeDSecureInfo {
    return [BTThreeDSecureInfo infoWithLiabilityShiftPossible:[self.threeDSecureInfoDictionary[@"liabilityShiftPossible"] boolValue]
                                             liabilityShifted:[self.threeDSecureInfoDictionary[@"liabilityShifted"] boolValue]];
}

@end
