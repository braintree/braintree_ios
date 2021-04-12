#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BTVenmoRequest.h>
#else
#import <BraintreeVenmo/BTVenmoRequest.h>
#endif

@interface BTVenmoRequest ()

@property (nonatomic, nullable, copy, readonly) NSString *paymentMethodUsageAsString;

@end
