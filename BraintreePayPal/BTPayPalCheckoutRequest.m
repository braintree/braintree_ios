#import "BTPayPalCheckoutRequest.h"

@implementation BTPayPalCheckoutRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enableShippingAddress = true;
        _addressOverride = false;
    }
    return self;
}

- (instancetype)initWithAmount:(NSDecimalNumber *)amount {
    if (amount == nil || [amount compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        return nil;
    }

    if (self = [self init]) {
        _amount = amount;
    }
    return self;
}

@end
