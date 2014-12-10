#import "BTThreeDSecureLookup.h"

@implementation BTThreeDSecureLookup

- (BOOL)requiresUserAuthentication {
    return self.acsURL != nil;
}

@end
