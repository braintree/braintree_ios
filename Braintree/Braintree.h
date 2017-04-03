#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <Braintree/Braintree-API.h>
#import <Braintree/Braintree-PayPal.h>
#import <Braintree/Braintree-Payments-UI.h>
#import <Braintree/Braintree-Payments.h>

#import <Braintree/BTDropInViewController.h>
#import <Braintree/BTPaymentButton.h>
#import <Braintree/BTClientCardTokenizationRequest.h>

@class Braintree;
@class PKPayment;

NS_ASSUME_NONNULL_BEGIN

typedef void (^BraintreeCompletionBlock)(Braintree *__nullable braintree, NSError *__nullable error);

/// The `Braintree` class is the front door to the Braintree SDK for iOS. It contains
/// everything you need to easily start accepting payments in your mobile app.
///
/// You can use Drop-In (our own provided UI components), or Custom (your own UI with a
/// Braintree backend).
///
/// With Drop-In, you can rely us to provide a fast, easy-to-use UI, which your users will
/// interact with in order to provide payment details.
///
/// With Custom, you have control of your UI, but errors will be handled on the
/// server-side via multiple server-side calls to Braintree. Like Drop-In, the end result is
/// a nonce, which you may transmit to your servers.
///
/// Regardless of how you integrate, the result, from the programmer's perspective, is a `BTPaymentMethod`
/// that has a `nonce` property. Send this nonce to your server to perform a variety of payment
/// operations, such as creating a sale.
///
/// For advanced integrations, you can use BTClient, BTPaymentButton, BTDropInViewController, etc. directly.
@interface Braintree : NSObject

/// Returns an instance of `Braintree`, the public interface of Braintree-iOS.
///
/// @param clientToken value that is generated on your server using a Braintree server-side
///  client library that contains all necessary configuration to setup the client SDKs. It also
///  authenticates the application to communicate directly to Braintree.
///
/// @see BTClient+Offline.h for offline client tokens that make it easy to test out the SDK without a
///  server-side integration.
///
/// @note You should generate a new client token before each checkout to ensure it has not expired.
///
/// @return An instance of the Braintree Library to perform payment operations.
+ (nullable Braintree *)braintreeWithClientToken:(NSString *)clientToken;

#pragma mark UI

/// Creates and returns a payment flow for accepting credit card, PayPal and Venmo based payments.
///
/// Present this view controller in your app to prompt your user for payment info, and you will
/// receive a payment method nonce.
///
/// @param delegate Delegate that is notified of success with a payment method containing a payment method nonce or an error.
///
/// @return A Drop-In view controller to be presented in your app's payment flow.
- (BTDropInViewController *)dropInViewControllerWithDelegate:(id<BTDropInViewControllerDelegate>)delegate;

/// Creates and returns a payment button for accepting PayPal and Venmo based payments.
///
/// Payment method creation may take place via app switch or via a UI flow in a view controller.
///
/// If available, this button will initiate One Touch Payments for PayPal or Venmo.
/// To enable One Touch, you should use setReturnURLSchemes: and handleOpenURL:sourceApplication: (see below).
///
/// @note The payment button touch handlers may initiate view controllers and/or app switching. For fine-grained control, you may use BTPaymentProvider directly.
///
/// @param delegate a delegate that receives lifecycle updates about the payment method authorization
///
/// @return A button you can add to your checkout flow.
- (BTPaymentButton *)paymentButtonWithDelegate:(id<BTPaymentMethodCreationDelegate>)delegate;

/// Creates and returns a payment button for accepting PayPal and/or Venmo based payments.
///
/// This method has identical behavior to paymentButtonWithDelegate: but allows you to specify the
/// payment provider types and their display order.
///
/// @param delegate a delegate that receives lifecycle updates about the payment method authorization
/// @param types    payment method types to enable from BTPaymentProviderType. If nil, the button may expose any available payment authorization types.
///
/// @return A button you can add to your checkout flow.
- (BTPaymentButton *)paymentButtonWithDelegate:(id<BTPaymentMethodCreationDelegate>)delegate paymentProviderTypes:(nullable NSOrderedSet *)types;


#pragma mark Custom

