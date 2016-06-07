#import "BTPayPalRequest.h"

@implementation BTPayPalRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shippingAddressRequired = NO;
        _intent = BTPayPalRequestIntentAuthorize;
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

+ (NSString *)intentTypeToString:(BTPayPalRequestIntent)intentType {
    NSString *result = nil;
    
    switch(intentType) {
        case BTPayPalRequestIntentAuthorize:
            result = @"authorize";
            break;
        case BTPayPalRequestIntentSale:
            result = @"sale";
            break;
        default:
            result = @"authorize";
            break;
    }
    
    return result;
}

@end
