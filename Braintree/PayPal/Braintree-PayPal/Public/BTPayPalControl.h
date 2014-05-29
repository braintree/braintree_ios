#import <UIKit/UIKit.h>

#import "Braintree-API.h"

@protocol BTPayPalControlDelegate;
@protocol BTPayPalControlViewControllerPresenterDelegate;

#pragma mark -

/// A UIControl subclass for initiating a PayPal auth flow, and displaying the state of the user's PayPal auth. This view
/// is appropriate for adding to your checkout form as a button.
///
/// By default, tapping on this control will result in a `BTPayPalViewController` being presented by a heuristically
/// determined ViewController. If you need to customize this behavior, you can specify your own `BTPayPalControlViewControllerPresenterDelegate`.
@interface BTPayPalControl : UIControl

/// A delegate that is notified as the PayPal consent flow triggered by this control changes state.
@property (nonatomic, weak) id<BTPayPalControlDelegate> delegate;

/// As an alternative to `delegate`, you may additionally specify a block for state change
/// notifications if a block-based interface is more convenient in your use case.
///
/// @param paymentMethodCompletionBlock A block to be invoked upon completion
- (void)setPaymentMethodCompletionBlock:(void (^)(BTPaymentMethod *paymentMethod, NSError *error))paymentMethodCompletionBlock;


/// An optional delegate that is notified when the `BTPayPalControl` is requesting presentation of
/// a view controller that will manage PayPal authentication flow.
@property (nonatomic, weak) id<BTPayPalControlViewControllerPresenterDelegate> presentationDelegate;

/// Your initialized Braintree client.
///
/// @see Braintree-API-iOS
@property (nonatomic, strong) BTClient *client;

/// Clear the currently logged-in user, if any.
- (void)clear;

@end

#pragma mark -

/// Delegate protocol for receiving messages about state changes to a `BTPayPalControl`
///
/// @see BTPayPalControl
@protocol BTPayPalControlDelegate <NSObject>

/// This message is sent when a payment method has been authorized and is available.
///
///  @param control The requesting `BTPayPalControl`
///  @param nonce   The nonce representing proof of an authorized payment method
- (void)payPalControl:(BTPayPalControl *)control didCreatePayPalAccount:(BTPaymentMethod *)paymentMethod;

/// This message is sent when the payment method is no longer available
///
///  @param control The requesting `BTPayPalControl`
- (void)payPalControl:(BTPayPalControl *)control didFailWithError:(NSError *)error;

@end

/// Delegate protocol for receiving request to present a view controller when the user taps the `BTPayPalControl` instance.
///
/// @note Providing a custom implementation of this protocol to your `BTPayPalControl` is not required.
///
/// @see BTPayPalControl
@protocol BTPayPalControlViewControllerPresenterDelegate <NSObject>

/// The control sends the delegate this message when it has prepared a `BTPayPalViewController`, which your implementation
/// should present to initiate the PayPal UI flow.
///
///  @param control        The requesting `BTPayPalControl`
///  @param viewController A configured view controller to be presented
- (void)payPalControl:(BTPayPalControl *)control requestsPresentationOfViewController:(UIViewController *)viewController;

/// The control sends the delegate this message when its view controller is ready to be dismissed.
///
///  @param control        The requesting `BTPayPalControl`
///  @param viewController A configured view controller to be presented
- (void)payPalControl:(BTPayPalControl *)control requestsDismissalOfViewController:(UIViewController *)viewController;

@end
