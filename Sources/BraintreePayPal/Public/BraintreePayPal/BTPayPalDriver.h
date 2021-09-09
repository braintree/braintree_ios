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
 Used to tokenize PayPal accounts.
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
