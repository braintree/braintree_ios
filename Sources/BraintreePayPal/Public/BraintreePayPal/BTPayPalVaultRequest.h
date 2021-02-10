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
 Optional: Display a custom description to the user for a billing agreement.
*/
@property (nonatomic, nullable, copy) NSString *billingAgreementDescription;

@end

NS_ASSUME_NONNULL_END
