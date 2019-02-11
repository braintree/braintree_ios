#import "BTThreeDSecureLookup.h"

@implementation BTThreeDSecureLookup

- (instancetype)initWithJSON:(BTJSON *)json {
    self = [super init];
    if (self) {
        _PAReq = [json[@"pareq"] asString];
        _MD = [json[@"md"] asString];
        _acsURL = [json[@"acsUrl"] asURL];
        _termURL = [json[@"termUrl"] asURL];
        _threeDSecureVersion = [json[@"threeDSecureVersion"] asString];
        _transactionId = [json[@"transactionId"] asString];
    }
    return self;
}

- (BOOL)requiresUserAuthentication {
    return self.acsURL != nil;
}

- (BOOL)isThreeDSecureVersion2 {
    return [self.threeDSecureVersion hasPrefix:@"2."];
}

@end