/// Creates and returns a payment method nonce for the given credit card details.
///
/// @note The credit card details provided are neither validated nor added to the Vault until you
///       perform a server-side operation with the nonce, such as `Transaction.create`, is performed.
///
/// @see BTClientCardRequest
///
/// @param cardDetails a tokenization request object containing the raw card details
/// @param completionBlock Completion block that is called exactly once asynchronously, providing either a nonce upon success or an error upon failure.
- (void)tokenizeCard:(BTClientCardTokenizationRequest *)cardDetails
          completion:(void (^)(NSString * __nullable nonce, NSError * __nullable error))completionBlock;

/// Creates and returns a payment method nonce for the given Apple Pay payment details
///
/// @note You should use this method if you have implemented Apple Pay directly with PassKit (PKPaymentRequest,
///       PKPaymentAuthorizationViewController, etc.). Alternatively, you can use paymentProviderWithDelegate:.
///
/// @param applePayPayment a PKPayment you receive from a PKPaymentAuthorizationViewControllerDelegate
/// @param completionBlock Completion block that is called exactly once asynchronously, providing either a nonce upon success or an error upon failure.
- (void)tokenizeApplePayPayment:(PKPayment *)applePayPayment
                     completion:(void (^)(NSString * __nullable nonce, NSError * __nullable error))completionBlock;

/// Initializes a provider that can initiate various payment method creation flows.
///
/// You should send `createPaymentMethod:` to the returned BTPaymentProvider after some user interaction takes place (for example, when the user taps your "Pay with PayPal" button.)
///
/// In order to receive delegate methods, the caller is responsible for retaining this Braintree
/// instance or the returned BTPaymentProvider object!
///
/// Payment method authorization may take place via app switch or via a UI flow in a view controller.
///
/// If available, this method may initiate One Touch Payments for PayPal or Venmo.
/// To enable One Touch, you should use setReturnURLSchemes: and handleOpenURL:sourceApplication: (see below).
///
/// @note If you do not wish to implement your own UI, see also dropInViewControllerWithDelegate: and paymentButtonWithDelegate:paymentProviderTypes:.
///
/// @note The payment button touch handlers may initiate view controllers and/or app switching. For fine-grained control, you may use BTPaymentProvider directly.
///
/// @see BTDropInViewController
/// @see BTPaymentButton
/// @param delegate a delegate that receives lifecycle updates about the payment method authorization
- (BTPaymentProvider *)paymentProviderWithDelegate:(id<BTPaymentMethodCreationDelegate>)delegate;

#pragma mark - One Touch Payments

/// The custom URL scheme that the authenticating app should use to return users to your app via `openURL:` (app switch).
///
/// When `nil` or when invalid, One Touch app switch will be disabled
///
/// @note This must match the entry in your app's Info.plist, and must be prefixed
/// with your Bundle ID, e.g. com.yourcompany.Your-App.payment
+ (void)setReturnURLScheme:(NSString *)scheme;

/// Handle app switch URL requests for the Braintree SDK
///
/// @param url               The URL received by the application delegate `openURL` method
/// @param sourceApplication The source application received by the application delegate `openURL` method
///
/// @return Whether Braintree was able to handle the URL and source application
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;


#pragma mark Advanced Integrations

/// A pre-configured BTClient based on your client token.
///
/// You can use this client to initialize various SDK objects, such as BTDropInViewController, BTPaymentButton, BTPaymentProvider, etc.
@property (nonatomic, readonly) BTClient *client;


#pragma mark - Library Metadata

/// Returns the current library version.
///
/// @return A string representation of this library's current semver.org version (if integrating with CocoaPods).
+ (NSString *)libraryVersion;

@end

@interface Braintree (Deprecated)

/// Creates and returns a nonce for the given credit card details.
///
/// This signature has been deprecated in favor of the more flexible `tokenizeCard:completion:`.
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
                    completion:(void (^)(NSString * __nullable nonce, NSError * __nullable error))completionBlock DEPRECATED_MSG_ATTRIBUTE("Please use -[Braintree tokenizeCardWithComponents:completion:]");


/// Creates and returns a PayPal button that can be added to the UI. When tapped, this button will initiate the PayPal authorization flow.
///
/// @param delegate Delegate that is notified of completion, receiving either a payment method with a nonce (upon user agreement and success) or an error (upon failure).
///
/// @return A PayPal button to be added as a subview in your UI.
- (nullable BTPayPalButton *)payPalButtonWithDelegate:(id<BTPayPalButtonDelegate>)delegate DEPRECATED_MSG_ATTRIBUTE("Please use -[Braintree paymentButtonWithDelegate:]");

@end

NS_ASSUME_NONNULL_END
