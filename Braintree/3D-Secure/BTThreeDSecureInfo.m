#import "BTThreeDSecureInfo.h"

@interface BTThreeDSecureInfo ()
@property (nonatomic, strong) NSDictionary *dictionary;
@end

@implementation BTThreeDSecureInfo

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    if ((self = [super init])) {
        self.dictionary = otherDictionary;
    }
    return self;
}

- (BOOL)liabilityShiftPossible {
    return [self.dictionary[@"liabilityShiftPossible"] boolValue];
}

- (BOOL)liabilityShifted {
    return [self.dictionary[@"liabilityShifted"] boolValue];
}

@end
