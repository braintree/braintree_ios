#import "BTPayPalDriver.h"

@implementation BTPayPalDriver

- (nonnull instancetype)initWithConfiguration:(nonnull BTConfiguration *)configuration {
    // TODO
    return [self init];
}
    
- (void)authorizeAccountWithCompletion:(nonnull void (^)(BTTokenizedPayPalAccount * __nonnull, NSError * __nonnull))completionBlock {
    // TODO
}

- (void)authorizeAccountWithAdditionalScopes:(nonnull NSSet<NSString *> *)additionalScopes completion:(nonnull void (^)(BTTokenizedPayPalAccount * __nonnull, NSError * __nonnull))completionBlock {
    // TODO
}

- (void)checkoutWithCheckoutRequest:(nonnull BTPayPalCheckoutRequest *)checkoutRequest completion:(nonnull void (^)(BTTokenizedPayPalCheckout * __nonnull, NSError * __nonnull))completionBlock {
    // TODO
}

@end
