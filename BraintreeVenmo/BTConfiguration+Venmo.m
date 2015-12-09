#import "BTConfiguration+Venmo.h"

@implementation BTConfiguration (Venmo)

+ (void)enableVenmo:(BOOL)isEnabled {
    [BTConfiguration setBetaPaymentOption:@"venmo" isEnabled:isEnabled];
}

- (BOOL)isVenmoEnabled {
    return (self.venmoAccessToken != nil) && [BTConfiguration isBetaEnabledPaymentOption:@"venmo"];
}

- (NSString*)venmoAccessToken {
    return [self.json[@"payWithVenmo"][@"accessToken"] asString];
}

@end
