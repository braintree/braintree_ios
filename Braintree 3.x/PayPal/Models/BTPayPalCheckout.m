#import "BTPayPalCheckout.h"
#import "BTLogger_Internal.h"

@interface BTPayPalCheckout ()
@end

@implementation BTPayPalCheckout

+ (instancetype)checkoutWithAmount:(NSDecimalNumber *)amount {
    BTPayPalCheckout *checkout = [[BTPayPalCheckout alloc] initWithAmount:amount];
    return checkout;
}
 
- (instancetype)initWithAmount:(NSDecimalNumber *)amount {
    if (amount == nil || [amount compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        [[BTLogger sharedLogger] log:@"Failed to initialize BTPayPalCheckout - amount must be a positive number."];
        return nil;
        
    }
    self = [self init];
    if (self) {
        self.amount = amount;
        self.enableShippingAddress = YES;
        self.addressOverride = NO;
    }
    return self;
}

- (NSString *)description {
    NSString *shippingAddressDescription = @"(nil)";
    if (self.shippingAddress) {
        shippingAddressDescription = [self.shippingAddress debugDescription];
    }
    return [NSString stringWithFormat:@"<BTPayPalCheckout:%p | amount:%@ enableShippingAddress:%@ addressOverride:%@ shippingAddress:%@>",
            self,
            self.amount.stringValue,
            self.enableShippingAddress ? @"YES" : @"NO",
            self.addressOverride ? @"YES" : @"NO",
            shippingAddressDescription];
}

@end
