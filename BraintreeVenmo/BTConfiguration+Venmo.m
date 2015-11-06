#import "BTConfiguration+Venmo.h"

@implementation BTConfiguration (Venmo)

- (BOOL)isVenmoEnabled {
    BTJSON *venmoConfiguration = self.json[@"venmo"];
    return venmoConfiguration.isString && ![venmoConfiguration.asString isEqualToString:@"off"];
}

@end
