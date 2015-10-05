#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@class BTDropInViewController, BTPaymentButton;

NS_ASSUME_NONNULL_BEGIN

@interface Braintree (UI)

/// Create a new drop in view controller with a client key.
///
/// @note Malformed or invalid client keys may not cause this method to return `nil`.
/// Client keys are designed for Braintree to initialize itself without requiring an initial
/// network call, so the only validation that occurs is a basic syntax check.
///
/// @param clientKey The client key. Passing an invalid key will return `nil`.
/// @return A drop in view controller, or `nil` if the client key is invalid.
+ (nullable BTDropInViewController *)dropInViewControllerWithClientKey:(NSString *)clientKey;


/// Create a new card tokenization client with a client token from your server.
///
/// @param clientToken The client token retrieved from your server. Passing an invalid client
/// token will return `nil`.
/// @return A drop in view controller, or `nil` if the client token is invalid.
+ (nullable BTDropInViewController *)dropInViewControllerWithClientToken:(NSString *)clientToken;


/// Create a new payment button with a client key.
///
/// @note Malformed or invalid client keys may not cause this method to return `nil`.
/// Client keys are designed for Braintree to initialize itself without requiring an initial
/// network call, so the only validation that occurs is a basic syntax check.
///
/// @param clientKey The client key. Passing an invalid key will return `nil`.
/// @return A payment button, or `nil` if the client key is invalid.
+ (nullable BTPaymentButton *)paymentButtonWithClientKey:(NSString *)clientKey;


/// Create a new payment button with a client token from your server.
///
/// @param clientToken The client token retrieved from your server. Passing an invalid client
/// token will return `nil`.
/// @return A payment button, or `nil` if the client token is invalid.
+ (nullable BTPaymentButton *)paymentButtonWithClientToken:(NSString *)clientToken;

@end

NS_ASSUME_NONNULL_END
