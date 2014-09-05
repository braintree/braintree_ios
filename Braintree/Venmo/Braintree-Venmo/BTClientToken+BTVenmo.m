#import "BTClientToken+BTVenmo.h"

@implementation BTClientToken (BTVenmo)

- (NSString *)btVenmo_status {
    id status = self.claims[@"venmo"];
    if ([status isKindOfClass:[NSString class]]) {
        return status;
    } else {
        return nil;
    }
}

@end
