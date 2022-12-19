#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BTPayPalPaymentType);
@class BTPayPalAccountNonce;
@class BTPayPalRequest;
@class BTPostalAddress;
@class BTAPIClient;

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for PayPal errors.
 */
extern NSString *const BTPayPalErrorDomain;

/**
 Error codes associated with PayPal.
 */
typedef NS_ENUM(NSInteger, BTPayPalErrorType) {
    /// Unknown error
    BTPayPalErrorTypeUnknown = 0,

    /// PayPal is disabled in configuration
    BTPayPalErrorTypeDisabled,

    /// Invalid request, e.g. missing PayPal request
    BTPayPalErrorTypeInvalidRequest,
    
    /// Braintree SDK is integrated incorrectly
    BTPayPalErrorTypeIntegration,

    /// Payment flow was canceled, typically initiated by the user when exiting early from the flow.
    BTPayPalErrorTypeCanceled
};

/** 
 Used to tokenize PayPal accounts.
*/
@interface BTPayPalClient : NSObject

/**
 Initialize a new PayPal client instance.

 @param apiClient The API client
*/
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/**
 Tokenize a PayPal account for vault or checkout.

 @note You can use this as the final step in your order/checkout flow. If you want, you may create a transaction from your
 server when this method completes without any additional user interaction.

 On success, you will receive an instance of `BTPayPalAccountNonce`; on failure or user cancelation you will receive an error. If the user cancels out of the flow, the error code will be `BTPayPalClientErrorTypeCanceled`.

 @param request Either a BTPayPalCheckoutRequest or a BTPayPalVaultRequest
 @param completionBlock This completion will be invoked exactly once when tokenization is complete or an error occurs.
*/
- (void)tokenizePayPalAccountWithPayPalRequest:(BTPayPalRequest *)request
                                    completion:(void (^)(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
