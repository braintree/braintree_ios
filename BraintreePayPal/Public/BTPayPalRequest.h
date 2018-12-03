#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPayPalLineItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Payment intent.

 @note Must be set to sale for immediate payment, authorize to authorize a payment for capture later, or order to create an order. Defaults to authorize. Only works in the Single Payment flow.

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
 Use this option to specify the PayPal page to display when a user lands on the PayPal site to complete the payment.
*/
typedef NS_ENUM(NSInteger, BTPayPalRequestLandingPageType) {
    /// Default
    BTPayPalRequestLandingPageTypeDefault = 1,

    /// Login
    BTPayPalRequestLandingPageTypeLogin,

    /// Billing
    BTPayPalRequestLandingPageTypeBilling,
};

/**
 The call-to-action in the PayPal one-time payment checkout flow.

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

/**
 A PayPal request specifies options that control the PayPal flow.

 @note For a one-time payment, the request must specify a transaction amount.

 @see BTPayPalDriver
*/
@interface BTPayPalRequest : NSObject

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
 Defaults to false. When set to true, the shipping address selector will be displayed.
*/
@property (nonatomic, getter=isShippingAddressRequired) BOOL shippingAddressRequired;

/**
 Defaults to false. Set to true to enable user editing of the shipping address.

 @note Only applies when `shippingAddressOverride` is set.
 */
@property (nonatomic, getter=isShippingAddressEditable) BOOL shippingAddressEditable;

/**
 Optional: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
 @note This is only used for one-time payments.
*/
@property (nonatomic, nullable, copy) NSString *currencyCode;

/**
 Optional: A locale code to use for the transaction.

 @note Supported locales are:

 `da_DK`,
 `de_DE`,
 `en_AU`,
 `en_GB`,
 `en_US`,
 `es_ES`,
 `es_XC`,
 `fr_CA`,
 `fr_FR`,
 `fr_XC`,
 `id_ID`,
 `it_IT`,
 `ja_JP`,
 `ko_KR`,
 `nl_NL`,
 `no_NO`,
 `pl_PL`,
 `pt_BR`,
 `pt_PT`,
 `ru_RU`,
 `sv_SE`,
 `th_TH`,
 `tr_TR`,
 `zh_CN`,
 `zh_HK`,
 `zh_TW`,
 `zh_XC`.
*/
@property (nonatomic, nullable, copy) NSString *localeCode;

/**
 Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
*/
@property (nonatomic, nullable, strong) BTPostalAddress *shippingAddressOverride;

/**
 Optional: Display a custom description to the user for a billing agreement.
*/
@property (nonatomic, nullable, copy) NSString *billingAgreementDescription;

/**
 Optional: Payment intent. Only applies when using checkout flow. Defaults to `BTPayPalRequestIntentAuthorize`.
*/
@property (nonatomic) BTPayPalRequestIntent intent;

/**
 Optional: Changes the call-to-action in the PayPal flow. This option works for both checkout and vault flows. Defaults to `BTPayPalRequestUserActionDefault`.
*/
@property (nonatomic) BTPayPalRequestUserAction userAction;

/**
 Optional: Landing page type. Defaults to `BTPayPalRequestLandingPageTypeDefault`.

 @note Setting the BTPayPalRequest's landingPageType changes the PayPal page to display when a user lands on the PayPal site to complete the payment. BTPayPalRequestLandingPageTypeLogin specifies a PayPal account login page is used. BTPayPalRequestLandingPageTypeBilling specifies a non-PayPal account landing page is used.
 */
@property (nonatomic) BTPayPalRequestLandingPageType landingPageType;

/**
 Optional: The merchant name displayed inside of the PayPal flow; defaults to the company name on your Braintree account
*/
@property (nonatomic, nullable, copy) NSString *displayName;

/**
 Optional: Offers PayPal Credit if the customer qualifies. Defaults to false. Only available with PayPal Checkout and PayPal Billing Agreement.
 */
@property (nonatomic) BOOL offerCredit;

/**
 Optional: A non-default merchant account to use for tokenization.
*/
@property (nonatomic, nullable, copy) NSString *merchantAccountId;

/**
 Optional: The line items for this transaction. It can include up to 249 line items.
*/
@property (nonatomic, nullable, copy) NSArray<BTPayPalLineItem *> *lineItems;

@end

NS_ASSUME_NONNULL_END
