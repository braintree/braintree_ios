#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalRequest.h>
#else
#import <BraintreePayPal/BTPayPalRequest.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Payment intent.

 @note Must be set to BTPayPalRequestIntentSale for immediate payment, BTPayPalRequestIntentAuthorize to authorize a payment for capture later, or BTPayPalRequestIntentOrder to create an order. Defaults to BTPayPalRequestIntentAuthorize. Only applies to PayPal Checkout.

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

/**
 The call-to-action in the PayPal Checkout flow.

 @note By default the final button will show the localized word for "Continue" and implies that the final amount billed is not yet known.
             Setting the BTPayPalRequest's userAction to `BTPayPalRequestUserActionCommit` changes the button text to "Pay Now", conveying to
             the user that billing will take place immediately.
*/
typedef NS_ENUM(NSInteger, BTPayPalRequestUserAction) {
    /// Default
    BTPayPalRequestUserActionDefault = 1,

    /// Commit
    BTPayPalRequestUserActionCommit,
};

@interface BTPayPalCheckoutRequest : BTPayPalRequest

+ (instancetype)new __attribute__((unavailable("Please use initWithAmount:")));

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithAmount:")));

/**
 Initialize a PayPal request with an amount for a one-time payment.

 @param amount Used for a one-time payment. Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
 @return A PayPal Checkout request.
*/
- (instancetype)initWithAmount:(NSString *)amount;

/**
 Used for a one-time payment.

 Amount must be greater than or equal to zero, may optionally contain exactly 2 decimal places separated by '.' and is limited to 7 digits before the decimal point.
*/
@property (nonatomic, readonly, strong) NSString *amount;

/**
 Optional: A three-character ISO-4217 ISO currency code to use for the transaction. Defaults to merchant currency code if not set.

 @note See https://developer.paypal.com/docs/api/reference/currency-codes/ for a list of supported currency codes.
*/
@property (nonatomic, nullable, copy) NSString *currencyCode;

/**
 Optional: Payment intent. Defaults to BTPayPalRequestIntentAuthorize. Only applies to PayPal Checkout.
*/
@property (nonatomic) BTPayPalRequestIntent intent;

/**
 Optional: Changes the call-to-action in the PayPal Checkout flow. Defaults to `BTPayPalRequestUserActionDefault`.
*/
@property (nonatomic) BTPayPalRequestUserAction userAction;

/**
 Optional: Offers PayPal Pay Later if the customer qualifies. Defaults to false. Only available with PayPal Checkout.
 */
@property (nonatomic) BOOL offerPayLater;

/**
 Optional: If set to true, this enables the Checkout with Vault flow, where the customer will be prompted to consent to a billing agreement during checkout.
 */
@property (nonatomic) BOOL requestBillingAgreement;

@end

NS_ASSUME_NONNULL_END
