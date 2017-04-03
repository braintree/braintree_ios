#import <Foundation/Foundation.h>

#import "BTCardPaymentMethod.h"
#import "BTPayPalPaymentMethod.h"

#import "BTApplePayPaymentMethod.h"
#import "BTCoinbasePaymentMethod.h"

#import "BTErrors.h"
#import "BTClientCardRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class BTClient, BTCoinbasePaymentMethod;

#pragma mark Types

/// Block type that takes an `NSArray` of `BTPaymentMethod`s
#if (defined(__clang__) && __has_feature(objc_generics))
typedef void (^BTClientPaymentMethodListSuccessBlock)(NSArray<BTPaymentMethod *> *paymentMethods);
#else
typedef void (^BTClientPaymentMethodListSuccessBlock)(NSArray *paymentMethods);
#endif

/// Block type that takes a single `BTPaymentMethod`
typedef void (^BTClientPaymentMethodSuccessBlock)(BTPaymentMethod *paymentMethod);

/// Block type that takes a `BTCardPaymentMethod`
typedef void (^BTClientCardSuccessBlock)(BTCardPaymentMethod *card);

#if BT_ENABLE_APPLE_PAY
/// Success Block type for the Save Apple Pay call
typedef void (^BTClientApplePaySuccessBlock)(BTApplePayPaymentMethod *applePayPaymentMethod);
#endif

/// Success Block type for the Save Paypal call
typedef void (^BTClientPaypalSuccessBlock)(BTPayPalPaymentMethod *paypalPaymentMethod);

/// Success Block type for the Save Coinbase call
typedef void (^BTClientCoinbaseSuccessBlock)(BTCoinbasePaymentMethod *coinbasePaymentMethod);

/// Success Block type for analytics events
typedef void (^BTClientAnalyticsSuccessBlock)(void);

/// Block type for handling `BTClient` errors
typedef void (^BTClientFailureBlock)(NSError *error);

/// A `BTClient` performs Braintree API operations and returns
/// resulting responses or errors. It is the entry-point for all
/// communication with Braintree.
@interface BTClient : NSObject <NSCoding, NSCopying>

/// Initialize and configure a `BTClient` with a client token.
/// The client token dictates the behavior of subsequent operations.
///
/// @param clientTokenString Braintree client token
- (nullable instancetype)initWithClientToken:(NSString *)clientTokenString;

/// The set of challenges that need to be provided to `saveCardWithNumber`
/// in order to save a card. This is dependent upon on your Gateway settings
/// (potentially among other factors).
@property (nonatomic, nullable, readonly) NSSet *challenges;

/// The public Braintree Merchant ID for which this client
/// was initialized.
@property (nonatomic, nullable, copy, readonly) NSString *merchantId;

/// A set of strings denoting additional scopes to use when authorizing a PayPal account.
/// See PayPalOAuthScopes.h for a list of available scopes.
#if (defined(__clang__) && __has_feature(objc_generics))
@property (nonatomic, nullable, copy) NSSet<NSString *> *additionalPayPalScopes;
#else
@property (nonatomic, nullable, copy) NSSet *additionalPayPalScopes;
#endif

#pragma mark - Fetch a Payment Method

/// Obtain a list of payment methods saved to Braintree
///
/// @param successBlock success callback for handling the returned list of payment methods
/// @param failureBlock failure callback for handling errors
- (void)fetchPaymentMethodsWithSuccess:(nullable BTClientPaymentMethodListSuccessBlock)successBlock
                               failure:(nullable BTClientFailureBlock)failureBlock;

/// Obtain information about a payment method based on a nonce
///
/// @param successBlock success callback for handling the retrieved payment methods
/// @param failureBlock failure callback for handling errors
- (void)fetchPaymentMethodWithNonce:(NSString *)nonce
                            success:(nullable BTClientPaymentMethodSuccessBlock)successBlock
                            failure:(nullable BTClientFailureBlock)failureBlock;

#pragma mark Save a New Payment Method

/// Save a card to Braintree
///
/// @param request an object that includes the raw card details
/// @param successBlock success callback for handling the resulting new card
/// @param failureBlock failure callback for handling errors
///
/// @see challenges
- (void)saveCardWithRequest:(BTClientCardRequest *)request
                    success:(nullable BTClientCardSuccessBlock)successBlock
                    failure:(nullable BTClientFailureBlock)failureBlock;

#if BT_ENABLE_APPLE_PAY
/// Save a payment method created via Apple Pay
///
/// @param payment A `PKPayment` instance
/// @param successBlock success callback for handling the resulting payment method
/// @param failureBlock failure callback for handling errors
- (void)saveApplePayPayment:(PKPayment *)payment
                    success:(nullable BTClientApplePaySuccessBlock)successBlock
                    failure:(nullable BTClientFailureBlock)failureBlock;
