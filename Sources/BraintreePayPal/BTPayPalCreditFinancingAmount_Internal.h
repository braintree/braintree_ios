#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalCreditFinancingAmount.h>
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreePayPal/BTPayPalCreditFinancingAmount.h>
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTPayPalCreditFinancingAmount ()

- (instancetype)initWithCurrency:(NSString *)currency value:(NSString *)value;

- (instancetype)initWithJSON:(BTJSON *)json;

@end
