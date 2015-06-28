#import "BTThreeDSecureInfo.h"

@interface BTThreeDSecureInfo ()
@property (nonatomic, readwrite, assign) BOOL liabilityShiftPossible;
@property (nonatomic, readwrite, assign) BOOL liabilityShifted;
@end

@implementation BTThreeDSecureInfo

+ (BTThreeDSecureInfo *)infoWithLiabilityShiftPossible:(BOOL)liabilityShiftPossible liabilityShifted:(BOOL)liabilityShifted {
    BTThreeDSecureInfo *info = [[BTThreeDSecureInfo alloc] init];
    info.liabilityShiftPossible = liabilityShiftPossible;
    info.liabilityShifted = liabilityShifted;
    return info;
}

@end
