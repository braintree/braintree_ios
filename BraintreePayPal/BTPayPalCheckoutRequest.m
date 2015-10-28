#import "BTPayPalCheckoutRequest.h"

@implementation BTPayPalCheckoutRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shippingAddressRequired = NO;
    }
    return self;
}

- (instancetype)initWithAmount:(NSString *)amount {
    if (amount == nil) {
        return nil;
    }

    if (self = [self init]) {
        _amount = amount;
    }
    return self;
}

@end
