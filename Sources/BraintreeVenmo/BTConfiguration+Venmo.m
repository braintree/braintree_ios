#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BTConfiguration+Venmo.h>
#else
#import <BraintreeVenmo/BTConfiguration+Venmo.h>
#endif

@implementation BTConfiguration (Venmo)

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
