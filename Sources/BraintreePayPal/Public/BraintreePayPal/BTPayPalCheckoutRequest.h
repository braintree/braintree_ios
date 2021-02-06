#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalRequest.h>
#else
#import <BraintreePayPal/BTPayPalRequest.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Payment intent.

 @note Must be set to sale for immediate payment, authorize to authorize a payment for capture later, or order to create an order. Defaults to authorize. Only works in the checkout (one-time payment) flow.

 @see https://developer.paypal.com/docs/integration/direct/payments/capture-payment/ Capture payments later
 @see https://developer.paypal.com/docs/integration/direct/payments/create-process-order/ Create and process orders
*/
typedef NS_ENUM(NSInteger, BTPayPalRequestIntent) {
    /// Authorize
    BTPayPalRequestIntentAuthorize = 1,

    /// Sale
    BTPayPalRequestIntentSale,

    /// Order
    BTPayPalRequestIntentOrder,
};

@interface BTPayPalCheckoutRequest : BTPayPalRequest

+ (instancetype)new __attribute__((unavailable("Please use initWithAmount:")));

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithAmount:")));

/**
 Initialize a PayPal request with an amount for a one-time payment.

 @param amount Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.', optional thousands separator ',', and is limited to 7 digits before the decimal point.
 @return A PayPal request.
*/
- (instancetype)initWithAmount:(NSString *)amount;

/**
 Used for a one-time payment.

 Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.', optional thousands separator ',', and is limited to 7 digits before the decimal point.
*/
@property (nonatomic, readonly, strong) NSString *amount;

/**
 Optional: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
 @note This is only used for one-time payments.
*/
@property (nonatomic, nullable, copy) NSString *currencyCode;

/**
 Optional: Payment intent. Only applies when using checkout flow. Defaults to `BTPayPalRequestIntentAuthorize`.
*/
@property (nonatomic) BTPayPalRequestIntent intent;

/**
 Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to false. Only available with PayPal Checkout.
 */
@property (nonatomic) BOOL offerPayLater;

@end

NS_ASSUME_NONNULL_END
