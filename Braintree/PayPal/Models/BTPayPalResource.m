#import "BTPayPalResource.h"
#import "BTLogger_Internal.h"

@interface BTPayPalResource ()
@end

@implementation BTPayPalResource

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    return [NSString stringWithFormat:@"<BTPayPalCheckout:%p | enableShippingAddress:%@ addressOverride:%@ shippingAddress:%@>",
            self,
            self.enableShippingAddress ? @"YES" : @"NO",
            self.addressOverride ? @"YES" : @"NO",
            shippingAddressDescription];
}

@end
