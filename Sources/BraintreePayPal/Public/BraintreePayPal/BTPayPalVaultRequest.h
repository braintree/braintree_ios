#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalRequest.h>
#else
#import <BraintreePayPal/BTPayPalRequest.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Options for the PayPal Vault flow.
 */
@interface BTPayPalVaultRequest : BTPayPalRequest

/**
 Optional: Offers PayPal Credit if the customer qualifies. Defaults to false.
 */
@property (nonatomic) BOOL offerCredit;

@end

NS_ASSUME_NONNULL_END
