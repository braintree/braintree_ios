#import "BTThreeDSecureLookup.h"

@implementation BTThreeDSecureLookup

- (instancetype)initWithJSON:(BTJSON *)json {
    self = [super init];
    if (self) {
        _PAReq = [json[@"pareq"] asString];
        _MD = [json[@"md"] asString];
        _acsURL = [json[@"acsUrl"] asURL];
        _termURL = [json[@"termUrl"] asURL];
    }
    return self;
}

- (BOOL)requiresUserAuthentication {
    return self.acsURL != nil;
}

@end
