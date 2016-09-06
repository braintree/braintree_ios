#import "BTPayPalRequest.h"

@implementation BTPayPalRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shippingAddressRequired = NO;
        _intent = BTPayPalRequestIntentAuthorize;
        _userAction = BTPayPalRequestUserActionDefault;
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
