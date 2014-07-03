#import <UIKit/UIKit.h>

#import "Braintree-API.h"

@protocol BTPayPalButtonDelegate;
@protocol BTPayPalButtonViewControllerPresenterDelegate;

#pragma mark -

/// A UIControl subclass for initiating a PayPal auth flow, and displaying the state of the user's PayPal auth. This view
/// is appropriate for adding to your checkout form as a *full-width* button.
///
/// By default, tapping on this button will result in a `BTPayPalViewController` being presented by a heuristically
/// determined ViewController. If you need to customize this behavior, you can specify your own `BTPayPalButtonViewControllerPresenterDelegate`.
@interface BTPayPalButton : UIControl

/// A delegate that is notified as the PayPal consent flow triggered by this button changes state.
@property (nonatomic, weak) id<BTPayPalButtonDelegate> delegate;

/// An optional delegate that is notified when the `BTPayPalButton` is requesting presentation of
/// a view controller that will manage PayPal authentication flow.
@property (nonatomic, weak) id<BTPayPalButtonViewControllerPresenterDelegate> presentationDelegate;

/// Your initialized Braintree client.
///
/// @see Braintree-API-iOS
@property (nonatomic, strong) BTClient *client;

@end

#pragma mark -

/// Delegate protocol for receiving messages about state changes to a `BTPayPalButton`
///
/// @see BTPayPalButton
@protocol BTPayPalButtonDelegate <NSObject>

/// This message is sent when a payment method has been authorized and is available.
///
/// @param button The requesting `BTPayPalButton`
///  @param nonce   The nonce representing proof of an authorized payment method
- (void)payPalButton:(BTPayPalButton *)button didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod;

/// This message is sent when the payment method could not be created.
///
/// @param button The requesting `BTPayPalButton`
- (void)payPalButton:(BTPayPalButton *)button didFailWithError:(NSError *)error;

@optional

/// This message is sent when the user has authorized PayPal, and the payment method
/// is about to be created.
///
/// @param button The requesting `BTPayPalButton`
- (void)payPalButtonWillCreatePayPalPaymentMethod:(BTPayPalButton *)button;

@end

/// Delegate protocol for receiving request to present a view controller when the user taps the `BTPayPalButton` instance.
///
/// @note Providing a custom implementation of this protocol to your `BTPayPalButton` is not required.
///
/// @see BTPayPalButton
@protocol BTPayPalButtonViewControllerPresenterDelegate <NSObject>

/// The button sends the delegate this message when it has prepared a `BTPayPalViewController`, which your implementation
/// should present to initiate the PayPal UI flow.
///
///  @param button        The requesting `BTPayPalButton`
///  @param viewController A configured view controller to be presented
- (void)payPalButton:(BTPayPalButton *)button requestsPresentationOfViewController:(UIViewController *)viewController;

/// The button sends the delegate this message when its view controller is ready to be dismissed.
///
///  @param button        The requesting `BTPayPalButton`
///  @param viewController A configured view controller to be presented
- (void)payPalButton:(BTPayPalButton *)button requestsDismissalOfViewController:(UIViewController *)viewController;

@end
