#import "BTConfiguration+Venmo.h"

@implementation BTConfiguration (Venmo)

+ (void)enableVenmo:(BOOL) __unused isEnabled { /* NO OP */ }

- (BOOL)isVenmoEnabled {
    return self.venmoAccessToken != nil;
}

- (NSString *)venmoAccessToken {
    return [self.json[@"payWithVenmo"][@"accessToken"] asString];
}

- (NSString *)venmoMerchantID {
    return [self.json[@"payWithVenmo"][@"merchantId"] asString];
}

- (NSString *)venmoEnvironment {
    return [self.json[@"payWithVenmo"][@"environment"] asString];
}

@end
