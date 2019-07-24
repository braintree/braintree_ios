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

- (NSString *)cavv {
    return [self.threeDSecureJSON[@"cavv"] asString];
}

- (NSString *)dsTransactionId {
    return [self.threeDSecureJSON[@"dsTransactionId"] asString];
}

- (NSString *)eciFlag {
    return [self.threeDSecureJSON[@"eciFlag"] asString];
}

- (NSString *)enrolled {
    return [self.threeDSecureJSON[@"enrolled"] asString];
}

- (BOOL)liabilityShifted {
    return [self.threeDSecureJSON[@"liabilityShifted"] isTrue];
}

- (BOOL)liabilityShiftPossible {
    return [self.threeDSecureJSON[@"liabilityShiftPossible"] isTrue];
}

- (NSString *)status {
    return [self.threeDSecureJSON[@"status"] asString];
}

- (NSString *)threeDSecureVersion {
    return [self.threeDSecureJSON[@"threeDSecureVersion"] asString];
}

- (BOOL)wasVerified {
    return ![self.threeDSecureJSON[@"liabilityShifted"] isError] &&
        ![self.threeDSecureJSON[@"liabilityShiftPossible"] isError];
}

- (NSString *)xid {
    return [self.threeDSecureJSON[@"xid"] asString];
}

@end
