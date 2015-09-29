#import <Foundation/Foundation.h>
#import "BTNullability.h"

@class BTAPIClient;

BT_ASSUME_NONNULL_BEGIN

@interface Braintree : NSObject


/// Creates a Braintree API client using a client key.
///
/// This is a convenience wrapper for `BTAPIClient`'s' `-initWithClientKey:` initializer.
///
/// @note Malformed or invalid client keys may not cause this method to return `nil`.
/// Client keys are designed for Braintree to initialize itself without requiring an initial
/// network call, so the only validation that occurs is a simple syntactical check.
///
/// @param clientKey The client key
/// @return A Braintree API client, or `nil` if the client key can be determined to be malformed.
+ (BT_NULLABLE BTAPIClient *)clientWithClientKey:(NSString *)clientKey;


/// Creates a Braintree API client using a client token.
///
/// This is a convenience wrapper for `BTAPIClient`'s' `-initWithClientToken:` initializer.
///
/// @param clientToken The client token
/// @return A Braintree API client, or `nil` if the client token is invalid
+ (BT_NULLABLE BTAPIClient *)clientWithClientToken:(NSString *)clientToken;


/// Sets the return URL scheme for your app.
///
/// This must be configured if your app integrates a payment option that may switch to either
/// Mobile Safari or to another app to finish the payment authorization workflow.
///
/// @param returnURLScheme The return URL scheme
+ (void)setReturnURLScheme:(NSString *)returnURLScheme;


/// Handles a return from app switch
/// @param url The URL that was opened to return to your app
/// @param sourceApplication The source app that requested the launch of your app
/// @return `YES` if the URL was handled
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;


/// Handles a return from app switch
/// @param url The URL that was opened to return to your app
/// @param options The options dictionary provided by `application:openURL:options:`
/// @return `YES` if the URL was handled
+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options;


@end

BT_ASSUME_NONNULL_END
