#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BTPaymentMethod.h"

/// Protocol for receiving payment method creation lifecycle messages from
/// an object creating a payment method, such as BTPaymentButton, BTPaymentProvider and BTThreeDSecure.
@protocol BTPaymentMethodCreationDelegate <NSObject>

/// The payment method creator requires presentation of a view controller in order to
/// proceed.
///
/// Your implementation should present the viewController modally, e.g. via
/// `presentViewController:animated:completion:`
///
/// @param sender         The payment method creator
/// @param viewController The view controller to be presented
- (void)paymentMethodCreator:(id)sender requestsPresentationOfViewController:(UIViewController *)viewController;

/// The payment method creator requires dismissal of a view controller.
///
/// Your implementation should dismiss the viewController, e.g. via
/// `dismissViewControllerAnimated:completion:`
///
/// @param sender         The payment method creator
/// @param viewController The view controller to be dismissed
- (void)paymentMethodCreator:(id)sender requestsDismissalOfViewController:(UIViewController *)viewController;

/// The payment method creator will perform an app switch in order to obtain user
/// payment authorization.
///
/// Your implementation of this method should set your app to the state
/// it should be in if the user manually app-switches back to your app.
/// For example, re-enable any controls that are disabled.
///
/// @param sender The payment method creator
- (void)paymentMethodCreatorWillPerformAppSwitch:(id)sender;

/// The payment method creator, having obtained user payment details and/or user
/// authorization, will now process the results.
///
/// This typically indicates asynchronous network activity.
/// When you receive this message, your UI should indicate activity.
///
/// In the case of an app switch, this message indicates that the user has returned to this app.
///
/// @param sender The payment method creator
- (void)paymentMethodCreatorWillProcess:(id)sender;

/// The payment method creator has cancelled.
///
/// @param sender The payment method creator
- (void)paymentMethodCreatorDidCancel:(id)sender;

/// Payment method creation is complete with success.
///
/// Typically, an implementation will convey this paymentMethod to your own server
/// for further use or to the user for final confirmation.
///
/// @param sender        The payment method creator
/// @param paymentMethod The resulting payment method
- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

/// The payment method creator failed to create a payment method.
///
/// A failure may occur at any point during payment method creation, such as:
/// - Payment authorization is initiated with an incompatible configuration (e.g. no authorization
///   mechanism possible for specified provider)
/// - An authorization provider (e.g. Venmo or PayPal) encounters an error
/// - A network or gateway error occurs
/// - The user-provided credentials led to a non-transactable payment method.
///
/// @param sender The payment method creator
/// @param error  An error that characterizes the failure
- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error;

@end
