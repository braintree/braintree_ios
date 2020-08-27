#import <BraintreePaymentFlow/BTConfiguration+LocalPayment.h>
#import <BraintreeCore/BTJSON.h>

@implementation BTConfiguration (LocalPayment)

- (BOOL)isLocalPaymentEnabled {
    // Local Payments are enabled when PayPal is enabled
    return [self.json[@"paypalEnabled"] isTrue];
}

@end
