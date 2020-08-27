#import "BTConfiguration+PayPal.h"

#import <BraintreeCore/BTJSON.h>

@implementation BTConfiguration (PayPal)

- (BOOL)isPayPalEnabled {
    return [self.json[@"paypalEnabled"] isTrue];
}

- (BOOL)isBillingAgreementsEnabled {
    return [self.json[@"paypal"][@"billingAgreementsEnabled"] isTrue];
}

@end
