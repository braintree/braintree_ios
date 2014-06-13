#import <UIKit/UIKit.h>

#import "Braintree-API.h"

typedef void (^BTPayPalPaymentMethodCompletionBlock)(BTPaymentMethod *paymentMethod, NSError *error);

@protocol BTPayPalControlDelegate;
@protocol BTPayPalControlViewControllerPresenterDelegate;

#pragma mark -

/// A UIControl subclass for initiating a PayPal auth flow, and displaying the state of the user's PayPal auth. This view
/// is appropriate for adding to your checkout form as a *full-width* button.
///
/// By default, tapping on this control will result in a `BTPayPalViewController` being presented by a heuristically
/// determined ViewController. If you need to customize this behavior, you can specify your own `BTPayPalControlViewControllerPresenterDelegate`.
@interface BTPayPalControl : UIControl

/// A delegate that is notified as the PayPal consent flow triggered by this control changes state.
@property (nonatomic, weak) id<BTPayPalControlDelegate> delegate;

/// As an alternative to `delegate`, you may additionally specify a block for completion.
@property (nonatomic, copy) BTPayPalPaymentMethodCompletionBlock completionBlock;

/// An optional delegate that is notified when the `BTPayPalControl` is requesting presentation of
/// a view controller that will manage PayPal authentication flow.
@property (nonatomic, weak) id<BTPayPalControlViewControllerPresenterDelegate> presentationDelegate;

/// Your initialized Braintree client.
///
/// @see Braintree-API-iOS
@property (nonatomic, strong) BTClient *client;

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
- (void)payPalControl:(BTPayPalControl *)control didCreatePayPalPaymentMethod:(BTPaymentMethod *)paymentMethod;

/// This message is sent when the payment method could not be created.
///
///  @param control The requesting `BTPayPalControl`
- (void)payPalControl:(BTPayPalControl *)control didFailWithError:(NSError *)error;

@optional

/// This message is sent when the user has authorized PayPal, and the payment method
/// is about to be created.
///
///  @param control The requesting `BTPayPalControl`
- (void)payPalControlWillCreatePayPalPaymentMethod:(BTPayPalControl *)control;

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
