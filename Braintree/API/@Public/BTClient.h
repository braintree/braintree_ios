@import Foundation;

#import "BTCardPaymentMethod.h"
#import "BTPayPalPaymentMethod.h"

#import "BTApplePayPaymentMethod.h"

#import "BTErrors.h"
#import "BTClientCardRequest.h"

#pragma mark Types

/// Block type that takes an `NSArray` of `BTPaymentMethod`s
typedef void (^BTClientPaymentMethodListSuccessBlock)(NSArray *paymentMethods);

/// Block type that takes a single `BTPaymentMethod`
typedef void (^BTClientPaymentMethodSuccessBlock)(BTPaymentMethod *paymentMethod);

/// Block type that takes a `BTCardPaymentMethod`
typedef void (^BTClientCardSuccessBlock)(BTCardPaymentMethod *card);

/// Success Block type for the Save Apple Pay call
typedef void (^BTClientApplePaySuccessBlock)(BTApplePayPaymentMethod *applePayPaymentMethod);

/// Success Block type for the Save Paypal call
typedef void (^BTClientPaypalSuccessBlock)(BTPayPalPaymentMethod *paypalPaymentMethod);

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
- (instancetype)initWithClientToken:(NSString *)clientTokenString;

/// The set of challenges that need to be provided to `saveCardWithNumber`
/// in order to save a card. This is dependent upon on your Gateway settings
/// (potentially among other factors).
@property (nonatomic, readonly) NSSet *challenges;

/// The public Braintree Merchant ID for which this client
/// was initialized.
@property (nonatomic, copy, readonly) NSString *merchantId;

#pragma mark API Methods

/// Obtain a list of payment methods saved to Braintree
///
/// @param successBlock success callback for handling the returned list of payment methods
/// @param failureBlock failure callback for handling errors
- (void)fetchPaymentMethodsWithSuccess:(BTClientPaymentMethodListSuccessBlock)successBlock
                               failure:(BTClientFailureBlock)failureBlock;

/// Obtain information about a payment method based on a nonce
///
/// @param successBlock success callback for handling the retrieved payment methods
/// @param failureBlock failure callback for handling errors
- (void)fetchPaymentMethodWithNonce:(NSString *)nonce
                            success:(BTClientPaymentMethodSuccessBlock)successBlock
                            failure:(BTClientFailureBlock)failureBlock;

/// Save a card to Braintree
///
/// @param request an object that includes the raw card details
/// @param successBlock success callback for handling the resulting new card
/// @param failureBlock failure callback for handling errors
///
/// @see challenges
- (void)saveCardWithRequest:(BTClientCardRequest *)request
                    success:(BTClientCardSuccessBlock)successBlock
                    failure:(BTClientFailureBlock)failureBlock;



/// Save a payment method created via Apple Pay
///
/// @param applePayRequest A BTClientApplePayRequest
/// @param successBlock success callback for handling the resulting payment method
/// @param failureBlock failure callback for handling errors
- (void)saveApplePayPayment:(PKPayment *)payment
                    success:(BTClientApplePaySuccessBlock)successBlock
                    failure:(BTClientFailureBlock)failureBlock;

/// Save a paypal payment method to Braintree
///
/// @param authCode Authorization Code
/// @param applicationCorrelationID PayPal App Correlation Id (See `-[BTClient btPayPal_applicationCorrelationId]` and https://github.com/paypal/PayPal-iOS-SDK/blob/master/docs/future_payments_mobile.md#obtain-an-application-correlation-id.)
/// @param successBlock success callback for handling the resulting new PayPal account payment method
/// @param failureBlock failure callback for handling errors
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                   applicationCorrelationID:(NSString *)applicationCorrelationId
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock;

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
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock DEPRECATED_ATTRIBUTE;

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
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock DEPRECATED_ATTRIBUTE;

/// "Fire and forget analytics" - transmits an analytics event to the Braintree analytics service
///
/// @param eventKind The analytics event name
- (void)postAnalyticsEvent:(NSString *)eventKind
                   success:(BTClientAnalyticsSuccessBlock)successBlock
                   failure:(BTClientFailureBlock)failureBlock;

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
/// @param validate whether details should be validated before creating a nonce for them
/// @param successBlock success callback for handling the resulting new card
/// @param failureBlock failure callback for handling errors
///
/// @see challenges
- (void)saveCardWithNumber:(NSString *)creditCardNumber
           expirationMonth:(NSString *)expirationMonth
            expirationYear:(NSString *)expirationYear
                       cvv:(NSString *)cvv
                postalCode:(NSString *)postalCode
                  validate:(BOOL)shouldValidate
                   success:(BTClientCardSuccessBlock)successBlock
                   failure:(BTClientFailureBlock)failureBlock DEPRECATED_MSG_ATTRIBUTE("Please use BTClientCardRequest and saveCardWithRequest:validate:success:failure:");

@end