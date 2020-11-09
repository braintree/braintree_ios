#import "BTPreferredPaymentMethodsResult_Internal.h"

#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTJSON.h>
#else
#import <BraintreeCore/BTJSON.h>
#endif

@implementation BTPreferredPaymentMethodsResult

- (instancetype)initWithJSON:(BTJSON * _Nullable)json venmoInstalled:(BOOL)venmoInstalled {
    if (self = [super init]) {
        _isPayPalPreferred = [json[@"data"][@"preferredPaymentMethods"][@"paypalPreferred"] isTrue];
        _isVenmoPreferred = venmoInstalled;
    }
    return self;
}

@end
