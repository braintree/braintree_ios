#import "BTConfiguration+ThreeDSecure.h"

@implementation BTConfiguration (ThreeDSecure)

- (NSString *)cardinalAuthenticationJWT {
    return [self.json[@"threeDSecure"][@"cardinalAuthenticationJWT"] asString];
}

@end