#endif

/// Save a paypal payment method to Braintree
///
/// @param authCode Authorization Code
/// @param applicationCorrelationId PayPal App Correlation Id (See `-[BTClient btPayPal_applicationCorrelationId]` and https://github.com/paypal/PayPal-iOS-SDK/blob/master/docs/future_payments_mobile.md#obtain-an-application-correlation-id.)
/// @param successBlock success callback for handling the resulting new PayPal account payment method
/// @param failureBlock failure callback for handling errors
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                   applicationCorrelationID:(NSString *)applicationCorrelationId
                                    success:(nullable BTClientPaypalSuccessBlock)successBlock
                                    failure:(nullable BTClientFailureBlock)failureBlock;

/// Save a paypal payment method to Braintree without a PayPal App Correlation ID
///
/// @note This signature has been deprecated in favor of
/// savePaypalPaymentMethodWithAuthCode:applicationCorrelationID:success:failure: to encourage the submission
/// of PayPal app correlation ids.
///
/// @param authCode Authorization Code
/// @param successBlock success callback for handling the resulting new PayPal account payment method
/// @param failureBlock failure callback for handling errors
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                                    success:(nullable BTClientPaypalSuccessBlock)successBlock
                                    failure:(nullable BTClientFailureBlock)failureBlock DEPRECATED_ATTRIBUTE;

/// Save a paypal payment method to Braintree
///
/// @note This signature has been deprecated in favor of
/// savePaypalPaymentMethodWithAuthCode:applicationCorrelationID:success:failure: for clarity
///
/// @param authCode Authorization Code
/// @param correlationId PayPal App Correlation ID (See `-[BTClient btPayPal_applicationCorrelationId]` and https://github.com/paypal/PayPal-iOS-SDK/blob/master/docs/future_payments_mobile.md#obtain-an-application-correlation-id.)
/// @param successBlock success callback for handling the resulting new PayPal account payment method
/// @param failureBlock failure callback for handling errors
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                              correlationId:(NSString *)correlationId
                                    success:(nullable BTClientPaypalSuccessBlock)successBlock
                                    failure:(nullable BTClientFailureBlock)failureBlock DEPRECATED_ATTRIBUTE;

#pragma mark - Coinbase

/// Save a Coinbase payment method to Braintree (beta)
///
/// @param coinbaseAuthResponse A Coinbase authorization response of type NSDictionary
/// @param successBlock success callback for handling the resulting new Coinbase account payment method
/// @param failureBlock failure callback for handling errors
- (void)saveCoinbaseAccount:(id)coinbaseAuthResponse
               storeInVault:(BOOL)storeInVault
                    success:(nullable BTClientCoinbaseSuccessBlock)successBlock
                    failure:(nullable BTClientFailureBlock)failureBlock;

#pragma mark Create a Braintree Analytics Event

/// "Fire and forget analytics" - transmits an analytics event to the Braintree analytics service
///
/// @param eventKind The analytics event name
- (void)postAnalyticsEvent:(NSString *)eventKind
                   success:(nullable BTClientAnalyticsSuccessBlock)successBlock
                   failure:(nullable BTClientFailureBlock)failureBlock;

- (void)postAnalyticsEvent:(NSString *)eventKind;

#pragma mark - Library Metadata

/// Retrieve the current library version.
///
/// @return A string representation of this library's current semver.org version.
+ (NSString *)libraryVersion;

@end

@interface BTClient (Deprecated)

/// Save a card to Braintree
///
/// You have two options for validation when saving a card to Braintree. You can specify
/// that only valid options should be saved.
///
/// @param cardNumber card number (PAN)
/// @param expirationMonth card expiration month (e.g. @"01")
/// @param expirationYear card expiration year (e.g. @"2018")`
/// @param cvv card's cvv three or four digit verification code (optional, depending on your Gateway settings)
/// @param postalCode card's postal code for address verification (optional, depending on your Gateway settings)
/// @param shouldValidate whether details should be validated before creating a nonce for them
/// @param successBlock success callback for handling the resulting new card
/// @param failureBlock failure callback for handling errors
///
/// @see challenges
- (void)saveCardWithNumber:(NSString *)cardNumber
           expirationMonth:(NSString *)expirationMonth
            expirationYear:(NSString *)expirationYear
                       cvv:(nullable NSString *)cvv
                postalCode:(nullable NSString *)postalCode
                  validate:(BOOL)shouldValidate
                   success:(nullable BTClientCardSuccessBlock)successBlock
                   failure:(nullable BTClientFailureBlock)failureBlock DEPRECATED_MSG_ATTRIBUTE("Please use BTClientCardRequest and saveCardWithRequest:validate:success:failure:");

@end

NS_ASSUME_NONNULL_END
