#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalCheckoutRequest.h>
#else
#import <BraintreePayPal/BTPayPalCheckoutRequest.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTPayPalCheckoutRequest ()

@property (nonatomic, copy, readonly) NSString *intentAsString;
@property (nonatomic, copy, readonly) NSString *userActionAsString;

@end

NS_ASSUME_NONNULL_END
