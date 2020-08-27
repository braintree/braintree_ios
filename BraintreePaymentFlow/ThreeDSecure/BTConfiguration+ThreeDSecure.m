#import "BTConfiguration+ThreeDSecure.h"

#import <BraintreeCore/BTJSON.h>

@implementation BTConfiguration (ThreeDSecure)

- (NSString *)cardinalAuthenticationJWT {
    return [self.json[@"threeDSecure"][@"cardinalAuthenticationJWT"] asString];
}

@end
