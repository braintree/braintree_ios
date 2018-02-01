#import "BTThreeDSecureInfo.h"

@interface BTThreeDSecureInfo ()

@property (nonatomic, strong) BTJSON *threeDSecureJSON;

@end

@implementation BTThreeDSecureInfo

- (instancetype)initWithJSON:(BTJSON *)json {
    if (self = [super init]) {
        if (json != nil) {
            _threeDSecureJSON = json;
        } else {
            _threeDSecureJSON = [BTJSON new];
        }
    }
    return self;
}

- (BOOL)liabilityShifted {
    return [self.threeDSecureJSON[@"liabilityShifted"] isTrue];
}

- (BOOL)liabilityShiftPossible {
    return [self.threeDSecureJSON[@"liabilityShiftPossible"] isTrue];
}

- (BOOL)wasVerified {
    return ![self.threeDSecureJSON[@"liabilityShifted"] isError] &&
        ![self.threeDSecureJSON[@"liabilityShiftPossible"] isError];
}

@end
