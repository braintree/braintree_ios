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
        self.enableShippingAddress = NO;
    }
    return self;
}

- (void)setShippingAddress:(ABRecordRef)shippingAddress {
    _shippingAddress = CFRetain(shippingAddress);
}

- (NSString *)description {
    NSString *shippingAddressDescription = @"(nil)";
    if (self.shippingAddress) {
        ABRecordGetRecordID(self.shippingAddress);
        shippingAddressDescription = (__bridge_transfer NSString *)ABRecordCopyCompositeName(self.shippingAddress);
    }
    return [NSString stringWithFormat:@"<BTPayPalCheckout:%p | amount:%@ enableShippingAddress:%@ shippingAddress:%@>",
            self,
            self.amount.stringValue,
            self.enableShippingAddress ? @"YES" : @"NO",
            shippingAddressDescription];
}

@end
