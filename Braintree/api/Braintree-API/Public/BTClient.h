#import <Foundation/Foundation.h>

#import "BTCardPaymentMethod.h"
#import "BTPayPalPaymentMethod.h"
#import "BTErrors.h"

#pragma mark Types

/// Block type that takes an `NSArray` of `BTPaymentMethod`s
typedef void (^BTClientPaymentMethodListSuccessBlock)(NSArray *paymentMethods);

/// Block type that takes a `BTCardPaymentMethod`
typedef void (^BTClientCardSuccessBlock)(BTCardPaymentMethod *card);

/// Success Block type for the Save Paypal call
typedef void (^BTClientPaypalSuccessBlock)(BTPayPalPaymentMethod *paypalPaymentMethod);

/// Success Block type for analytics events
typedef void (^BTClientAnalyticsSuccessBlock)(void);

/// Block type for handling `BTClient` errors
typedef void (^BTClientFailureBlock)(NSError *error);

/// A `BTClient` performs Braintree API operations and returns
/// resulting responses or errors. It is the entry-point for all
/// communication with Braintree.
@interface BTClient : NSObject

/// Initialize and configure a `BTClient` with a client token.
/// The client token dictates the behavior of subsequent operations.
///
/// @param clientTokenString Braintree client token
- (instancetype)initWithClientToken:(NSString *)clientTokenString;

/// The set of challenges that need to be provided to `saveCardWithNumber`
/// in order to save a card. This is dependent upon on your Gateway settings
/// (potentially among other factors).
@property (nonatomic, readonly) NSSet *challenges;

#pragma mark API Methods

/// Obtain a list of payment methods saved to Braintree
///
/// @param successBlock success callback for handling the returned list of payment methods
/// @param failureBlock success callback for handling errors
- (void)fetchPaymentMethodsWithSuccess:(BTClientPaymentMethodListSuccessBlock)successBlock
                               failure:(BTClientFailureBlock)failureBlock;

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
                   failure:(BTClientFailureBlock)failureBlock;

/// Save a paypal payment method to Braintree
/// @param authCode Authorization Code
/// @param correlationId PayPal App Correlation Id
/// @param successBlock success callback for handling the resulting new PayPal account payment method
/// @param failureBlock failure callback for handling errors
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                              correlationId:(NSString *)applicationCorrelationId
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock;

/// Save a paypal payment method to Braintree without a PayPal App Correlation ID
/// @param authCode Authorization Code
/// @param successBlock success callback for handling the resulting new PayPal account payment method
/// @param failureBlock failure callback for handling errors
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock DEPRECATED_ATTRIBUTE;


/// "Fire and forget analytics" - transmits an analytics event to the Braintree analytics service
///
/// @param eventKind The analytics event name
- (void)postAnalyticsEvent:(NSString *)eventKind
                   success:(BTClientAnalyticsSuccessBlock)successBlock
                   failure:(BTClientFailureBlock)failureBlock;

#pragma mark - Library Metadata

/// Retrieve the current library version.
///
/// @return A string representation of this library's current semver.org version.
+ (NSString *)libraryVersion;

@end