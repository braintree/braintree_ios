#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTConfiguration+PayPal.h>
#else
#import <BraintreePayPal/BTConfiguration+PayPal.h>
#endif

@implementation BTConfiguration (PayPal)

- (BOOL)isPayPalEnabled {
    return [self.json[@"paypalEnabled"] isTrue];
}

- (BOOL)isBillingAgreementsEnabled {
    return [self.json[@"paypal"][@"billingAgreementsEnabled"] isTrue];
}

@end
