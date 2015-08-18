#import "BTPayPalCheckoutRequest.h"

@implementation BTPayPalCheckoutRequest

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
