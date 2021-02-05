#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalRequest.h>
#else
#import <BraintreePayPal/BTPayPalRequest.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTPayPalCheckoutRequest : BTPayPalRequest

@end

NS_ASSUME_NONNULL_END
