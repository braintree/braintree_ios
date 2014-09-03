#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <Braintree/Braintree-API.h>
#import <Braintree/Braintree-PayPal.h>
#import <Braintree/Braintree-Venmo.h>
#import <Braintree/Braintree-Payments-UI.h>

#import "BTDropInViewController.h"
#import "BTPaymentMethodAuthorizationDelegate.h"

/// The `Braintree` class is the front door to the Braintree SDK for iOS. It contains
/// everything you need to easily start accepting payments in your mobile app.
///
/// You can choose: Drop-In or Custom.
///
/// With Drop-In, you can rely us to provide a fast, easy-to-use UI, which your users will
/// interact with in order to provide payment details. The result, from the programmer's
/// perspective, is a nonce. Send this nonce to your server to perform a variety of payment 
/// operations, such as creating a sale.
///
/// With custom, you have control of your UI, but errors will be handled on the
/// server-side via multiple server-side calls to Braintree. Like Drop-In, the end result is
/// a nonce, which you may transmit to your servers.
///
/// For advanced integrations, you should use BTClient, BTPayPalButton, BTDropInViewController, etc. directly.
@interface Braintree : NSObject

/// Returns an instance of `Braintree`, the public interface of Braintree-iOS.
///
/// @param clientToken value that is generated on your sever using a Braintree server-side
///  client library that contains all necessary configuration to setup the client SDKs. It also
///  authenticates the application to communicate directly to Braintree.
///
/// @see BTClient+Offline.h for offline client tokens that make it easy to test out the SDK without a
///  server-side integration.
///
/// @note You should generate a new client token before each checkout to ensure it has not expired.
///
/// @return An instance of the Braintree Library to perform payment operations.
+ (Braintree *)braintreeWithClientToken:(NSString *)clientToken;


#pragma mark Drop In

/// Creates and returns a payment flow for accepting credit card and PayPal-based payments.
///
/// Present this view controller in your app to prompt your user for payment info, and you will
/// receive a payment method nonce.
///
/// @param delegate Delegate that is notified of success with a payment method containing a payment method nonce or an error.
///
/// @return A Drop-In view controller to be presented in your app's payment flow.
- (BTDropInViewController *)dropInViewControllerWithDelegate:(id<BTDropInViewControllerDelegate>)delegate;


#pragma mark Custom

/// Creates and returns a PayPal button that can be added to the UI. When tapped, this button will initiate the PayPal authorization flow.
///
/// @param delegate Delegate that is notified of completion, receiving either a payment method with a nonce (upon user agreement and success) or an error (upon failure).
///
/// @return A PayPal button to be added as a subview in your UI.
- (BTPayPalButton *)payPalButtonWithDelegate:(id<BTPayPalButtonDelegate>)delegate;


/// Creates and returns a nonce for the given credit card details.
///
/// @note The credit card details provided are not validated until a
///  Braintree operation, such as `Transaction.Create` is performed on
///  your server.
///
/// @param cardNumber      Card number to tokenize
/// @param expirationMonth Card's expiration month
/// @param expirationYear  Card's expiration year
/// @param completionBlock Completion block that is called exactly once asynchronously, providing either a nonce upon success or an error upon failure.
- (void)tokenizeCardWithNumber:(NSString *)cardNumber
               expirationMonth:(NSString *)expirationMonth
                expirationYear:(NSString *)expirationYear
                    completion:(void (^)(NSString *nonce, NSError *error))completionBlock;


/// Initiates a payment method authorization flow.
///
/// You should invoke this method after some user interaction takes place (for example, when the user taps a "PayPal" button.
///
/// Payment method authorizaiton takes place via app switch (if available) or via a UI flow in a view controller.
///
/// @note If you do not wish to implement your own UI, the Braintree SDK includes UI options for payment buttons that allow the user to initiate payment method authorization.
///
///  @param type     the payment type to authorize, such as PayPal or Venmo
///  @param delegate a delegate that receives lifecycle updates about the payment method authorization
- (void)initiatePaymentMethodAuthorization:(BTPaymentAuthorizationType)type delegate:(id<BTPaymentAuthorizerDelegate>)delegate;


#pragma mark Advanced Integrations

/// A pre-configured BTClient based on your client token.
///
/// You can use this client when setting BTPayPalButton or BTDropInViewController's client.
@property (nonatomic, readonly) BTClient *client;


#pragma mark - Library Metadata

/// Returns the current library version.
///
/// @return A string representation of this library's current semver.org version (if integrating with CocoaPods).
+ (NSString *)libraryVersion;


#pragma mark - One Touch™ Payments

/// The custom URL scheme that the authenticating app should use to return users to your app via `openURL:` (app switch).
///
/// When `nil` or when invalid, One Touch app switch will be disabled
///
/// @note This must match the entry in your app's Info.plist, and must be prefixed
/// with your Bundle ID, e.g. com.yourcompany.Your-App.payment
+ (void)setReturnURLScheme:(NSString *)scheme;

///  Handle app switch URL requests for the Braintree SDK
///
///  @param url               The URL received by the application delegate `openURL` method
///  @param sourceApplication The source application received by the application delegate `openURL` method
///
///  @return Whether Braintree was able to handle the URL and source application
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;


@end