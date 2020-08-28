#import "BTConfiguration+LocalPayment.h"

@implementation BTConfiguration (LocalPayment)

- (BOOL)isLocalPaymentEnabled {
    // Local Payments are enabled when PayPal is enabled
    return [self.json[@"paypalEnabled"] isTrue];
}

@end
