#import "BTPreferredPaymentMethodsResult_Internal.h"
#import "BraintreeCoreSwiftImports.h"

@implementation BTPreferredPaymentMethodsResult

- (instancetype)initWithJSON:(BTJSON * _Nullable)json venmoInstalled:(BOOL)venmoInstalled {
    if (self = [super init]) {
        _isPayPalPreferred = [json[@"data"][@"preferredPaymentMethods"][@"paypalPreferred"] isTrue];
        _isVenmoPreferred = venmoInstalled;
    }
    return self;
}

@end
