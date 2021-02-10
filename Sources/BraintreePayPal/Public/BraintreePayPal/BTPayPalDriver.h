#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTPayPalCheckoutRequest.h>
#import <Braintree/BTPayPalVaultRequest.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreePayPal/BTPayPalCheckoutRequest.h>
#import <BraintreePayPal/BTPayPalVaultRequest.h>
#endif

@class BTPayPalAccountNonce;
@class BTPayPalRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for PayPal errors.
 */
extern NSString *const BTPayPalDriverErrorDomain;

/**
 Error codes associated with PayPal.
 */
typedef NS_ENUM(NSInteger, BTPayPalDriverErrorType) {
    /// Unknown error
    BTPayPalDriverErrorTypeUnknown = 0,

    /// PayPal is disabled in configuration
    BTPayPalDriverErrorTypeDisabled,

    /// Invalid request, e.g. missing PayPal request
    BTPayPalDriverErrorTypeInvalidRequest,
    
    /// Braintree SDK is integrated incorrectly
    BTPayPalDriverErrorTypeIntegration,

    /// Payment flow was canceled, typically initiated by the user when exiting early from the flow.
    BTPayPalDriverErrorTypeCanceled
};

/** 
 BTPayPalDriver enables you to obtain permission to charge your customers' PayPal accounts by presenting the PayPal website.

 @note To make PayPal available, you must ensure that PayPal is enabled in your Braintree control panel.
 See our [online documentation](https://developers.braintreepayments.com/ios+ruby/guides/paypal) for
 details.

 This class supports two basic use-cases: Vault and Checkout. Each of these involves variations on the
 user experience as well as variations on the capabilities granted to you by this authorization.

 The *Vault* option uses PayPal's future payments authorization, which allows your merchant account to
 charge this customer arbitrary amounts for a long period of time into the future (unless the user
 manually revokes this permission in their PayPal control panel.) This authorization flow includes
 a screen with legal language that directs the user to agree to the terms of Future Payments.
 Unfortunately, it is not currently possible to collect shipping information in the Vault flow.

 The *Checkout* option creates a one-time use PayPal payment on your behalf. As a result, you must
 specify the checkout details up-front, so that they can be shown to the user during the PayPal flow.
 With this flow, you must specify the estimated transaction amount, and you can collect shipping
 details. This flow omits the Future Payments agreement, and the resulting payment method cannot be
 stored in the vault. It is only possible to create one Braintree transaction with this form of user
 approval.

 The user experience takes full advantage of One Touch. This
 means that users may bypass the username/password entry screen when they are already logged in.

 Upon successful completion, you will receive a `BTPayPalAccountNonce`, which includes user-facing
 details and a payment method nonce, which you must pass to your server in order to create a transaction
 or save the authorization in the Braintree vault (not possible with Checkout).

 ## User Experience Details

 To keep your UI in sync during authentication, you may set a delegate, which will be notified
 as the PayPal driver progresses through the various steps necessary for user
 authentication.

*/
@interface BTPayPalDriver : NSObject

/**
 Initialize a new PayPal driver instance.

 @param apiClient The API client
*/
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/**
 Check out with PayPal to create a single-use PayPal payment method nonce.

 @note You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
 server when this method completes without any additional user interaction.

 On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error. If the user cancels out of the flow, the error code will be `BTPayPalDriverErrorTypeCanceled`.

 @param request A PayPal Checkout request
 @param completionBlock This completion will be invoked exactly once when checkout is complete or an error occurs.
 */
- (void)requestOneTimePayment:(BTPayPalCheckoutRequest *)request
                   completion:(void (^)(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error))completionBlock DEPRECATED_MSG_ATTRIBUTE("Use tokenizePayPalAccount instead.");

/**
 Create a PayPal Billing Agreement for repeat purchases.

 @note You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
 server when this method completes without any additional user interaction.
 
 On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error. If the user cancels out of the flow, the error code will be `BTPayPalDriverErrorTypeCanceled`.

 @param request A PayPal Vault request
 @param completionBlock This completion will be invoked exactly once when checkout is complete or an error occurs.
*/
- (void)requestBillingAgreement:(BTPayPalVaultRequest *)request
                     completion:(void (^)(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error))completionBlock DEPRECATED_MSG_ATTRIBUTE("Use tokenizePayPalAccount instead.");

/**
 Tokenize a PayPal account for vault or checkout.

 @note You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
 server when this method completes without any additional user interaction.

 On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error. If the user cancels out of the flow, the error code will be `BTPayPalDriverErrorTypeCanceled`.

 @param request Either a BTPayPalCheckoutRequest or a BTPayPalVaultRequest
 @param completionBlock This completion will be invoked exactly once when tokenization is complete or an error occurs.
*/
- (void)tokenizePayPalAccountWithPayPalRequest:(BTPayPalRequest *)request
                                    completion:(void (^)(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
