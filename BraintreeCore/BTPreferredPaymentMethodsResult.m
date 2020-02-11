#import "BTPreferredPaymentMethodsResult_Internal.h"

@implementation BTPreferredPaymentMethodsResult

- (instancetype)initWithJSON:(BTJSON * _Nullable)json {
    if (self = [super init]) {
        _isPayPalPreferred = [json[@"data"][@"clientConfiguration"][@"paypal"][@"preferredPaymentMethod"] isTrue];
    }
    return self;
}

@end
